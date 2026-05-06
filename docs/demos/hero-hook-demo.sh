#!/usr/bin/env bash
set -euo pipefail

type_slowly() {
  local text="$1"
  local i

  for ((i = 0; i < ${#text}; i++)); do
    printf '%s' "${text:i:1}"
    sleep 0.045
  done
}

printf '%s' '~/projects/api $ '

sleep 1
type_slowly 'rm -rf ~/important-data'

sleep 0.5
printf '\n'

sleep 0.3
printf '\033[31m[fstack hook] BLOCKED: destructive command outside allowlist\033[0m\n'

sleep 0.3
printf '\033[33m   reason: rm -rf without explicit --i-know-what-im-doing flag\033[0m\n'

sleep 0.3
printf "\033[32m   tip: type 'override' to bypass for this session\033[0m\n"

sleep 0.3
printf '%s' '~/projects/api $ '

sleep 1.5
