#!/usr/bin/env bash
#
# PreToolUse(Bash) — refuse commands that feed fetched bytes straight into an
# interpreter: `get <url> | sh`, `bash <(curl ...)`, `eval "$(wget -O- ...)"`.
#
# This is a tripwire, not a boundary. It only sees the command string, so
# base64, a shell variable, or writing the file in one call and running it in
# the next all slip past. What it stops is the one-liner that turns fetched
# bytes into running code before anyone has looked at them — the step the
# HTTP wrappers in ~/.claude/bin deliberately cannot see.
#
# Exit 0 = allow, exit 2 = block with the message on stderr.

set -uo pipefail

cmd="$(jq -r '.tool_input.command // empty' 2>/dev/null)"
# No command, or no jq: stay out of the way rather than block everything.
[[ -n "$cmd" ]] || exit 0

fetch='(curl|wget|[][:alnum:]_.~/-]*/(get|post|put|patch|delete))([[:space:]]|$)'
interp='(sudo[[:space:]]+)?((ba|z|k|da)?sh|python3?|node|bun|deno|perl|ruby|osascript|php)([[:space:]]|$)'

block() {
  printf 'Blocked by no-fetch-exec: %s.\n' "$1" >&2
  printf 'Fetched content must not run unreviewed — save it, read it, then run it deliberately.\n' >&2
  exit 2
}

if printf '%s' "$cmd" | grep -Eq "$fetch[^|]*\|[[:space:]]*$interp"; then
  block "a fetch is piped into an interpreter"
fi

if printf '%s' "$cmd" | grep -Eq "$interp[^|]*<\([[:space:]]*$fetch"; then
  block "an interpreter reads a fetch through process substitution"
fi

if printf '%s' "$cmd" | grep -Eq "(eval|source|(^|[[:space:];&|])\.)[[:space:]]+[^|]*[\$<]\([[:space:]]*$fetch"; then
  block "fetched output is handed to eval or source"
fi

exit 0
