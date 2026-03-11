#!/usr/bin/env bash
# ┌─────────────────────────────────────────────────────────────────┐
# │ claude-safe-bypass installer                                   │
# │ Copies safety config into your project's .claude/ directory.   │
# │                                                                │
# │ Usage:                                                         │
# │   bash install.sh /path/to/your/project                       │
# │   cd your-project && bash /path/to/install.sh                  │
# └─────────────────────────────────────────────────────────────────┘

set -euo pipefail

TARGET="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/template"

if [ ! -d "$SRC" ]; then
  echo "  Error: template/ directory not found." >&2
  echo "  Run this script from the cloned repo." >&2
  exit 1
fi

# ── Install ──────────────────────────────────────────────────────

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
