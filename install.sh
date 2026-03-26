#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────
# Eagle Skills — Quick installer
# curl -fsSL https://raw.githubusercontent.com/eagleisbatman/eagle-skills/main/install.sh | bash
# ─────────────────────────────────────────────────────────────

REPO_URL="https://github.com/eagleisbatman/eagle-skills.git"
INSTALL_DIR="${EAGLE_SKILLS_DIR:-$HOME/.eagle-skills}"

echo ""
echo "  Eagle Skills — installer"
echo ""

# Check git
if ! command -v git &>/dev/null; then
  echo "  Error: git is required but not installed."
  exit 1
fi

# Clone or update
if [ -d "$INSTALL_DIR/.git" ]; then
  echo "  Updating existing installation..."
  git -C "$INSTALL_DIR" pull --quiet
else
  echo "  Cloning to $INSTALL_DIR..."
  git clone --quiet "$REPO_URL" "$INSTALL_DIR"
fi

# Run the full CLI installer
exec "$INSTALL_DIR/bin/eagle-skills" install
