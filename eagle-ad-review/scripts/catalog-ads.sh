#!/usr/bin/env bash
# Eagle Ad Review — Ad File Catalog Script
# Scans a folder of ad creatives, catalogs all files by type/dimensions/aspect ratio,
# groups by directory structure, and outputs a structured inventory.
#
# Usage: catalog-ads.sh <folder_path> [output_dir]
# Defaults: output_dir=./ad-catalog

set -euo pipefail

FOLDER="${1:?Usage: catalog-ads.sh <folder_path> [output_dir]}"
OUTPUT_DIR="${2:-./ad-catalog}"

# Validate input
if [ ! -d "$FOLDER" ]; then
  echo "Error: Directory not found: $FOLDER"
  exit 1
fi

# Check dependencies
for cmd in identify ffprobe; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Warning: $cmd not found. Some features will be limited."
    echo "  identify: Install ImageMagick for image dimension detection"
    echo "  ffprobe: Install ffmpeg for video metadata"
  fi
done

# Create output directory
mkdir -p "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/thumbnails"

echo "=== Eagle Ad Review — Creative Catalog ==="
echo "Scanning: $FOLDER"
echo ""

# --- Count files by type ---
IMAGE_COUNT=$(find "$FOLDER" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" -o -iname "*.bmp" -o -iname "*.tiff" \) | wc -l | tr -d ' ')
VIDEO_COUNT=$(find "$FOLDER" -type f \( -iname "*.mp4" -o -iname "*.mov" -o -iname "*.avi" -o -iname "*.webm" -o -iname "*.mkv" \) | wc -l | tr -d ' ')
AUDIO_COUNT=$(find "$FOLDER" -type f \( -iname "*.mp3" -o -iname "*.wav" -o -iname "*.aac" -o -iname "*.m4a" -o -iname "*.ogg" -o -iname "*.flac" \) | wc -l | tr -d ' ')
PDF_COUNT=$(find "$FOLDER" -type f -iname "*.pdf" | wc -l | tr -d ' ')
OTHER_COUNT=$(find "$FOLDER" -type f \( -iname "*.xlsx" -o -iname "*.docx" -o -iname "*.pptx" -o -iname "*.csv" \) | wc -l | tr -d ' ')
TOTAL=$((IMAGE_COUNT + VIDEO_COUNT + AUDIO_COUNT + PDF_COUNT + OTHER_COUNT))

echo "=== File Inventory ==="
echo "  Images: $IMAGE_COUNT"
echo "  Videos: $VIDEO_COUNT"
echo "  Audio:  $AUDIO_COUNT"
echo "  PDFs:   $PDF_COUNT"
echo "  Other:  $OTHER_COUNT"
echo "  Total:  $TOTAL"
echo ""

# --- Directory structure (markets/campaigns) ---
echo "=== Directory Structure ==="
find "$FOLDER" -type d -mindepth 1 -maxdepth 2 | sort | while read -r dir; do
  rel_dir="${dir#$FOLDER/}"
  count=$(find "$dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.mp4" -o -iname "*.mov" -o -iname "*.webp" \) | wc -l | tr -d ' ')
  if [ "$count" -gt 0 ]; then
    echo "  $rel_dir ($count files)"
  fi
done
echo ""

