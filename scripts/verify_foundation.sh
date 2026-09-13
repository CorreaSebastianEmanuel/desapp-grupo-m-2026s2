#!/bin/sh
set -eu

url=${1:-http://127.0.0.1:4000/}
timeout=${VERIFY_TIMEOUT_SECONDS:-30}
marker=${VERIFY_MARKER:-Football Player Market}
started=$(date +%s)
body=$(mktemp "${TMPDIR:-/tmp}/football-market-response.XXXXXX")
trap 'rm -f "$body"' EXIT HUP INT TERM

while :; do
  status=$(curl --silent --show-error --output "$body" --write-out '%{http_code}' --max-time 2 "$url" 2>/dev/null || true)

  if [ "$status" = "200" ] && grep -Fq "$marker" "$body"; then
    elapsed=$(($(date +%s) - started))
    printf 'foundation ready: status=200 marker=%s elapsed=%ss url=%s\n' "$marker" "$elapsed" "$url"
    exit 0
  fi

  elapsed=$(($(date +%s) - started))
  if [ "$elapsed" -ge "$timeout" ]; then
    printf 'foundation verification failed after %ss: status=%s marker=%s url=%s\n' "$elapsed" "${status:-connection-failed}" "$marker" "$url" >&2
    exit 1
  fi

  sleep 1
done
