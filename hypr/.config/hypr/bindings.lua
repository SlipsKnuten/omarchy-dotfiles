-- Replace Omarchy's stock lid handlers with the ACAD-aware local policy.
hl.unbind("switch:on:Lid Switch")
hl.unbind("switch:off:Lid Switch")
o.bind("switch:on:Lid Switch", nil, "$HOME/.config/hypr/scripts/lid-close.sh", { locked = true })
o.bind("switch:off:Lid Switch", nil, "$HOME/.config/hypr/scripts/lid-open.sh", { locked = true })

-- Preserve the stock keyboard-backlight controls and OSD while recording the
-- selected level independently of Omarchy's temporary lock/idle save state.
hl.unbind("XF86KbdBrightnessUp")
hl.unbind("XF86KbdBrightnessDown")
hl.unbind("XF86KbdLightOnOff")
o.bind("XF86KbdBrightnessUp", "Keyboard brightness up", "keyboard-backlight-memory up", { locked = true, repeating = true })
o.bind("XF86KbdBrightnessDown", "Keyboard brightness down", "keyboard-backlight-memory down", { locked = true, repeating = true })
o.bind("XF86KbdLightOnOff", "Keyboard backlight cycle", "keyboard-backlight-memory cycle", { locked = true })
