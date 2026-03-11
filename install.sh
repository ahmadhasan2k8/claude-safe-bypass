#!/usr/bin/env bash
# ┌─────────────────────────────────────────────────────────────────────────────┐
# │ claude-safe-bypass installer                                               │
# │ Copies safety config into your project's .claude/ directory.               │
# │                                                                            │
# │ Usage:                                                                     │
# │   curl -fsSL https://raw.githubusercontent.com/ahmadhasan2k8/claude-safe-bypass/main/install.sh | bash │
# │   bash install.sh [target-dir]                                             │
# └─────────────────────────────────────────────────────────────────────────────┘

set -euo pipefail

TARGET="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Detect source: local clone vs. curl pipe ─────────────────────────────────

if [ -d "$SCRIPT_DIR/template" ]; then
  SRC="$SCRIPT_DIR/template"
else
  # Running via curl pipe — download template files
  REPO="https://raw.githubusercontent.com/ahmadhasan2k8/claude-safe-bypass/main/template"
  TMP=$(mktemp -d)
  SRC="$TMP"
  trap 'rm -rf "$TMP"' EXIT

  mkdir -p "$SRC/.claude/hooks"
  curl -fsSL "$REPO/.claude/settings.json"              -o "$SRC/.claude/settings.json"
  curl -fsSL "$REPO/.claude/hooks/block-dangerous.sh"   -o "$SRC/.claude/hooks/block-dangerous.sh"
  curl -fsSL "$REPO/CLAUDE.md"                          -o "$SRC/CLAUDE.md"
fi

# ── Install ──────────────────────────────────────────────────────────────────

mkdir -p "$TARGET/.claude/hooks"

cp "$SRC/.claude/settings.json"            "$TARGET/.claude/settings.json"
cp "$SRC/.claude/hooks/block-dangerous.sh" "$TARGET/.claude/hooks/block-dangerous.sh"
chmod +x "$TARGET/.claude/hooks/block-dangerous.sh"

if [ -f "$TARGET/CLAUDE.md" ]; then
  printf '\n' >> "$TARGET/CLAUDE.md"
  cat "$SRC/CLAUDE.md" >> "$TARGET/CLAUDE.md"
  echo "  Appended safety rules to existing CLAUDE.md"
else
  cp "$SRC/CLAUDE.md" "$TARGET/CLAUDE.md"
  echo "  Created CLAUDE.md with safety rules"
fi

echo ""
echo "  claude-safe-bypass installed into $(cd "$TARGET" && pwd)"
echo ""
echo "  Files added:"
echo "    .claude/settings.json              — deny rules + hook config"
echo "    .claude/hooks/block-dangerous.sh   — PreToolUse safety hook"
echo "    CLAUDE.md                          — safety instructions for Claude"
echo ""
echo "  You can now use: claude --dangerously-skip-permissions"
echo "  The hook will still block destructive commands."
echo ""
