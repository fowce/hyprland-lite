# Keybinds

The Hyprland keybinds are defined in:

```text
config/hypr/modules/keybindings/
```

The main modifier is `Super`.

## Applications

| Keybind | Action |
| --- | --- |
| `Super + Return` | Open Kitty. |
| `Super + B` | Open browser. |
| `Super + E` | Open file manager. |
| `Super + Ctrl + Return` | Open Rofi application launcher. |

## Windows

| Keybind | Action |
| --- | --- |
| `Super + Q` | Close active window. |
| `Super + F` | Toggle fullscreen. |
| `Super + M` | Toggle maximized mode. |
| `Super + T` | Toggle floating. |
| `Super + P` | Toggle pseudo tiling. |
| `Super + J` | Toggle split. |
| `Super + K` | Swap split. |
| `Super + G` | Toggle group. |
| `Super + Arrow` | Focus by direction. |
| `Super + Shift + Arrow` | Resize active window. |
| `Super + Alt + Arrow` | Swap window by direction. |
| `Super + Left Mouse` | Move window. |
| `Super + Right Mouse` | Resize window. |

## Workspaces

| Keybind | Action |
| --- | --- |
| `Super + 1..0` | Focus workspace 1..10. |
| `Super + Shift + 1..0` | Move active window to workspace 1..10. |
| `Super + Mouse Wheel` | Move to previous/next workspace. |
| `Super + Tab` | Open workspace switcher. |

`Super + Tab` exists because jumping from workspace 1 to 7 with number keys is
not ergonomic. The script reads live workspace data from `hyprctl -j`, shows it
in Rofi, and switches to the selected workspace.

## System Actions

| Keybind | Action |
| --- | --- |
| `Super + Ctrl + R` | Reload Hyprland. |
| `Super + Shift + B` | Reload Waybar. |
| `Super + Ctrl + B` | Toggle Waybar. |
| `Super + Ctrl + S` | Open sidebar, once implemented. |
| `Super + Ctrl + C` | Open top-centered calendar. |
| `Super + Ctrl + L` | Lock screen. |

## Clipboard, Wallpaper, Power

| Keybind | Action |
| --- | --- |
| `Super + V` | Open clipboard history. |
| `Super + Ctrl + W` | Open wallpaper picker. |
| `Super + Shift + W` | Set random wallpaper. |
| `Super + Ctrl + P` | Open Quickshell power menu. |
| `Super + Shift + Q` | Logout directly. |

## Screenshots And OCR

| Keybind | Action |
| --- | --- |
| `Super + Print` | Area screenshot. |
| `Super + Alt + F` | Fullscreen screenshot. |
| `Super + Alt + S` | Area screenshot. |
| `Super + Alt + A` | OCR selected area. |

## Effects

| Keybind | Action |
| --- | --- |
| `Super + Shift + H` | Toggle Hyprsunset. |
| `Super + Shift + V` | Toggle Hyprshade vibrance. |

## Media Keys

Hardware media keys control volume, microphone mute, brightness, and playback
through `wpctl`, `brightnessctl`, and `playerctl`.
