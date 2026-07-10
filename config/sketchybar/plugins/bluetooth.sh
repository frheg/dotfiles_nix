#!/bin/sh
if [ "$(blueutil --power)" != "1" ]; then
  sketchybar --set "$NAME" label="Off"
  exit 0
fi

DEVICES=$(blueutil --connected --format json | jq -r '[.[].name] | join(", ")')

if [ -n "$DEVICES" ]; then
  sketchybar --set "$NAME" label="$DEVICES"
else
  sketchybar --set "$NAME" label="On"
fi
