local settings = require("modules.settings")
local mod = settings.mod

hl.bind(mod .. " + CTRL + W", hl.dsp.exec_cmd(settings.scripts .. "/wallpaper-picker.sh"), { description = "Open wallpaper picker" })
hl.bind(mod .. " + SHIFT + W", hl.dsp.exec_cmd(settings.scripts .. "/wallpaper.sh --random"), { description = "Set random wallpaper" })
