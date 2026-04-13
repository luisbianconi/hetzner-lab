#!/usr/bin/env bash
set -euo pipefail

status="${1:?status is required}"
workers="${2:-unknown}"
readme="${README_PATH:-README.md}"
timezone="${LAB_STATUS_TZ:-Europe/Lisbon}"

case "$status" in
  active)
    status_color="brightgreen"
    ;;
  inactive)
    status_color="red"
    ;;
  *)
    status_color="yellow"
    ;;
esac

updated_at="$(TZ="$timezone" date '+%Y--%m--%d')"
tmp_file="$(mktemp)"
uses_crlf=0

if grep -q $'\r$' "$readme"; then
  uses_crlf=1
fi

awk \
  -v status="$status" \
  -v status_color="$status_color" \
  -v workers="$workers" \
  -v updated_at="$updated_at" '
  /<!-- LAB_STATUS_START -->/ {
    print
    print "![Lab Status](https://img.shields.io/badge/lab_status-" status "-" status_color ")"
    print "![Workers](https://img.shields.io/badge/workers-" workers "-blue)"
    print "![Last Update](https://img.shields.io/badge/last_update-" updated_at "-lightgray)"
    in_status_block = 1
    next
  }

  /<!-- LAB_STATUS_END -->/ {
    print
    in_status_block = 0
    next
  }

  !in_status_block {
    print
  }
' "$readme" > "$tmp_file"

if [ "$uses_crlf" -eq 1 ]; then
  sed -i 's/$/\r/' "$tmp_file"
fi

mv "$tmp_file" "$readme"
