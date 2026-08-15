#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

failures=0

pass() {
  printf 'PASS  %s\n' "$1"
}

fail() {
  printf 'FAIL  %s\n' "$1" >&2
  failures=$((failures + 1))
}

required=(
  "README.md"
  "START_HERE.md"
  "AGENTS.md"
  "CHATGPT_PROJECT_INSTRUCTIONS.md"
  "docs/INDEX.md"
  ".codex/config.toml"
  "scripts/bootstrap-project.sh"
  "scripts/install-global.sh"
)

for path in "${required[@]}"; do
  if [[ -f "$path" ]]; then
    pass "required file: $path"
  else
    fail "missing required file: $path"
  fi
done

for script in scripts/*.sh; do
  if bash -n "$script"; then
    pass "bash syntax: $script"
  else
    fail "bash syntax: $script"
  fi
done

if ! command -v python3 >/dev/null 2>&1; then
  fail "python3 is required for structural validation"
else
  if python3 <<'PY'
from __future__ import annotations

import re
import sys
from pathlib import Path

try:
    import tomllib
except ModuleNotFoundError:
    print("Python 3.11+ is required for tomllib", file=sys.stderr)
    raise

root = Path.cwd()
errors: list[str] = []

skill_dirs = sorted((root / ".agents" / "skills").glob("*"))
if not skill_dirs:
    errors.append("no skills found")

skill_name_re = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")

for directory in skill_dirs:
    path = directory / "SKILL.md"
    if not path.is_file():
        errors.append(f"missing {path.relative_to(root)}")
        continue

    text = path.read_text(encoding="utf-8")
    match = re.match(r"\A---\n(.*?)\n---\n", text, flags=re.S)
    if not match:
        errors.append(f"{path.relative_to(root)}: missing YAML frontmatter")
        continue

    frontmatter = match.group(1)
    values: dict[str, str] = {}
    for line in frontmatter.splitlines():
        if ":" in line:
            key, value = line.split(":", 1)
            values[key.strip()] = value.strip()

    name = values.get("name", "")
    description = values.get("description", "")

    if not name:
        errors.append(f"{path.relative_to(root)}: missing name")
    elif not skill_name_re.fullmatch(name):
        errors.append(f"{path.relative_to(root)}: invalid skill name {name!r}")
    elif name != directory.name:
        errors.append(
            f"{path.relative_to(root)}: name {name!r} does not match directory {directory.name!r}"
        )

    if len(description) < 30:
        errors.append(f"{path.relative_to(root)}: description is too vague")

agent_files = sorted((root / ".codex" / "agents").glob("*.toml"))
if not agent_files:
    errors.append("no custom agents found")

agent_names: set[str] = set()
for path in agent_files:
    try:
        data = tomllib.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:
        errors.append(f"{path.relative_to(root)}: invalid TOML: {exc}")
        continue

    for field in ("name", "description", "developer_instructions"):
        value = data.get(field)
        if not isinstance(value, str) or not value.strip():
            errors.append(f"{path.relative_to(root)}: missing {field}")

    name = data.get("name")
    if isinstance(name, str):
        if name in agent_names:
            errors.append(f"{path.relative_to(root)}: duplicate agent name {name}")
        agent_names.add(name)

    if data.get("sandbox_mode") not in {"read-only", "workspace-write"}:
        errors.append(f"{path.relative_to(root)}: set explicit sandbox_mode")

try:
    config = tomllib.loads((root / ".codex" / "config.toml").read_text(encoding="utf-8"))
    agents = config.get("agents", {})
    if agents.get("enabled") is not True:
        errors.append(".codex/config.toml: agents.enabled must be true")
except Exception as exc:
    errors.append(f".codex/config.toml: invalid TOML: {exc}")

metadata_re = re.compile(
    r"^> Status: (DRAFT|IN_REVIEW|APPROVED|SUPERSEDED|ARCHIVED)\s*$",
    flags=re.M,
)
authority_re = re.compile(
    r"^> Authority: (EXPLORATORY|DECISION|CANONICAL|IMPLEMENTATION|REFERENCE)\s*$",
    flags=re.M,
)

for path in sorted((root / "docs").glob("*.md")):
    text = path.read_text(encoding="utf-8")
    if not metadata_re.search(text):
        errors.append(f"{path.relative_to(root)}: missing or invalid Status")
    if not authority_re.search(text):
        errors.append(f"{path.relative_to(root)}: missing or invalid Authority")

relative_link_re = re.compile(r"\[[^\]]+\]\((?!https?://|mailto:|#)([^)]+)\)")
for path in root.rglob("*.md"):
    text = path.read_text(encoding="utf-8")
    for raw_target in relative_link_re.findall(text):
        target = raw_target.split("#", 1)[0]
        if not target:
            continue
        resolved = (path.parent / target).resolve()
        try:
            resolved.relative_to(root.resolve())
        except ValueError:
            errors.append(f"{path.relative_to(root)}: link escapes repository: {raw_target}")
            continue
        if not resolved.exists():
            errors.append(f"{path.relative_to(root)}: broken link: {raw_target}")

secret_patterns = {
    "OpenAI-style key": re.compile(r"\bsk-[A-Za-z0-9_-]{20,}\b"),
    "GitHub token": re.compile(r"\bgh[pousr]_[A-Za-z0-9]{20,}\b"),
    "AWS access key": re.compile(r"\bAKIA[0-9A-Z]{16}\b"),
    "private key": re.compile(r"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----"),
}

for path in root.rglob("*"):
    if not path.is_file() or ".git" in path.parts:
        continue
    try:
        text = path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        continue
    for label, pattern in secret_patterns.items():
        if pattern.search(text):
            errors.append(f"{path.relative_to(root)}: possible {label}")

if errors:
    for error in errors:
        print(error, file=sys.stderr)
    raise SystemExit(1)

print(
    f"validated {len(skill_dirs)} skills, "
    f"{len(agent_files)} agents and documentation metadata"
)
PY
  then
    pass "skills, agents, docs, links and secret patterns"
  else
    fail "skills, agents, docs, links or secret patterns"
  fi
fi

if [[ $failures -gt 0 ]]; then
  echo
  echo "Validation failed: $failures check group(s)." >&2
  exit 1
fi

echo
echo "Validation passed."
