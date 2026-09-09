-- Quattro owns display idle/locking; hypridle is retained only for the
-- independent keyboard-backlight timer.
o.launch_on_start("hypridle -c $HOME/.config/hypr/hypridle-kbd.conf")
o.exec_on_start("keyboard-backlight-memory init")
