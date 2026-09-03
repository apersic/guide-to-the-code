#!/usr/bin/env bash
# Rename pstack/astack poteto-mode to <handle>-mode (default: nax).
# Usage: ./scripts/rename-poteto-handle.sh [--dry-run] [handle]
# ROOT is the directory containing skills/ and agents/ (scripts/..).
# Skips LICENSE. Restores README https://x.com/poteto bio link after rewrite.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SCRIPT_PATH="${SCRIPT_DIR}/$(basename "${BASH_SOURCE[0]}")"

DRY_RUN=0
HANDLE=nax
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    *) HANDLE="$arg" ;;
  esac
done

if ! [[ "$HANDLE" =~ ^[a-z][a-z0-9-]*$ ]]; then
  echo "handle must be a lowercase slug matching [a-z][a-z0-9-]* (got: ${HANDLE})" >&2
  exit 1
fi

if [[ ! -d "${ROOT}/skills" || ! -d "${ROOT}/agents" ]]; then
  echo "ROOT must contain skills/ and agents/ (resolved: ${ROOT})" >&2
  exit 1
fi

first="${HANDLE%%-*}"
HANDLE_TITLE="$(printf '%s' "$(printf '%s' "$first" | cut -c1 | tr '[:lower:]' '[:upper:]')$(printf '%s' "$first" | cut -c2-)")"

SRC_MODE="${ROOT}/skills/poteto-mode"
DST_MODE="${ROOT}/skills/${HANDLE}-mode"
SRC_AGENT="${ROOT}/agents/poteto-agent.md"
DST_AGENT="${ROOT}/agents/${HANDLE}-agent.md"
SRC_DOC="${ROOT}/docs/guide/02-poteto-mode.md"
DST_DOC="${ROOT}/docs/guide/02-${HANDLE}-mode.md"

if [[ ! -d "$SRC_MODE" ]]; then
  if [[ -d "$DST_MODE" ]]; then
    echo "already renamed to ${HANDLE}-mode; nothing to do"
    exit 0
  fi
  echo "skills/poteto-mode is missing under ${ROOT}" >&2
  exit 1
fi

if [[ -e "$DST_MODE" ]]; then
  echo "skills/${HANDLE}-mode already exists; refusing to overwrite" >&2
  exit 1
fi

if [[ -e "${ROOT}/.git" ]]; then
  MV_PRINT="git mv"
else
  MV_PRINT="mv"
fi

rel() {
  printf '%s\n' "${1#"${ROOT}/"}"
}

run_mv() {
  local from="$1" to="$2"
  echo "${MV_PRINT} $(rel "$from") $(rel "$to")"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    return 0
  fi
  if [[ -e "${ROOT}/.git" ]]; then
    git -C "$ROOT" mv "$(rel "$from")" "$(rel "$to")"
  else
    mv "$from" "$to"
  fi
}

sed_inplace() {
  local file="$1"
  shift
  sed -i.bak "$@" "$file"
  rm -f "${file}.bak"
}

rewrite_file() {
  local f="$1"
  sed_inplace "$f" \
    -e "s/Poteto Mode/${HANDLE_TITLE} Mode/g" \
    -e "s/Poteto subagent/${HANDLE_TITLE} subagent/g" \
    -e "s/poteto-mode-tools/${HANDLE}-mode-tools/g" \
    -e "s/poteto-mode/${HANDLE}-mode/g" \
    -e "s/poteto-agent/${HANDLE}-agent/g" \
    -e "s/poteto's/${HANDLE}'s/g" \
    -e "s/Poteto/${HANDLE_TITLE}/g" \
    -e "s/poteto/${HANDLE}/g"
}

list_text_files() {
  find "$ROOT" \
    \( -name .git -o -name node_modules \) -prune -o \
    -type f \( \
      -name '*.md' -o -name '*.json' -o -name '*.ts' -o \
      -name '*.mjs' -o -name '*.js' -o -name '*.yml' -o \
      -name '*.yaml' -o -name '*.toml' -o -name '*.lock' -o \
      -name '*.txt' \
    \) ! -name LICENSE -print
}

protect_readme() {
  local f="${ROOT}/README.md"
  [[ -f "$f" ]] || return 0
  if grep -q 'https://x.com/poteto' "$f"; then
    sed_inplace "$f" \
      -e 's|\[poteto\](https://x.com/poteto)|__POTETO_HANDLE_LINK__|g' \
      -e 's|https://x.com/poteto|__POTETO_TWITTER_URL__|g'
  fi
}

restore_readme() {
  local f="${ROOT}/README.md"
  [[ -f "$f" ]] || return 0
  sed_inplace "$f" \
    -e 's|__POTETO_HANDLE_LINK__|[poteto](https://x.com/poteto)|g' \
    -e 's|__POTETO_TWITTER_URL__|https://x.com/poteto|g'
}

run_mv "$SRC_MODE" "$DST_MODE"
run_mv "$SRC_AGENT" "$DST_AGENT"
if [[ -f "$SRC_DOC" ]]; then
  run_mv "$SRC_DOC" "$DST_DOC"
fi

edited=0
while IFS= read -r f; do
  [[ "$f" == "$SCRIPT_PATH" ]] && continue
  [[ "$(basename "$f")" == "LICENSE" ]] && continue
  if ! grep -a -q -i -e poteto "$f"; then
    continue
  fi
  count="$(grep -a -c -i -e poteto "$f" || true)"
  echo "$(rel "$f") (${count})"
  edited=$((edited + 1))
  if [[ "$DRY_RUN" -eq 0 ]]; then
    if [[ "$f" == "${ROOT}/README.md" ]]; then
      protect_readme
    fi
    rewrite_file "$f"
    if [[ "$f" == "${ROOT}/README.md" ]]; then
      restore_readme
    fi
  fi
done < <(list_text_files)

echo "files to edit: ${edited}"

if [[ "$DRY_RUN" -eq 1 ]]; then
  exit 0
fi

if command -v rg >/dev/null 2>&1; then
  (cd "$ROOT" && rg -n 'poteto' --glob '!LICENSE' --glob '!.git/**' --glob '!node_modules/**' --glob '!scripts/rename-poteto-handle.sh') || true
else
  grep -R -n -I --exclude-dir=.git --exclude-dir=node_modules --exclude=LICENSE --exclude=rename-poteto-handle.sh -e poteto "$ROOT" || true
fi
