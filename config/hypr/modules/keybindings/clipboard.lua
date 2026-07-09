local settings = require("modules.settings")
local mod = settings.mod

hl.bind(mod .. " + V", hl.dsp.exec_cmd(settings.scripts .. "/clipboard.sh"), { description = "Open clipboard history" })
