local settings = require("modules.settings")
local mod = settings.mod

hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd(settings.terminal), { description = "Open terminal" })
hl.bind(mod .. " + B", hl.dsp.exec_cmd(settings.browser), { description = "Open browser" })
hl.bind(mod .. " + E", hl.dsp.exec_cmd(settings.file_manager), { description = "Open file manager" })
hl.bind(mod .. " + CTRL + RETURN", hl.dsp.exec_cmd(settings.scripts .. "/launcher.sh"), { description = "Open application launcher" })
