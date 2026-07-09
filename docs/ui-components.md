# UI Components

This file explains the current UI pieces, how they work, which commands they
run, and what still needs live testing.

The implementation is written for this repository. No third-party UI template is
copied into the project.

## Waybar

Files:

```text
config/waybar/config.jsonc
config/waybar/modules.jsonc
config/waybar/style.css
```

Purpose:

- top bar;
- workspace buttons;
- active window title;
- audio, battery, network, keyboard layout;
- clipboard shortcut;
- power menu shortcut;
- clock and calendar trigger;
- sidebar trigger.

Commands launched from Waybar:

```text
~/.config/hypr/scripts/launcher.sh
~/.config/hypr/scripts/workspace-switcher.sh
~/.config/hypr/scripts/clipboard.sh
~/.config/hypr/scripts/power.sh
qs ipc call sidebar toggle
qs ipc call power toggle
qs ipc call calendar toggle
kitty -e nmtui
pavucontrol
```

Design logic:

- Waybar remains static and easy to read.
- Removed items stay removed: update button, hardware dropdown, lock toggles.
- The network module opens `nmtui` instead of adding a heavier network applet.
- The keyboard language module is visible directly on the bar.

Risks:

- `qs` must be running for sidebar, power, and calendar panel buttons.
- `nmtui` requires NetworkManager tools.

## Rofi Launcher

Files:

```text
config/rofi/config.rasi
config/rofi/launcher.rasi
config/rofi/clipboard.rasi
config/rofi/workspace.rasi
config/rofi/power.rasi
```

Purpose:

- application launcher;
- clipboard history menu;
- workspace switcher;
- fallback power menu;
- palette and wallpaper pickers.

Design logic:

- search field is on top;
- list is below;
- no decorative panels beyond the minimal window;
- colors come from `~/.config/theme/colors.rasi`.

Risks:

- Rofi package naming differs between systems. Use a Wayland-capable Rofi build.

## Quickshell Entrypoint

File:

```text
config/quickshell/shell.qml
```

Purpose:

- loads the current QML panels:
  - power;
  - calendar;
  - sidebar.

Source:

- written for this repository.

Risk:

- QML panels need live Wayland testing. Static checks may not validate
  Quickshell-specific imports.

## Power Menu

File:

```text
config/quickshell/power/PowerWindow.qml
```

Opened by:

```text
qs ipc call power toggle
Super + Ctrl + P
Waybar power button
```

Purpose:

- lock;
- suspend;
- logout;
- reboot;
- poweroff.

Commands:

```text
~/.config/hypr/scripts/power.sh --lock
~/.config/hypr/scripts/power.sh --suspend
~/.config/hypr/scripts/power.sh --logout
~/.config/hypr/scripts/power.sh --reboot
~/.config/hypr/scripts/power.sh --poweroff
```

Design logic:

- vertical compact overlay;
- keyboard navigation with up/down/enter;
- Escape closes;
- the dangerous poweroff action uses the error color.

Risk:

- logout/reboot/poweroff are real system actions. They are exposed only through
  explicit button/key activation.

## Calendar

File:

```text
config/quickshell/calendar/CalendarWindow.qml
```

Opened by:

```text
qs ipc call calendar toggle
Super + Ctrl + C
Waybar clock click
```

Purpose:

- top-centered dropdown calendar;
- current month view;
- previous/next/today controls.

Design logic:

- Monday-first week layout;
- current day uses accent color;
- Escape or focus loss closes the panel.

Risk:

- Month/day names are currently English. Localization can be added later if
  needed.

## Sidebar

File:

```text
config/quickshell/sidebar/SidebarWindow.qml
```

Opened by:

```text
qs ipc call sidebar toggle
Super + Ctrl + S
Waybar sidebar button
```

Purpose:

- desktop control panel without heavy settings apps.

Current actions:

