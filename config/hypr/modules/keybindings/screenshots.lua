local settings = require("modules.settings")
local mod = settings.mod

hl.bind(mod .. " + PRINT", hl.dsp.exec_cmd(settings.scripts .. "/screenshot.sh"), { description = "Take screenshot" })
hl.bind(mod .. " + ALT + F", hl.dsp.exec_cmd(settings.scripts .. "/screenshot.sh --screen"), { description = "Take fullscreen screenshot" })
hl.bind(mod .. " + ALT + S", hl.dsp.exec_cmd(settings.scripts .. "/screenshot.sh --area"), { description = "Take area screenshot" })
hl.bind(mod .. " + ALT + A", hl.dsp.exec_cmd(settings.scripts .. "/ocr.sh"), { description = "Extract text from area" })
