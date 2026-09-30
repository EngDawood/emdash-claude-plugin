#!/usr/bin/env bash
#
# Syncs skills from the emdash-cms/emdash repository into this plugin.
#
# Every skill in the config's "sync" array is fully mirrored: the local
# directory is deleted and replaced with the upstream copy. Skills not in
# the list (excluded or local-only) are left untouched.
#
# Usage:
#   scripts/sync-skills.sh \
#     --config .github/skills-sync.json \
#     --upstream <path to the upstream skills/ dir> \
#     --dest <path to this repo's skills/ dir> \
#     --state <path to state json> \
#     [--sha <upstream commit sha>]   # default: git rev-parse of the checkout
#     [--force]                       # sync even if the sha matches state
#
# The state file records the last synced upstream commit; when the current
# upstream sha matches it, the script exits early without touching anything.
#
# Exit codes:
#   0  success (the working tree may now contain skill updates to commit)
#   1  configuration, missing-skill, or validation error

set -euo pipefail

CONFIG=""
UPSTREAM=""
DEST=""
STATE=""
SHA=""
FORCE="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --config)   CONFIG="$2";   shift 2 ;;
    --upstream) UPSTREAM="$2"; shift 2 ;;
    --dest)     DEST="$2";     shift 2 ;;
    --state)    STATE="$2";    shift 2 ;;
    --sha)      SHA="$2";      shift 2 ;;
    --force)    FORCE="true";  shift ;;
    -h|--help)  sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "error: unknown argument: $1" >&2; exit 1 ;;
  esac
done

for req in CONFIG UPSTREAM DEST STATE; do
  [[ -n "${!req}" ]] || {
    echo "error: missing required argument --$(echo "$req" | tr '[:upper:]' '[:lower:]')" >&2
    exit 1
  }
done

[[ -f "$CONFIG" ]]     || { echo "error: config not found: $CONFIG" >&2; exit 1; }
[[ -d "$UPSTREAM" ]]   || { echo "error: upstream skills dir not found: $UPSTREAM" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "error: jq is required" >&2; exit 1; }

UPSTREAM_REPO="$(jq -r '.upstream.repo' "$CONFIG")"
UPSTREAM_BRANCH="$(jq -r '.upstream.branch // "main"' "$CONFIG")"
mapfile -t SYNC_SKILLS < <(jq -r '.sync[]' "$CONFIG")
mapfile -t EXCLUDED    < <(jq -r '(.excluded // {}) | keys[]' "$CONFIG")

[[ ${#SYNC_SKILLS[@]} -gt 0 ]] || { echo "error: config lists no skills to sync" >&2; exit 1; }

if [[ -z "$SHA" ]]; then
  SHA="$(git -C "$UPSTREAM" rev-parse HEAD 2>/dev/null || echo "unknown")"
fi

echo "Upstream : $UPSTREAM_REPO ($UPSTREAM_BRANCH @ ${SHA:0:7})"
echo "Local    : $DEST"
echo "Syncing  : ${SYNC_SKILLS[*]}"
echo "Excluded : ${EXCLUDED[*]:-<none>}"
echo

# --- Early exit when upstream is unchanged ---------------------------------
if [[ "$FORCE" != "true" && -f "$STATE" ]]; then
  LAST_SHA="$(jq -r '.upstreamSha // empty' "$STATE" 2>/dev/null || true)"
  if [[ "$LAST_SHA" == "$SHA" ]]; then
    echo "Upstream unchanged since last sync (${LAST_SHA:0:7}). Nothing to do."
    exit 0
  fi
fi

# --- Warn about upstream skills not covered by the config ------------------
for d in "$UPSTREAM"/*/; do
  [[ -d "$d" ]] || continue
  name="$(basename "$d")"
  if [[ " ${SYNC_SKILLS[*]} " != *" $name "* && " ${EXCLUDED[*]:-} " != *" $name "* ]]; then
    echo "note: upstream skill '$name' is neither in sync nor excluded — add it to $CONFIG"
  fi
done

# --- Mirror each synced skill -----------------------------------------------
CHANGED=()
for skill in "${SYNC_SKILLS[@]}"; do
  src="$UPSTREAM/$skill"
  local_dir="$DEST/$skill"

  if [[ ! -d "$src" ]]; then
    echo "error: skill '$skill' is in the sync list but not found at $src" >&2
    exit 1
  fi

  if [[ -d "$local_dir" ]] && diff -qr -- "$src" "$local_dir" >/dev/null 2>&1; then
    echo "  = $skill (up to date)"
  else
    rm -rf -- "$local_dir"
    cp -r -- "$src" "$local_dir"
    echo "  * $skill (updated from upstream)"
    CHANGED+=("$skill")
  fi
done

# --- Validate what we just synced --------------------------------------------
validate_skill() {
  local dir="$1" file="$1/SKILL.md" actual_name

  if [[ ! -f "$file" ]]; then
    echo "error: validation: $dir has no SKILL.md" >&2
    return 1
  fi

  if ! awk '
    NR == 1                 { if ($0 != "---") exit 1; in_fm = 1; next }
    in_fm && /^---[[:space:]]*$/ { in_fm = 0; next }
    in_fm && /^name: .+/        { name_ok = 1 }
    in_fm && /^description: .+/ { desc_ok = 1 }
    END { exit (name_ok && desc_ok) ? 0 : 1 }
  ' "$file"; then
    echo "error: validation: $file is missing name/description frontmatter" >&2
    return 1
  fi

  actual_name="$(sed -n 's/^name: *//p' "$file" | head -n1)"
  if [[ "$actual_name" != "$(basename "$dir")" ]]; then
    echo "error: validation: frontmatter name '$actual_name' does not match directory '$(basename "$dir")'" >&2
    return 1
  fi
}

for skill in "${SYNC_SKILLS[@]}"; do
  validate_skill "$DEST/$skill"
done

# --- Record state (only when it changed) --------------------------------------
NEW_STATE="$(jq -n \
  --arg repo "$UPSTREAM_REPO" \
  --arg branch "$UPSTREAM_BRANCH" \
  --arg sha "$SHA" \
  --argjson skills "$(printf '%s\n' "${SYNC_SKILLS[@]}" | jq -R . | jq -s -c .)" \
  '{ upstreamRepo: $repo, upstreamBranch: $branch, upstreamSha: $sha, syncedSkills: $skills }')"

if [[ ! -f "$STATE" ]] || ! grep -qxF "$NEW_STATE" "$STATE"; then
  mkdir -p -- "$(dirname "$STATE")"
  printf '%s\n' "$NEW_STATE" > "$STATE"
fi

# --- Summary -------------------------------------------------------------------
echo
if [[ ${#CHANGED[@]} -eq 0 ]]; then
  echo "All ${#SYNC_SKILLS[@]} skills already up to date."
else
  echo "Updated ${#CHANGED[@]} skill(s): ${CHANGED[*]}"
fi
echo "Skills not in the sync list were left untouched."