# --- Image dimensions and aspect ratios ---
if command -v identify &>/dev/null; then
  echo "=== Image Dimensions ==="

  CATALOG_FILE="$OUTPUT_DIR/image-catalog.csv"
  echo "file,width,height,aspect_ratio,format,size_kb,directory" > "$CATALOG_FILE"

  find "$FOLDER" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" \) | sort | while read -r img; do
    dims=$(identify -format "%w %h" "$img" 2>/dev/null | head -1) || continue
    width=$(echo "$dims" | awk '{print $1}')
    height=$(echo "$dims" | awk '{print $2}')
    size_kb=$(( $(stat -f%z "$img" 2>/dev/null || stat --format=%s "$img" 2>/dev/null) / 1024 ))
    format="${img##*.}"
    dir_name="$(dirname "${img#$FOLDER/}")"

    # Determine aspect ratio category
    if [ "$height" -eq 0 ]; then
      ratio="unknown"
    else
      ratio_val=$(python3 -c "print(round($width/$height, 2))" 2>/dev/null || echo "0")
      if python3 -c "exit(0 if abs($ratio_val - 1.0) < 0.05 else 1)" 2>/dev/null; then
        ratio="1:1 (Square)"
      elif python3 -c "exit(0 if abs($ratio_val - 0.5625) < 0.05 else 1)" 2>/dev/null; then
        ratio="9:16 (Vertical)"
      elif python3 -c "exit(0 if abs($ratio_val - 0.8) < 0.05 else 1)" 2>/dev/null; then
        ratio="4:5 (Portrait)"
      elif python3 -c "exit(0 if abs($ratio_val - 1.7778) < 0.08 else 1)" 2>/dev/null; then
        ratio="16:9 (Landscape)"
      elif python3 -c "exit(0 if abs($ratio_val - 1.91) < 0.08 else 1)" 2>/dev/null; then
        ratio="1.91:1 (Wide)"
      elif python3 -c "exit(0 if abs($ratio_val - 0.6667) < 0.05 else 1)" 2>/dev/null; then
        ratio="2:3 (Pinterest)"
      elif python3 -c "exit(0 if $ratio_val > 1.0 else 1)" 2>/dev/null; then
        ratio="Landscape (${width}×${height})"
      else
        ratio="Portrait (${width}×${height})"
      fi
    fi

    echo "\"$(basename "$img")\",$width,$height,\"$ratio\",$format,$size_kb,\"$dir_name\"" >> "$CATALOG_FILE"
  done

  # Summarize aspect ratios
  echo "  Aspect ratio distribution:"
  tail -n +2 "$CATALOG_FILE" | awk -F',' '{gsub(/"/, "", $4); print $4}' | sort | uniq -c | sort -rn | while read -r count ratio; do
    echo "    $ratio: $count files"
  done
  echo ""
  echo "  Full catalog: $CATALOG_FILE"
  echo ""
fi

# --- Video metadata ---
if command -v ffprobe &>/dev/null && [ "$VIDEO_COUNT" -gt 0 ]; then
  echo "=== Video Files ==="

  VIDEO_CATALOG="$OUTPUT_DIR/video-catalog.csv"
  echo "file,width,height,aspect_ratio,duration_seconds,codec,size_mb,directory" > "$VIDEO_CATALOG"

  find "$FOLDER" -type f \( -iname "*.mp4" -o -iname "*.mov" -o -iname "*.avi" -o -iname "*.webm" \) | sort | while read -r vid; do
    meta=$(ffprobe -v quiet -print_format json -show_format -show_streams "$vid" 2>/dev/null) || continue
    width=$(echo "$meta" | python3 -c "import sys,json; s=[x for x in json.load(sys.stdin)['streams'] if x.get('codec_type')=='video']; print(s[0]['width'] if s else 0)" 2>/dev/null || echo "0")
    height=$(echo "$meta" | python3 -c "import sys,json; s=[x for x in json.load(sys.stdin)['streams'] if x.get('codec_type')=='video']; print(s[0]['height'] if s else 0)" 2>/dev/null || echo "0")
    duration=$(echo "$meta" | python3 -c "import sys,json; print(round(float(json.load(sys.stdin)['format'].get('duration', 0)), 1))" 2>/dev/null || echo "0")
    codec=$(echo "$meta" | python3 -c "import sys,json; s=[x for x in json.load(sys.stdin)['streams'] if x.get('codec_type')=='video']; print(s[0].get('codec_name','unknown') if s else 'unknown')" 2>/dev/null || echo "unknown")
    size_mb=$(python3 -c "import os; print(round(os.path.getsize('$vid')/1048576, 1))" 2>/dev/null || echo "0")
    dir_name="$(dirname "${vid#$FOLDER/}")"

    # Aspect ratio
    if [ "$height" -ne 0 ]; then
      ratio_val=$(python3 -c "print(round($width/$height, 2))" 2>/dev/null || echo "0")
      if python3 -c "exit(0 if abs($ratio_val - 1.0) < 0.05 else 1)" 2>/dev/null; then
        ratio="1:1"
      elif python3 -c "exit(0 if abs($ratio_val - 0.5625) < 0.05 else 1)" 2>/dev/null; then
        ratio="9:16"
      elif python3 -c "exit(0 if abs($ratio_val - 0.8) < 0.05 else 1)" 2>/dev/null; then
        ratio="4:5"
      elif python3 -c "exit(0 if abs($ratio_val - 1.7778) < 0.08 else 1)" 2>/dev/null; then
        ratio="16:9"
      else
        ratio="${width}:${height}"
      fi
    else
      ratio="unknown"
    fi

    echo "\"$(basename "$vid")\",$width,$height,$ratio,${duration}s,$codec,$size_mb,\"$dir_name\"" >> "$VIDEO_CATALOG"
    echo "  $(basename "$vid"): ${width}×${height} ($ratio) ${duration}s ${codec} ${size_mb}MB"
  done

  echo ""
  echo "  Full catalog: $VIDEO_CATALOG"
  echo ""
fi

# --- Audio metadata ---
if command -v ffprobe &>/dev/null && [ "$AUDIO_COUNT" -gt 0 ]; then
  echo "=== Audio Files ==="

  AUDIO_CATALOG="$OUTPUT_DIR/audio-catalog.csv"
  echo "file,duration_seconds,codec,sample_rate,channels,size_mb,directory" > "$AUDIO_CATALOG"

  find "$FOLDER" -type f \( -iname "*.mp3" -o -iname "*.wav" -o -iname "*.aac" -o -iname "*.m4a" -o -iname "*.ogg" -o -iname "*.flac" \) | sort | while read -r aud; do
    meta=$(ffprobe -v quiet -print_format json -show_format -show_streams "$aud" 2>/dev/null) || continue
    duration=$(echo "$meta" | python3 -c "import sys,json; print(round(float(json.load(sys.stdin)['format'].get('duration', 0)), 1))" 2>/dev/null || echo "0")
    codec=$(echo "$meta" | python3 -c "import sys,json; s=[x for x in json.load(sys.stdin)['streams'] if x.get('codec_type')=='audio']; print(s[0].get('codec_name','unknown') if s else 'unknown')" 2>/dev/null || echo "unknown")
    sample_rate=$(echo "$meta" | python3 -c "import sys,json; s=[x for x in json.load(sys.stdin)['streams'] if x.get('codec_type')=='audio']; print(s[0].get('sample_rate','0') if s else '0')" 2>/dev/null || echo "0")
    channels=$(echo "$meta" | python3 -c "import sys,json; s=[x for x in json.load(sys.stdin)['streams'] if x.get('codec_type')=='audio']; print(s[0].get('channels', 0) if s else 0)" 2>/dev/null || echo "0")
    size_mb=$(python3 -c "import os; print(round(os.path.getsize('$aud')/1048576, 1))" 2>/dev/null || echo "0")
    dir_name="$(dirname "${aud#$FOLDER/}")"

    echo "\"$(basename "$aud")\",${duration}s,$codec,$sample_rate,$channels,$size_mb,\"$dir_name\"" >> "$AUDIO_CATALOG"
    echo "  $(basename "$aud"): ${duration}s ${codec} ${sample_rate}Hz ${channels}ch ${size_mb}MB"
  done

  echo ""
  echo "  Full catalog: $AUDIO_CATALOG"
  echo ""
fi

# --- Generate thumbnails for report ---
echo "=== Generating Thumbnails ==="

find "$FOLDER" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | sort | while read -r img; do
  basename_clean=$(basename "$img" | sed 's/[^a-zA-Z0-9._-]/_/g')
  thumb_path="$OUTPUT_DIR/thumbnails/$basename_clean"

  if command -v convert &>/dev/null; then
    convert "$img" -resize 400x400\> -quality 80 "$thumb_path" 2>/dev/null
  else
    # Fallback: just copy (no resize)
    cp "$img" "$thumb_path" 2>/dev/null
  fi
done

# Video thumbnails (first frame)
find "$FOLDER" -type f \( -iname "*.mp4" -o -iname "*.mov" \) | sort | while read -r vid; do
  basename_clean=$(basename "$vid" | sed 's/\.[^.]*$/.jpg/' | sed 's/[^a-zA-Z0-9._-]/_/g')
  thumb_path="$OUTPUT_DIR/thumbnails/$basename_clean"

  if command -v ffmpeg &>/dev/null; then
    ffmpeg -y -i "$vid" -vframes 1 -q:v 5 -vf "scale=400:-1" "$thumb_path" 2>/dev/null
  fi
done

THUMB_TOTAL=$(find "$OUTPUT_DIR/thumbnails" -type f | wc -l | tr -d ' ')
echo "  Generated $THUMB_TOTAL thumbnails in $OUTPUT_DIR/thumbnails/"
echo ""

# --- Summary ---
echo "=== Catalog Complete ==="
echo "  Images: $IMAGE_COUNT"
echo "  Videos: $VIDEO_COUNT"
echo "  Audio:  $AUDIO_COUNT"
echo "  Total:  $TOTAL"
echo "  Output: $OUTPUT_DIR/"
echo ""
echo "Files generated:"
[ -f "$OUTPUT_DIR/image-catalog.csv" ] && echo "  - image-catalog.csv (image dimensions and metadata)"
[ -f "$OUTPUT_DIR/video-catalog.csv" ] && echo "  - video-catalog.csv (video metadata)"
[ -f "$OUTPUT_DIR/audio-catalog.csv" ] && echo "  - audio-catalog.csv (audio metadata)"
echo "  - thumbnails/ ($THUMB_TOTAL thumbnail images for report)"
