# Customization

## Palettes

Palette files live in:

```text
config/palettes/
```

Each palette is a JSON file. Example:

```text
config/palettes/warm.json
```

To add a new palette, create a new `<name>.json` with the same keys.

Required keys:

- `background`
- `sidebar`
- `surface`
- `hover`
- `border`
- `accent`
- `accent_hover`
- `accent_active`
- `text`
- `text_secondary`
- `text_disabled`
- `success`
- `warning`
- `error`
- `info`

Every value must be a `#RRGGBB` color. If a required key is missing, the
generator exits with an error and does not silently create a broken theme.

## Applying A Palette

Inside the repository:

```bash
./config/theme/apply-palette.sh warm --repo-root "$PWD" --no-reload
```

After installation:

```bash
~/.config/theme/apply-palette.sh warm
```

Or open the palette picker from the sidebar. It runs:

```text
~/.config/hypr/scripts/palette-picker.sh
```

The script generates color files for:

- Waybar;
- Rofi;
- Kitty;
- Hyprland Lua;
- Hyprlock;
- Mako;
- Quickshell.

It changes colors only. It does not change layout, modules, keybinds, or
behavior.

## Wallpaper

Wallpapers belong in:

```text
config/wallpapers/
```

The wallpaper script stores the current selection in:

```text
~/.cache/hyprland-lite/current-wallpaper
```

It also creates a lockscreen cache image:

```text
~/.cache/hyprland-lite/lockscreen.png
```

## Local Overrides

Use local files for machine-specific changes where possible. The current Kitty
config already tries to include:

```text
~/.config/kitty/custom.conf
```

That file is optional and can stay outside the repository.
