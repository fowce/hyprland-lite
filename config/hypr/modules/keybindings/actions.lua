local settings = require("modules.settings")
local mod = settings.mod

hl.bind(mod .. " + CTRL + R", hl.dsp.exec_cmd("hyprctl reload"), { description = "Reload Hyprland" })
hl.bind(mod .. " + SHIFT + B", hl.dsp.exec_cmd("pkill -SIGUSR2 waybar || waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css"), { description = "Reload Waybar" })
hl.bind(mod .. " + CTRL + B", hl.dsp.exec_cmd(settings.scripts .. "/waybar-toggle.sh"), { description = "Toggle Waybar" })
hl.bind(mod .. " + CTRL + S", hl.dsp.exec_cmd("qs ipc call sidebar toggle"), { description = "Open sidebar" })
hl.bind(mod .. " + CTRL + C", hl.dsp.exec_cmd("qs ipc call calendar toggle"), { description = "Open calendar" })
hl.bind(mod .. " + CTRL + L", hl.dsp.exec_cmd(settings.scripts .. "/lock.sh"), { description = "Lock screen" })
