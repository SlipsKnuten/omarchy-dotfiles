#!/bin/bash
# Restart wallpaper and waybar when monitors change

restart_services() {
    sleep 0.5  # Brief delay for monitor to fully initialize

    # Restart wallpaper
    pkill -x swaybg
    setsid uwsm-app -- swaybg -i "$HOME/.config/omarchy/current/background" -m fill >/dev/null 2>&1 &

    # Restart waybar
    omarchy-restart-waybar
}

# Listen for Hyprland monitor events
socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
    case "$line" in
        monitoradded*|monitorremoved*)
            restart_services
            ;;
    esac
done
