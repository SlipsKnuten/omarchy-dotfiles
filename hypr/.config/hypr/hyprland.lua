-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Load packaged Omarchy defaults, followed by personal overrides.
require("default.hypr.omarchy")
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")
require("default.hypr.toggles")

-- Keep Omarchy's shell idle timer suspended while watching YouTube in Zen.
-- Zen publishes a D-Bus screensaver inhibitor, but the shell idle monitor
-- currently listens for Hyprland/Wayland inhibitors instead.
o.window({ class = "^zen$", title = ".*YouTube.*" }, { idle_inhibit = "focus" })
