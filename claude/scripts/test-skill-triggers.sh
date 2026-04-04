#!/usr/bin/env bash
# test-skill-triggers.sh - Check which skills are registered and triggerable
# Usage: bash ~/.claude/scripts/test-skill-triggers.sh

set -euo pipefail

SKILLS_DIR="$HOME/.claude/skills"
PASS=0
FAIL=0
WARN=0

echo "Skill Trigger Audit"
echo "==================="
echo ""

for skill_dir in "$SKILLS_DIR"/*/; do
  [[ -d "$skill_dir" ]] || continue
  skill_name=$(basename "$skill_dir")
  skill_file="$skill_dir/SKILL.md"

  if [[ ! -f "$skill_file" ]]; then
    echo "FAIL  $skill_name - no SKILL.md"
    FAIL=$((FAIL + 1))
    continue
  fi

  # Check frontmatter exists
  if ! head -1 "$skill_file" | grep -q '^---'; then
    echo "FAIL  $skill_name - no YAML frontmatter"
    FAIL=$((FAIL + 1))
    continue
  fi

  # Extract description (handles YAML multi-line > and | blocks)
  desc=$(awk '/^---$/{n++; next} n==1' "$skill_file" | \
    awk '/^description:/{found=1; sub(/^description: *>? */, ""); if(length>0) print; next} found && /^  /{sub(/^  +/, ""); print; next} found{exit}' | \
    tr '\n' ' ' | sed 's/  */ /g')

  if [[ -z "$desc" ]] || [[ ${#desc} -lt 20 ]]; then
    echo "WARN  $skill_name - description too short (${#desc} chars), may not trigger"
    WARN=$((WARN + 1))
    continue
  fi

  # Check for trigger phrases in description
  has_triggers=false
  if echo "$desc" | grep -qiE 'use when|trigger|user says|use this'; then
    has_triggers=true
  fi

  # Check references exist
  ref_issues=""
  if grep -q 'references/' "$skill_file" 2>/dev/null; then
    while IFS= read -r ref; do
      ref_path="$skill_dir$ref"
      [[ -f "$ref_path" ]] || ref_issues="$ref_issues missing:$ref"
    done < <(grep -oE 'references/[a-zA-Z0-9_-]+\.(md|py|sh)' "$skill_file" | sort -u)
  fi

  if [[ -n "$ref_issues" ]]; then
    echo "FAIL  $skill_name -$ref_issues"
    FAIL=$((FAIL + 1))
  elif $has_triggers; then
    echo "OK    $skill_name"
    PASS=$((PASS + 1))
  else
    echo "WARN  $skill_name - no trigger phrases in description"
    WARN=$((WARN + 1))
  fi
done

echo ""
echo "Results: $PASS OK, $WARN warnings, $FAIL failures ($(( PASS + WARN + FAIL )) total)"
