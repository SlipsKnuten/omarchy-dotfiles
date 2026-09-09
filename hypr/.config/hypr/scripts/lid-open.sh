#!/bin/bash
#
# Lid-open handler (Hyprland `bindl`).

# Restore the panel, DPMS state, and saved display/keyboard brightness using
# Quattro's supported wake path, then re-assert our independent preferred
# keyboard level in case Quattro's temporary save was overwritten.
omarchy-system-wake
keyboard-backlight-memory restore
