#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────
# Eagle Skills — CLI installer, updater, and manager
# https://github.com/eagleisbatman/eagle-skills
# ─────────────────────────────────────────────────────────────

VERSION="1.0.0"
REPO_URL="https://github.com/eagleisbatman/eagle-skills.git"
INSTALL_DIR="${EAGLE_SKILLS_DIR:-$HOME/.eagle-skills}"
SKILLS_DIR="$HOME/.claude/skills"

# Available skills (directory name → display name)
declare -a SKILL_DIRS=("eagle-ux-review" "eagle-product-diagnostics" "eagle-ad-review")
declare -a SKILL_NAMES=("Eagle UX Review" "Eagle Product Diagnostics" "Eagle Ad Review")
declare -a SKILL_DESCS=(
  "Expert-level UX audits grounded in 65+ UX laws"
  "Three-layer data validation: design intent + behavior + outcomes"
  "Strategy-first ad creative review across any medium"
)

# ─── Colors ──────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ─── Helpers ─────────────────────────────────────────────────
info()    { echo -e "${BLUE}info${RESET}  $1"; }
ok()      { echo -e "${GREEN}  ok${RESET}  $1"; }
warn()    { echo -e "${YELLOW}warn${RESET}  $1"; }
err()     { echo -e "${RED} err${RESET}  $1"; }
header()  { echo -e "\n${BOLD}${MAGENTA}$1${RESET}\n"; }

check_git() {
  if ! command -v git &>/dev/null; then
    err "git is required but not installed."
    exit 1
  fi
}

check_claude_code() {
  if [ ! -d "$HOME/.claude" ]; then
    warn "~/.claude directory not found. Is Claude Code installed?"
    echo -e "  ${DIM}Install: https://docs.anthropic.com/en/docs/claude-code${RESET}"
    read -rp "  Continue anyway? [y/N] " answer
    [[ "$answer" =~ ^[Yy]$ ]] || exit 0
  fi
}

ensure_skills_dir() {
  mkdir -p "$SKILLS_DIR"
}

