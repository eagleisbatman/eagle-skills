#!/usr/bin/env bash
# Eagle UX Review — Frame Extraction Script
# Extracts frames from video at configurable intervals with metadata
#
# Usage: extract-frames.sh <video_path> [output_dir] [interval_seconds]
# Defaults: output_dir=./ux-review-frames, interval=1

set -euo pipefail

VIDEO_PATH="${1:?Usage: extract-frames.sh <video_path> [output_dir] [interval_seconds]}"
OUTPUT_DIR="${2:-./ux-review-frames}"
INTERVAL="${3:-1}"

# Validate input
if [ ! -f "$VIDEO_PATH" ]; then
  echo "Error: Video file not found: $VIDEO_PATH"
  exit 1
fi

# Check dependencies
for cmd in ffmpeg ffprobe; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: $cmd is required but not installed."
    exit 1
  fi
done

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Extract metadata
echo "=== Video Metadata ==="
METADATA=$(ffprobe -v quiet -print_format json -show_format -show_streams "$VIDEO_PATH")
DURATION=$(echo "$METADATA" | python3 -c "import sys,json; print(f'{float(json.load(sys.stdin)[\"format\"][\"duration\"]):.1f}')")
RESOLUTION=$(echo "$METADATA" | python3 -c "import sys,json; s=[x for x in json.load(sys.stdin)['streams'] if x['codec_type']=='video'][0]; print(f'{s[\"width\"]}x{s[\"height\"]}')")
echo "Duration: ${DURATION}s"
echo "Resolution: ${RESOLUTION}"
echo "Interval: ${INTERVAL}s"

# Save metadata to file
SOURCE_NAME=$(basename "$VIDEO_PATH" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read().strip()))" 2>/dev/null || basename "$VIDEO_PATH" | sed 's/"/\\"/g')
cat > "${OUTPUT_DIR}/metadata.json" <<METAEOF
{
  "source": $SOURCE_NAME,
  "duration_seconds": $DURATION,
  "resolution": "$RESOLUTION",
  "frame_interval_seconds": $INTERVAL,
  "extracted_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
METAEOF

# Extract frames
echo ""
echo "=== Extracting Frames ==="
ffmpeg -y -i "$VIDEO_PATH" \
  -vf "fps=1/${INTERVAL}" \
  -q:v 2 \
  "${OUTPUT_DIR}/frame_%03d.jpg" \
  2>&1 | grep -E "^frame=" | tail -1

FRAME_COUNT=$(ls -1 "${OUTPUT_DIR}"/frame_*.jpg 2>/dev/null | wc -l | tr -d ' ')
echo ""
echo "=== Complete ==="
echo "Extracted ${FRAME_COUNT} frames to ${OUTPUT_DIR}/"
echo "Frame interval: ${INTERVAL}s"
echo "Expected duration coverage: $((FRAME_COUNT * INTERVAL))s of ${DURATION}s"

# Generate frame index
echo ""
echo "=== Frame Index ==="
for f in "${OUTPUT_DIR}"/frame_*.jpg; do
  name=$(basename "$f" .jpg)
  num=$(echo "$name" | sed 's/frame_0*//')
  timestamp=$((num * INTERVAL))
  echo "  ${name}.jpg → ${timestamp}s"
done
