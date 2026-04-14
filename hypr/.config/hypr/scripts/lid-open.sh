#!/bin/bash

# Re-enable laptop screen if it was disabled (clamshell mode)
if ! hyprctl monitors -j | jq -e '.[] | select(.name == "eDP-1")' > /dev/null 2>&1; then
  hyprctl keyword monitor "eDP-1, preferred, auto, auto"
fi