# ─── Skill selection menu ────────────────────────────────────
select_skills() {
  local -a selected=()

  header "Eagle Skills"
  echo -e "  ${DIM}Custom skills for Claude Code${RESET}"
  echo ""

  echo -e "  ${BOLD}Available skills:${RESET}"
  echo ""
  for i in "${!SKILL_DIRS[@]}"; do
    local num=$((i + 1))
    echo -e "    ${CYAN}${num}${RESET}  ${BOLD}${SKILL_NAMES[$i]}${RESET}"
    echo -e "       ${DIM}${SKILL_DESCS[$i]}${RESET}"
    echo ""
  done

  echo -e "    ${CYAN}a${RESET}  ${BOLD}All skills${RESET}"
  echo ""

  read -rp "  Select skills to install (e.g. 1,3 or a for all): " choice

  if [[ "$choice" =~ ^[Aa]$ ]]; then
    selected=("${SKILL_DIRS[@]}")
  else
    IFS=',' read -ra nums <<< "$choice"
    for num in "${nums[@]}"; do
      num=$(echo "$num" | tr -d ' ')
      if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#SKILL_DIRS[@]}" ]; then
        selected+=("${SKILL_DIRS[$((num - 1))]}")
      else
        warn "Skipping invalid selection: $num"
      fi
    done
  fi

  if [ ${#selected[@]} -eq 0 ]; then
    err "No skills selected."
    exit 1
  fi

  SELECTED_SKILLS=("${selected[@]}")
}

# ─── Commands ────────────────────────────────────────────────

cmd_install() {
  check_git
  check_claude_code
  ensure_skills_dir

  select_skills

  echo ""

  # Clone or update the repo
  if [ -d "$INSTALL_DIR/.git" ]; then
    info "Updating existing clone at $INSTALL_DIR"
    git -C "$INSTALL_DIR" pull --quiet
    ok "Repository updated"
  else
    info "Cloning eagle-skills to $INSTALL_DIR"
    git clone --quiet "$REPO_URL" "$INSTALL_DIR"
    ok "Repository cloned"
  fi

  # Symlink selected skills
  local count=0
  for skill in "${SELECTED_SKILLS[@]}"; do
    local src="$INSTALL_DIR/$skill"
    local dst="$SKILLS_DIR/$skill"

    if [ ! -d "$src" ]; then
      warn "Skill directory not found: $src (skipping)"
      continue
    fi

    # Remove existing (symlink or directory)
    if [ -L "$dst" ]; then
      rm "$dst"
    elif [ -d "$dst" ]; then
      warn "$dst exists and is not a symlink. Overwrite? [y/N]"
      read -rp "  " answer
      if [[ "$answer" =~ ^[Yy]$ ]]; then
        rm -rf "$dst"
      else
        warn "Skipping $skill"
        continue
      fi
    fi

    ln -sf "$src" "$dst"
    ok "Installed ${BOLD}$(skill_display_name "$skill")${RESET}"
    count=$((count + 1))
  done

  echo ""
  if [ "$count" -gt 0 ]; then
    echo -e "  ${GREEN}${BOLD}$count skill(s) installed.${RESET}"
    echo -e "  ${DIM}Skills are symlinked — run ${RESET}eagle-skills update${DIM} to get the latest.${RESET}"
  else
    warn "No skills were installed."
  fi
  echo ""
}

cmd_update() {
  if [ ! -d "$INSTALL_DIR/.git" ]; then
    err "Eagle Skills not found at $INSTALL_DIR"
    echo -e "  ${DIM}Run ${RESET}eagle-skills install${DIM} first.${RESET}"
    exit 1
  fi

  header "Updating Eagle Skills"

  local before
  before=$(git -C "$INSTALL_DIR" rev-parse HEAD)
  git -C "$INSTALL_DIR" pull --quiet
  local after
  after=$(git -C "$INSTALL_DIR" rev-parse HEAD)

  if [ "$before" = "$after" ]; then
    ok "Already up to date."
  else
    local changes
    changes=$(git -C "$INSTALL_DIR" log --oneline "$before..$after" | wc -l | tr -d ' ')
    ok "Updated ($changes new commit(s))"
    echo ""
    echo -e "  ${DIM}Recent changes:${RESET}"
    git -C "$INSTALL_DIR" log --oneline "$before..$after" | head -10 | while read -r line; do
      echo -e "    ${DIM}$line${RESET}"
    done
  fi

  # Verify symlinks still work
  echo ""
  local broken=0
  for skill in "${SKILL_DIRS[@]}"; do
    local dst="$SKILLS_DIR/$skill"
    if [ -L "$dst" ]; then
      if [ -d "$dst" ]; then
        ok "$skill"
      else
        err "$skill — broken symlink"
        broken=$((broken + 1))
      fi
    fi
  done

  if [ "$broken" -gt 0 ]; then
    warn "$broken broken symlink(s). Run ${RESET}eagle-skills install${DIM} to fix.${RESET}"
  fi
  echo ""
}

cmd_status() {
  header "Eagle Skills — Status"

  # Check install directory
  if [ -d "$INSTALL_DIR/.git" ]; then
    local commit
    commit=$(git -C "$INSTALL_DIR" log --oneline -1)
    ok "Repo: $INSTALL_DIR"
    echo -e "     ${DIM}$commit${RESET}"

    # Check for updates
    git -C "$INSTALL_DIR" fetch --quiet 2>/dev/null || true
    local local_rev remote_rev
    local_rev=$(git -C "$INSTALL_DIR" rev-parse HEAD)
    remote_rev=$(git -C "$INSTALL_DIR" rev-parse '@{u}' 2>/dev/null || echo "$local_rev")
    if [ "$local_rev" != "$remote_rev" ]; then
      local behind
      behind=$(git -C "$INSTALL_DIR" rev-list --count HEAD..'@{u}' 2>/dev/null || echo "?")
      warn "Update available ($behind commit(s) behind)"
    fi
  else
    warn "Not installed. Run: eagle-skills install"
    return
  fi

  echo ""

  # Check each skill
  echo -e "  ${BOLD}Installed skills:${RESET}"
  echo ""
  local installed=0
  for i in "${!SKILL_DIRS[@]}"; do
    local skill="${SKILL_DIRS[$i]}"
    local dst="$SKILLS_DIR/$skill"
    if [ -L "$dst" ] && [ -d "$dst" ]; then
      echo -e "    ${GREEN}*${RESET} ${BOLD}${SKILL_NAMES[$i]}${RESET}"
      echo -e "      ${DIM}$dst -> $(readlink "$dst")${RESET}"
      installed=$((installed + 1))
    elif [ -L "$dst" ]; then
      echo -e "    ${RED}!${RESET} ${BOLD}${SKILL_NAMES[$i]}${RESET} ${RED}(broken symlink)${RESET}"
    elif [ -d "$dst" ]; then
      echo -e "    ${YELLOW}~${RESET} ${BOLD}${SKILL_NAMES[$i]}${RESET} ${YELLOW}(copied, not symlinked)${RESET}"
      installed=$((installed + 1))
    else
      echo -e "    ${DIM}-${RESET} ${DIM}${SKILL_NAMES[$i]}${RESET} ${DIM}(not installed)${RESET}"
    fi
  done
  echo ""
  echo -e "  ${DIM}$installed of ${#SKILL_DIRS[@]} skills installed${RESET}"
  echo ""
}

cmd_uninstall() {
  header "Uninstall Eagle Skills"

  local removed=0

  for i in "${!SKILL_DIRS[@]}"; do
    local skill="${SKILL_DIRS[$i]}"
    local dst="$SKILLS_DIR/$skill"
    if [ -L "$dst" ]; then
      rm "$dst"
      ok "Removed ${SKILL_NAMES[$i]}"
      removed=$((removed + 1))
    elif [ -d "$dst" ]; then
      read -rp "  Remove ${SKILL_NAMES[$i]} (not a symlink — will delete)? [y/N] " answer
      if [[ "$answer" =~ ^[Yy]$ ]]; then
        rm -rf "$dst"
        ok "Removed ${SKILL_NAMES[$i]}"
        removed=$((removed + 1))
      fi
    fi
  done

  if [ "$removed" -eq 0 ]; then
    info "No skills were installed."
  else
    ok "$removed skill(s) removed."
  fi

  # Optionally remove the clone
  if [ -d "$INSTALL_DIR" ]; then
    echo ""
    read -rp "  Also remove the cloned repo at $INSTALL_DIR? [y/N] " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
      rm -rf "$INSTALL_DIR"
      ok "Repo removed."
    fi
  fi
  echo ""
}

skill_display_name() {
  local dir="$1"
  for i in "${!SKILL_DIRS[@]}"; do
    if [ "${SKILL_DIRS[$i]}" = "$dir" ]; then
      echo "${SKILL_NAMES[$i]}"
      return
    fi
  done
  echo "$dir"
}

cmd_help() {
  echo ""
  echo -e "${BOLD}Eagle Skills${RESET} v${VERSION}"
  echo -e "${DIM}Custom skills for Claude Code${RESET}"
  echo ""
  echo -e "${BOLD}Usage:${RESET}"
  echo "  eagle-skills <command>"
  echo ""
  echo -e "${BOLD}Commands:${RESET}"
  echo "  install     Select and install skills for Claude Code"
  echo "  update      Pull latest changes (symlinked skills update automatically)"
  echo "  status      Show installed skills and check for updates"
  echo "  uninstall   Remove installed skills"
  echo "  help        Show this help message"
  echo ""
  echo -e "${BOLD}Quick start:${RESET}"
  echo "  npx eagle-skills install"
  echo ""
  echo -e "${BOLD}Alternative (without npm):${RESET}"
  echo "  curl -fsSL https://raw.githubusercontent.com/eagleisbatman/eagle-skills/main/install.sh | bash"
  echo ""
}

# ─── Main ────────────────────────────────────────────────────
main() {
  local cmd="${1:-help}"

  case "$cmd" in
    install)   cmd_install ;;
    update)    cmd_update ;;
    status)    cmd_status ;;
    uninstall) cmd_uninstall ;;
    help|--help|-h) cmd_help ;;
    version|--version|-v) echo "eagle-skills v${VERSION}" ;;
    *)
      err "Unknown command: $cmd"
      cmd_help
      exit 1
      ;;
  esac
}

main "$@"
