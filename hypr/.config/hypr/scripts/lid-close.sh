#!/bin/bash
#
# Lid-close handler (driven by Hyprland `bindl`, NOT logind).
#
# Why not logind: systemd-logind's "on external power?" check walks every
# non-battery power supply and trusts any with online=1. This AMD Strix laptop
# has a phantom USB-C UCSI source (ucsi-source-psy-USBC000:002) stuck at
# online=1 even on battery, so logind always thinks it's on AC and uses
# HandleLidSwitchExternalPower (lock) instead of suspending. We can't tell
# logind to ignore one supply, so logind's lid handling is disabled
# (/etc/systemd/logind.conf.d/disable-lid-handling.conf) and we decide here,
# reading the REAL charger (ACAD) directly.
#
# Behaviour:
#   - External monitor connected -> clamshell: just lock, stay awake.
#   - No external + real charger (ACAD) plugged in -> lock, stay awake
#     (so Plex / downloads keep running on AC).
#   - No external + on battery -> lock, then suspend.

# Record a lit, non-idle level before Quattro temporarily turns the keyboard
# off. If the five-second idle timer already fired, the saved preference wins.
keyboard-backlight-memory capture

if omarchy-hw-external-monitors; then
  # Clamshell: lock, remain awake, and let Omarchy disable the internal panel.
  omarchy-system-lock
  omarchy-hyprland-monitor-clamshell
  exit 0
fi

# No external monitor. Decide lock style by whether we're about to suspend.
# Read the *real* AC adapter (ACAD); ignore the buggy USB-C UCSI phantom supply.
if [[ "$(cat /sys/class/power_supply/ACAD/online 2>/dev/null)" == "0" ]]; then
  # On battery -> lock through Quattro, then suspend. Quattro owns display
  # blanking directly, avoiding the old deferred `sleep 3; dpms off` timer
  # that froze during suspend and fired into resume.
  omarchy-system-lock
  sleep 1 # let the lock take hold before freezing the session
  systemctl suspend
else
  # On AC: stay awake (locked) — Plex / downloads continue. Use the normal
  # lock so the display still powers off a few seconds after locking.
  omarchy-system-lock
fi
