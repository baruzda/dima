#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat <<'EOF'
Usage:
  bash scripts/install-global.sh [--force]

Installs:
  skills  -> ~/.agents/skills/
  agents  -> ~/.codex/agents/
  rules   -> ~/.codex/AGENTS.md

The script does not overwrite ~/.codex/config.toml.
EOF
}

FORCE="${1:-}"
if [[ $# -gt 1 || ( "$FORCE" != "" && "$FORCE" != "--force" ) ]]; then
  usage
  exit 2
fi

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CODEX_HOME="${CODEX_HOME:-"$HOME/.codex"}"
AGENTS_HOME="${AGENTS_HOME:-"$HOME/.agents"}"

mkdir -p "$CODEX_HOME/agents" "$AGENTS_HOME/skills"

copied=0
skipped=0

copy_file() {
  local source="$1"
  local destination="$2"

  mkdir -p "$(dirname "$destination")"

  if [[ -e "$destination" && "$FORCE" != "--force" ]]; then
    printf 'skip  %s\n' "$destination"
    skipped=$((skipped + 1))
    return
  fi

  cp "$source" "$destination"
  printf 'copy  %s\n' "$destination"
  copied=$((copied + 1))
}

copy_tree() {
  local source_dir="$1"
  local destination_dir="$2"
  local file rel

  while IFS= read -r -d '' file; do
    rel="${file#"$source_dir"/}"
    copy_file "$file" "$destination_dir/$rel"
  done < <(find "$source_dir" -type f -print0 | sort -z)
}

copy_tree "$SOURCE_ROOT/.agents/skills" "$AGENTS_HOME/skills"
copy_tree "$SOURCE_ROOT/.codex/agents" "$CODEX_HOME/agents"
copy_file "$SOURCE_ROOT/AGENTS.md" "$CODEX_HOME/AGENTS.md"

echo
echo "Global install complete: $copied copied, $skipped preserved."
echo
echo "Optional Codex config values from this kit:"
cat "$SOURCE_ROOT/.codex/config.toml"
echo
echo "Merge them into $CODEX_HOME/config.toml manually if needed."
echo "Avoid keeping identical skills both globally and in one project."
