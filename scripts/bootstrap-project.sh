#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat <<'EOF'
Usage:
  bash scripts/bootstrap-project.sh <target-project> [--force]

Copies the vibe-coding kit into an existing project.
Existing files are preserved unless --force is supplied.
EOF
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage
  exit 2
fi

TARGET="$1"
FORCE="${2:-}"

if [[ "$FORCE" != "" && "$FORCE" != "--force" ]]; then
  usage
  exit 2
fi

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"

if [[ "$TARGET" == "$SOURCE_ROOT" ]]; then
  echo "Target is the kit repository itself. Nothing to bootstrap." >&2
  exit 1
fi

copied=0
skipped=0

copy_file() {
  local source="$1"
  local destination="$2"

  mkdir -p "$(dirname "$destination")"

  if [[ -e "$destination" && "$FORCE" != "--force" ]]; then
    printf 'skip  %s\n' "${destination#"$TARGET"/}"
    skipped=$((skipped + 1))
    return
  fi

  cp "$source" "$destination"
  printf 'copy  %s\n' "${destination#"$TARGET"/}"
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

copy_file "$SOURCE_ROOT/AGENTS.md" "$TARGET/AGENTS.md"
copy_file "$SOURCE_ROOT/CHATGPT_PROJECT_INSTRUCTIONS.md" "$TARGET/CHATGPT_PROJECT_INSTRUCTIONS.md"
copy_tree "$SOURCE_ROOT/.agents/skills" "$TARGET/.agents/skills"
copy_tree "$SOURCE_ROOT/.codex/agents" "$TARGET/.codex/agents"
copy_file "$SOURCE_ROOT/.codex/config.toml" "$TARGET/.codex/config.toml"
copy_tree "$SOURCE_ROOT/docs" "$TARGET/docs"
copy_tree "$SOURCE_ROOT/templates" "$TARGET/templates/vibe-kit"
copy_file "$SOURCE_ROOT/.github/pull_request_template.md" "$TARGET/.github/pull_request_template.md"

copy_file "$SOURCE_ROOT/templates/PROJECT_BRIEF.md" "$TARGET/docs/project/PROJECT_BRIEF.md"
copy_file "$SOURCE_ROOT/templates/CURRENT_STATE.md" "$TARGET/docs/project/CURRENT_STATE.md"
copy_file "$SOURCE_ROOT/templates/DECISION_LOG.md" "$TARGET/docs/project/DECISION_LOG.md"

if [[ ! -e "$TARGET/docs/project/TASKS.md" || "$FORCE" == "--force" ]]; then
  cat > "$TARGET/docs/project/TASKS.md" <<'EOF'
# Tasks

> Status: APPROVED
> Authority: CANONICAL
> Last reviewed: YYYY-MM-DD

## Now

- [ ] Define one observable vertical slice.

## Next

- [ ]

## Later

- [ ]

## Blocked

- [ ]
EOF
  printf 'copy  %s\n' "docs/project/TASKS.md"
  copied=$((copied + 1))
else
  printf 'skip  %s\n' "docs/project/TASKS.md"
  skipped=$((skipped + 1))
fi

echo
echo "Bootstrap complete: $copied copied, $skipped preserved."
echo "Next:"
echo "  1. Fill docs/project/PROJECT_BRIEF.md"
echo "  2. Update docs/project/CURRENT_STATE.md"
echo "  3. Start Codex from the target repository"
