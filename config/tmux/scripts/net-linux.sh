#!/usr/bin/env bash
DIR="$1"
STATE="$HOME/.cache/tmux-net-linux-$DIR"
mkdir -p "$(dirname "$STATE")"

if [ "$DIR" = "down" ]; then
  CUR=$(awk -F'[: ]+' '$1 !~ /lo/ && NF > 2 {sum += $3} END {print sum+0}' /proc/net/dev)
else
  CUR=$(awk -F'[: ]+' '$1 !~ /lo/ && NF > 2 {sum += $11} END {print sum+0}' /proc/net/dev)
fi

NOW=$(date +%s)

if [ ! -f "$STATE" ]; then
  echo "$CUR $NOW" > "$STATE"
  echo "0 KB/s"
  exit 0
fi

read PREV PREV_T < "$STATE"
DT=$((NOW - PREV_T))
[ "$DT" -le 0 ] && DT=1

RATE=$(((CUR - PREV) / DT))
echo "$CUR $NOW" > "$STATE"

if [ "$RATE" -ge 1048576 ]; then
  awk "BEGIN {printf \"%.1f MB/s\", $RATE/1048576}"
else
  awk "BEGIN {printf \"%.0f KB/s\", $RATE/1024}"
fi
