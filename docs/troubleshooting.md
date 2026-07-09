# Troubleshooting

## Installer Refuses To Install

If you see an error about `.install-ready`, the repository is still marked as not
ready.

This is intentional. After VM testing and review:

```bash
printf 'ready\n' > .install-ready
```

## Waybar Does Not Start

Check the config manually:

```bash
waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css
```

Also check whether another Waybar process is running:

```bash
pgrep -a waybar
```

## Rofi Theme Fails

Dump the theme:

```bash
rofi -no-config -theme ~/.config/rofi/launcher.rasi -dump-theme
```

If palette files are missing, reapply the palette:

```bash
~/.config/theme/apply-palette.sh warm
```

## Clipboard Is Empty

The history watcher must be running:

```bash
pgrep -a wl-paste
```

Start it manually for testing:

```bash
wl-paste --watch cliphist store
```

## Wallpaper Does Not Restore

Check that `swww` works:

```bash
swww query
```

Set a wallpaper manually:

```bash
~/.config/hypr/scripts/wallpaper.sh --random
```

## Quickshell Panel Does Not Open

Check that Quickshell is running:

```bash
pgrep -a qs
```

Start it manually:

```bash
qs
```

Then test IPC:

```bash
qs ipc call power toggle
qs ipc call calendar toggle
```

## Hyprlock Shows No Wallpaper

Run the lock helper once:

```bash
~/.config/hypr/scripts/lock.sh
```

It creates:

```text
~/.cache/hyprland-lite/lockscreen.png
```

## Hyprshade Does Not Start

Check whether it is installed:

```bash
command -v hyprshade
```

Then test:

```bash
hyprshade on vibrance
```

If the shader is missing, the package may not provide a default `vibrance`
shader. In that case the toggle script needs a local shader path.
