local omarchy_gdk_scale = 2
local omarchy_monitor_scale = "auto"

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

hl.monitor({
  output = "desc:LG Electronics 27GN950",
  mode = "3840x2160@60",
  position = "0x0",
  scale = 1.5,
})

hl.monitor({
  output = "desc:LG Electronics LG ULTRAGEAR",
  mode = "2560x1440@144",
  position = "2560x0",
  scale = 1,
  transform = 3,
})

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
