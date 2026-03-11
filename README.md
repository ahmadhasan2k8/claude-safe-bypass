# claude-safe-bypass

Safety guardrails for Claude Code's `--dangerously-skip-permissions` mode.

Use bypass mode for speed without worrying about catastrophic mistakes. This project adds a **PreToolUse hook** that blocks destructive commands before they execute — even with all permissions bypassed.

## What it blocks

| Category | Examples |
|----------|----------|
| **Destructive files** | `rm -rf`, `shred`, `mkfs` |
| **Privilege escalation** | `sudo` |
| **Git disasters** | `push --force`, `reset --hard`, `clean -f`, push to `main`/`master` |
| **Bad permissions** | `chmod 777`, `chown root` |
| **Database drops** | `DROP TABLE`, `TRUNCATE`, `DELETE` without `WHERE` |
| **System killers** | `killall`, `shutdown`, `reboot`, `kill -9 -1` |
| **Sensitive files** | Edits to `.env`, `.pem`, `.key`, `credentials`, `secrets` |

Network blocking (`curl`, `wget`) is included but **commented out** — uncomment in the hook if you want it.

## Install

### One-liner (copy into any project)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ahmadhasan2k8/claude-safe-bypass/main/install.sh)
```

### From a local clone

```bash
git clone https://github.com/ahmadhasan2k8/claude-safe-bypass.git
cd claude-safe-bypass
bash install.sh /path/to/your/project
```

### Manual

Copy these into your project:

```
your-project/
├── .claude/
│   ├── settings.json              # deny rules + hook config
│   └── hooks/
│       └── block-dangerous.sh     # PreToolUse safety hook (chmod +x)
└── CLAUDE.md                      # safety instructions for Claude
```

## How it works

Three layers of defense:

```
┌─────────────────────────────────────────────────────┐
│  Layer 1: PreToolUse Hook (block-dangerous.sh)      │
│  Enforced — runs before every tool call.            │
│  Blocks via exit code 2, cannot be overridden       │
│  by Claude.                                         │
├─────────────────────────────────────────────────────┤
│  Layer 2: Deny Rules (settings.json)                │
│  Enforced — glob-pattern blocklist applied by       │
│  Claude Code itself.                                │
├─────────────────────────────────────────────────────┤
│  Layer 3: CLAUDE.md Instructions                    │
│  Advisory — natural language rules Claude follows.  │
│  Soft guardrail, not enforced by the system.        │
└─────────────────────────────────────────────────────┘
```

**Hooks are the key.** Even with `--dangerously-skip-permissions`, PreToolUse hooks still execute and can block any action. The hook receives JSON on stdin with the tool name and input, and exits `2` to block or `0` to allow.

## Customizing

### Enable network blocking

Edit `.claude/hooks/block-dangerous.sh` and uncomment the curl/wget section:

```bash
# ── Optional: uncomment to block outbound network ──────────────────────
echo "$COMMAND" | grep -qE '(^|\||\;|&&)\s*(curl|wget|nc|netcat)\b' \
  && ! echo "$COMMAND" | grep -qE '(localhost|127\.0\.0\.1)' \
  && block "External network access"
```

### Add your own rules

Add patterns to the hook script following the same format:

```bash
echo "$COMMAND" | grep -qE 'your-pattern-here' \
  && block "Reason for blocking"
```

Or add glob patterns to `settings.json`:

```json
{
  "permissions": {
    "deny": [
      "Bash(your-pattern *)"
    ]
  }
}
```

### Project-specific overrides

Each project gets its own copy of the files — edit them freely per project. Common tweaks:

- **API projects**: uncomment network blocking, allowlist specific domains
- **Monorepos**: restrict `Edit`/`Write` to specific subdirectories
- **CI/CD**: add stricter rules, remove the optional sections

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- `jq` (used by the hook script to parse tool input)
- `bash` 4+

## FAQ

**Does this work with `--dangerously-skip-permissions`?**
Yes. That's the entire point. Hooks execute regardless of permission mode.

**Can Claude bypass the hook?**
No. Hooks are executed by the Claude Code runtime, not by Claude itself. Claude cannot modify or skip them during a session.

**What happens when something is blocked?**
Claude sees the block message and adapts — it will try a safer alternative or ask you what to do.

**Will this slow things down?**
Negligibly. The hook runs `grep` on a string — it takes milliseconds.

## License

MIT
