#!/usr/bin/env bash

PAGE_SIZE=$(vm_stat | awk '/page size of/ {print $8}')
USED_PAGES=$(vm_stat | awk '
  /Pages active/ {a=$3}
  /Pages wired down/ {w=$4}
  /Pages occupied by compressor/ {c=$5}
  END {
    gsub(/\./, "", a)
    gsub(/\./, "", w)
    gsub(/\./, "", c)
    print a + w + c
  }
')

TOTAL_BYTES=$(sysctl -n hw.memsize)
USED_GIB=$(awk "BEGIN {printf \"%.1f\", ($USED_PAGES * $PAGE_SIZE) / 1024 / 1024 / 1024}")
TOTAL_GIB=$(awk "BEGIN {printf \"%.0f\", $TOTAL_BYTES / 1024 / 1024 / 1024}")

printf "%sGi/%sGi" "$USED_GIB" "$TOTAL_GIB"
