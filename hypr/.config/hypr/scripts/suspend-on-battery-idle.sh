#!/bin/bash

# Quattro's Stay Awake toggle must disable auto-suspend as well as its own
# screensaver and lock timers.
[[ ! -e "$HOME/.local/state/omarchy/indicators/stay-awake" ]] || exit 0

# Fail safe if the laptop's real AC-adapter state cannot be read. The UCSI
# source/sink devices are intentionally ignored because they have been stale on
# this machine before.
AC_ONLINE=/sys/class/power_supply/ACAD/online
[[ -r $AC_ONLINE ]] || exit 0
[[ $(<"$AC_ONLINE") == 0 ]] || exit 0

logger --tag omarchy-idle-suspend "30-minute battery idle timeout; requesting suspend-then-hibernate"
systemctl suspend-then-hibernate
