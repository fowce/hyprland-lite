local settings = require("modules.settings")

hl.on("hyprland.start", function()
    hl.exec_cmd("pgrep -x waybar >/dev/null || waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css")
    hl.exec_cmd("pgrep -x mako >/dev/null || mako")
    hl.exec_cmd("[ -x " .. settings.scripts .. "/wallpaper.sh ] && " .. settings.scripts .. "/wallpaper.sh --restore")
    hl.exec_cmd("command -v qs >/dev/null 2>&1 && (pgrep -x qs >/dev/null || qs)")
end)
