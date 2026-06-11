#!/usr/bin/env bash
#
# setup.sh — install the workflow template into a new project.
#
# Copies only what the chosen agent needs (plus the shared files), skipping
# template-repo cruft (.git, LICENSE, README.md, setup.sh itself). Optionally
# fills in {{PROJECT_NAME}} and creates an empty ARCHITECTURE.md.
#
# Usage:
#   ./setup.sh <target-dir> [--claude | --opencode | --both] [--name "Project Name"] [--force]
#
# Examples:
#   ./setup.sh ~/work/my-app --claude
#   ./setup.sh ~/work/my-app --opencode --name "My App"
#   ./setup.sh ../my-app            # prompts for agent + name interactively
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- shared, never-copied, and agent-specific file sets ---------------------
SHARED=(CLAUDE.md docs features)            # used by both Claude Code and opencode
CLAUDE_ONLY=(.claude)                       # Claude Code specific
OPENCODE_ONLY=(.opencode opencode.json)     # opencode specific
# Never copied into a target: .git LICENSE README.md setup.sh

usage() {
  sed -n '3,15p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

die() { printf 'error: %s\n' "$1" >&2; exit 1; }

# Escape a string for safe use on the replacement side of `sed s#...#...#`.
escape_repl() { printf '%s' "$1" | sed -e 's/[\\&#]/\\&/g'; }

# Portable in-place sed (works the same on Linux and macOS).
sed_inplace() {
  local expr="$1" file="$2" tmp
  tmp="$(mktemp)"
  sed "$expr" "$file" >"$tmp" && mv "$tmp" "$file"
}

# --- parse arguments --------------------------------------------------------
TARGET=""
AGENT=""
NAME=""
FORCE=0

while [ $# -gt 0 ]; do
  case "$1" in
    --claude)   AGENT="claude" ;;
    --opencode) AGENT="opencode" ;;
    --both)     AGENT="both" ;;
    --name)     shift; [ $# -gt 0 ] || die "--name requires a value"; NAME="$1" ;;
    --name=*)   NAME="${1#--name=}" ;;
    --force)    FORCE=1 ;;
    -h|--help)  usage 0 ;;
    -*)         die "unknown option: $1 (try --help)" ;;
    *)          [ -z "$TARGET" ] || die "unexpected extra argument: $1"; TARGET="$1" ;;
  esac
  shift
done

[ -n "$TARGET" ] || { printf 'No target directory given.\n\n'; usage 1; }

# --- resolve agent (prompt if not provided) ---------------------------------
if [ -z "$AGENT" ]; then
  printf 'Which agent is this project for?\n'
  printf '  1) Claude Code\n  2) opencode\n  3) both\n'
  printf 'Choice [1/2/3]: '
  read -r choice
  case "$choice" in
    1) AGENT="claude" ;;
    2) AGENT="opencode" ;;
    3) AGENT="both" ;;
    *) die "invalid choice: $choice" ;;
  esac
fi

# --- resolve project name (prompt if not provided) --------------------------
if [ -z "$NAME" ]; then
  printf 'Project name (blank to leave {{PROJECT_NAME}} placeholder): '
  read -r NAME
fi

# --- build the list of items to copy ----------------------------------------
items=("${SHARED[@]}")
case "$AGENT" in
  claude)   items+=("${CLAUDE_ONLY[@]}") ;;
  opencode) items+=("${OPENCODE_ONLY[@]}") ;;
  both)     items+=("${CLAUDE_ONLY[@]}" "${OPENCODE_ONLY[@]}") ;;
esac

# --- guard against clobbering an existing project ---------------------------
if [ -e "$TARGET/CLAUDE.md" ] && [ "$FORCE" -ne 1 ]; then
  die "$TARGET already contains CLAUDE.md — refusing to overwrite (use --force)"
fi

mkdir -p "$TARGET"

# --- copy ------------------------------------------------------------------
printf 'Installing workflow template (%s) into %s\n' "$AGENT" "$TARGET"
for item in "${items[@]}"; do
  src="$SCRIPT_DIR/$item"
  [ -e "$src" ] || { printf '  ! skipping %s (not found in template)\n' "$item"; continue; }
  cp -R "$src" "$TARGET/"
  printf '  + %s\n' "$item"
done

# --- fill in {{PROJECT_NAME}} ----------------------------------------------
if [ -n "$NAME" ] && [ -f "$TARGET/CLAUDE.md" ]; then
  sed_inplace "s#{{PROJECT_NAME}}#$(escape_repl "$NAME")#g" "$TARGET/CLAUDE.md"
  printf '  ~ {{PROJECT_NAME}} -> %s in CLAUDE.md\n' "$NAME"
fi

# --- create an empty ARCHITECTURE.md ---------------------------------------
if [ ! -e "$TARGET/ARCHITECTURE.md" ]; then
  : >"$TARGET/ARCHITECTURE.md"
  printf '  + ARCHITECTURE.md (empty)\n'
fi

# --- next steps -------------------------------------------------------------
cat <<EOF

Done. Next steps:
  1. cd $TARGET
  2. Edit CLAUDE.md — fill in the "About the Project" section.
  3. Fill in ARCHITECTURE.md as the project takes shape.
  4. (Frontend projects) add docs/CorporateDesign.md.
  5. Run /requirements <your-project-idea> in your agent to start Init Mode.
EOF
