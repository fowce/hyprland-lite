hl.on("hyprland.start", function()
    hl.exec_cmd("pgrep -x hypridle >/dev/null || hypridle")
    hl.exec_cmd("pgrep -f 'wl-paste --watch cliphist store' >/dev/null || wl-paste --watch cliphist store")
end)
