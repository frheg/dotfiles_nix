#!/bin/bash

STATE="$HOME/.cache/tmux-net-rx"
mkdir -p "$(dirname "$STATE")"

CUR=$(netstat -ibn | awk '$1 !~ /^lo/ && $7 > 0 {sum += $7} END {print sum}')

if [ ! -f "$STATE" ]; then
  echo "$CUR $(date +%s)" > "$STATE"
  echo "0 KB/s"
  exit 0
fi

read PREV PREV_T < "$STATE"
NOW=$(date +%s)

DT=$((NOW - PREV_T))
[ "$DT" -le 0 ] && DT=1

DB=$((CUR - PREV))
RATE=$((DB / DT))

echo "$CUR $NOW" > "$STATE"

if [ "$RATE" -ge 1073741824 ]; then
  awk "BEGIN {printf \"%.1f GB/s\", $RATE/1073741824}"
elif [ "$RATE" -ge 1048576 ]; then
  awk "BEGIN {printf \"%.1f MB/s\", $RATE/1048576}"
else
  awk "BEGIN {printf \"%.0f KB/s\", $RATE/1024}"
fi
