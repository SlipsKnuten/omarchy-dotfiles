-- Restore the saved keyboard-backlight level at login, then turn it off after
-- five seconds without input and restore it as soon as input resumes.
o.exec_on_start("keyboard-backlight-memory init")
o.launch_on_start("hypridle -c $HOME/.config/hypr/hypridle-kbd.conf")
