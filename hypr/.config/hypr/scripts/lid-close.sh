#!/bin/bash

# Count monitors (excluding eDP-1)
EXTERNAL_COUNT=$(hyprctl monitors -j | jq '[.[] | select(.name != "eDP-1")] | length')

if [[ "$EXTERNAL_COUNT" -gt 0 ]]; then
  # External monitor connected — clamshell mode (just disable laptop screen)
  hyprctl keyword monitor "eDP-1, disable"
else
  # No external monitor — lock and suspend
  loginctl lock-session
  sleep 1
  systemctl suspend
fi