- color picker through `hyprpicker -a`;
- Waybar toggle;
- wallpaper picker;
- palette picker;
- media previous/play/next;
- volume slider through `wpctl`;
- `pavucontrol`;
- brightness slider through `brightnessctl`;
- Hyprsunset toggle;
- Hyprshade vibrance toggle;
- screenshot area/screen;
- OCR;
- network through `kitty -e nmtui`;
- GTK theme tool through `nwg-look`;
- Qt theme tool through `qt6ct`.

Design logic:

- no Welcome section;
- no settings dashboard;
- no light theme toggle;
- no dock controls;
- no game mode;
- no Fastfetch panel;
- no Bluetooth controls.

Risks:

- The sliders set absolute values based on their current UI position. They do
  not yet read live volume/brightness at panel open.
- `nwg-look`, `qt6ct`, and `tesseract` are optional. Missing tools make only
  those actions fail.

## Workspace Switcher

File:

```text
config/hypr/scripts/workspace-switcher.sh
```

Opened by:

```text
Super + Tab
Waybar appmenu right click
```

Purpose:

- quickly jump to workspace 1..10 without reaching for number keys.

Logic:

- reads active workspace with `hyprctl activeworkspace -j`;
- reads all workspaces with `hyprctl workspaces -j`;
- builds a 1..10 menu with window counts;
- marks the active workspace with `*`;
- sends `hyprctl dispatch workspace <number>`.

Dependencies:

- `hyprctl`;
- `jq`;
- `rofi`.

Risk:

- Only covers workspaces 1..10 by design.

## Clipboard

File:

```text
config/hypr/scripts/clipboard.sh
```

Opened by:

```text
Super + V
Waybar clipboard button
```

Purpose:

- show clipboard history;
- delete one entry;
- wipe history.

Logic:

- history watcher starts from Hyprland autostart:

```text
wl-paste --watch cliphist store
```

- menu uses `cliphist list`;
- selected item is decoded with `cliphist decode`;
- result is copied with `wl-copy`.

Dependencies:

- `cliphist`;
- `wl-clipboard`;
- `rofi`.

Risk:

- Clipboard history may store sensitive copied text. Use middle click on the
  Waybar clipboard button or `cliphist wipe` to clear it.

## Wallpaper Picker

Files:

```text
config/hypr/scripts/wallpaper-picker.sh
config/hypr/scripts/wallpaper.sh
```

Opened by:

```text
Super + Ctrl + W
Sidebar Wallpaper button
```

Purpose:

- select a wallpaper file;
- set it with `swww` or compatible `awww`;
- store current wallpaper state;
- generate lockscreen cache.

Logic:

- reads image files from `~/.config/wallpapers`;
- sends the selected path to `wallpaper.sh`;
- `wallpaper.sh` uses `swww` when available, otherwise compatible `awww`;
- cache is stored in `~/.cache/hyprland-lite`.

Dependencies:

- `swww` or compatible `awww`;
- `imagemagick`;
- `rofi`.

Risk:

- Very large wallpapers can make git history heavy. Keep private collections in
  `config/wallpapers/local/`, which is ignored by git.

Current scope:

- this is intentionally Rofi-based for the first VM test;
- a dedicated Quickshell wallpaper panel is not implemented yet.

## Palette Picker

Files:

```text
config/hypr/scripts/palette-picker.sh
config/theme/apply-palette.sh
config/palettes/*.json
```

Opened by:

```text
Sidebar Palette button
```

Purpose:

- change colors without changing theme layout or behavior.

Logic:

- lists `~/.config/palettes/*.json`;
- strips `.json` for menu display;
- selected name is passed to `apply-palette.sh`;
- generator validates required keys and color format;
- generated color files are written for Waybar, Rofi, Kitty, Hyprland,
  Hyprlock, Mako, and Quickshell.

Dependencies:

- `rofi`;
- `jq`;

Risk:

- A palette missing required keys fails intentionally. It should not generate a
  partial broken theme.
