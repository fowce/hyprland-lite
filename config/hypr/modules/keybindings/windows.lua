local settings = require("modules.settings")
local mod = settings.mod

hl.bind(mod .. " + Q", hl.dsp.window.close(), { description = "Close active window" })
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }), { description = "Toggle fullscreen" })
hl.bind(mod .. " + M", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }), { description = "Toggle maximized" })
hl.bind(mod .. " + T", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating" })
hl.bind(mod .. " + P", hl.dsp.window.pseudo(), { description = "Toggle pseudo tiling" })
hl.bind(mod .. " + J", hl.dsp.layout("togglesplit"), { description = "Toggle split" })
hl.bind(mod .. " + K", hl.dsp.layout("swapsplit"), { description = "Swap split" })
hl.bind(mod .. " + G", hl.dsp.group.toggle(), { description = "Toggle group" })

hl.bind(mod .. " + left", hl.dsp.focus({ direction = "left" }), { description = "Focus left" })
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }), { description = "Focus right" })
hl.bind(mod .. " + up", hl.dsp.focus({ direction = "up" }), { description = "Focus up" })
hl.bind(mod .. " + down", hl.dsp.focus({ direction = "down" }), { description = "Focus down" })

hl.bind(mod .. " + SHIFT + right", hl.dsp.window.resize({ x = 100, y = 0, relative = true }), { repeating = true, description = "Increase window width" })
hl.bind(mod .. " + SHIFT + left", hl.dsp.window.resize({ x = -100, y = 0, relative = true }), { repeating = true, description = "Decrease window width" })
hl.bind(mod .. " + SHIFT + down", hl.dsp.window.resize({ x = 0, y = 100, relative = true }), { repeating = true, description = "Increase window height" })
hl.bind(mod .. " + SHIFT + up", hl.dsp.window.resize({ x = 0, y = -100, relative = true }), { repeating = true, description = "Decrease window height" })

hl.bind(mod .. " + ALT + left", hl.dsp.window.swap({ direction = "l" }), { description = "Swap left" })
hl.bind(mod .. " + ALT + right", hl.dsp.window.swap({ direction = "r" }), { description = "Swap right" })
hl.bind(mod .. " + ALT + up", hl.dsp.window.swap({ direction = "u" }), { description = "Swap up" })
hl.bind(mod .. " + ALT + down", hl.dsp.window.swap({ direction = "d" }), { description = "Swap down" })

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Move window with mouse" })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window with mouse" })
