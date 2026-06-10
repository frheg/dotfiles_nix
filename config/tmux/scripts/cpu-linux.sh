#!/usr/bin/env bash
STATE="$HOME/.cache/tmux-cpu-linux"
mkdir -p "$(dirname "$STATE")"

read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
idle_all=$((idle + iowait))
non_idle=$((user + nice + system + irq + softirq + steal))
total=$((idle_all + non_idle))

if [ ! -f "$STATE" ]; then
  echo "$total $idle_all" > "$STATE"
  echo "0%"
  exit 0
fi

read prev_total prev_idle < "$STATE"
totald=$((total - prev_total))
idled=$((idle_all - prev_idle))

echo "$total $idle_all" > "$STATE"

awk "BEGIN { if ($totald <= 0) print \"0%\"; else printf \"%.1f%%\", (100 * ($totald - $idled) / $totald) }"
