local settings = require("modules.settings")
local mod = settings.mod

hl.bind(mod .. " + SHIFT + H", hl.dsp.exec_cmd(settings.scripts .. "/hyprsunset-toggle.sh"), { description = "Toggle hyprsunset" })
hl.bind(mod .. " + SHIFT + V", hl.dsp.exec_cmd(settings.scripts .. "/hyprshade-toggle.sh"), { description = "Toggle vibrance shader" })
