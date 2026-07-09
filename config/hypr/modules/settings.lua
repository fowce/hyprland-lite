local home = os.getenv("HOME") or "~"

Desktop = {
    mod = "SUPER",
    terminal = "kitty",
    browser = "zen-browser",
    file_manager = "nautilus --new-window",
    editor = "nvim",
    scripts = home .. "/.config/hypr/scripts",
    quickshell = home .. "/.config/quickshell",
}

return Desktop
