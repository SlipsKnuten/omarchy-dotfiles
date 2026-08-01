#!/bin/bash
#
# Lid-open handler (Hyprland `bindl`).

# Re-enable laptop screen if it was disabled (clamshell mode).
if ! hyprctl monitors -j | jq -e '.[] | select(.name == "eDP-1")' > /dev/null 2>&1; then
  hyprctl keyword monitor "eDP-1, preferred, auto, auto"
fi

# AMD Strix iGPU does not auto-restore the panel/backlight on lid open after a
# non-suspend lock (lid close on AC) — without this you must press a key to wake
# the display. Force DPMS on and restore the saved brightness.
hyprctl dispatch dpms on
brightnessctl -r 2>/dev/null
