#!/bin/bash
#
# Lid-close handler (driven by Hyprland's Lua switch binding, NOT logind).
#
# Why not logind: this laptop has exposed unreliable USB-C power-supply state in
# the past. Keep logind's lid handling disabled so there is exactly one owner of
# the policy and the result does not depend on its AC/docked classification.
#
# Behaviour:
#   - External monitor connected -> clamshell: just lock, stay awake.
#   - No external monitor -> lock, suspend, then hibernate after the systemd
#     sleep-policy delay when running on battery.

# Record a lit, non-idle level before Quattro temporarily turns the keyboard
# off. If the five-second idle timer already fired, the saved preference wins.
keyboard-backlight-memory capture

if omarchy-hw-external-monitors; then
  # Clamshell: lock, remain awake, and let Omarchy disable the internal panel.
  omarchy-system-lock
  omarchy-hyprland-monitor-clamshell
  exit 0
fi

# No external monitor: Quattro owns display blanking, and its sleep-lock delay
# inhibitor verifies that the session is secure before systemd enters sleep.
omarchy-system-lock
sleep 1 # give the lock a head start before PrepareForSleep is emitted
systemctl suspend-then-hibernate
