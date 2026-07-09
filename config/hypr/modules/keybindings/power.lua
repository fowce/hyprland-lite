local settings = require("modules.settings")
local mod = settings.mod

hl.bind(mod .. " + CTRL + P", hl.dsp.exec_cmd("qs ipc call power toggle"), { description = "Open power menu" })
hl.bind(mod .. " + SHIFT + Q", hl.dsp.exec_cmd(settings.scripts .. "/power.sh --logout"), { description = "Logout" })
