# Dependencies

This file lists Arch Linux packages used by the config.

Do not install packages blindly on the main system. Test in a VM first.

## Core

| Package | Needed | Source | Why | Replaceable | Notes |
| --- | --- | --- | --- | --- | --- |
| `hyprland` | required | pacman | Wayland compositor | no | Main desktop session. |
| `xdg-desktop-portal-hyprland` | required | pacman | portals for screen sharing and file dialogs | no | Needed for Wayland desktop integration. |
| `polkit-gnome` | required | pacman | authentication agent | yes | Can be replaced by another polkit agent. |
| `jq` | required | pacman | parse `hyprctl -j` output | yes | Used by scripts. |
| `libnotify` | recommended | pacman | `notify-send` for script notifications | yes | Scripts still avoid hard failure when notification sending fails. |

## Bar And Launcher

| Package | Needed | Source | Why | Replaceable | Notes |
| --- | --- | --- | --- | --- | --- |
| `waybar` | required | pacman | top status bar | yes | Current config is written for Waybar. |
| `rofi` | required | pacman | launcher and small menus | yes | Wayland-capable package may be named differently on some setups. |
| `ttf-font-awesome` | recommended | pacman | icon glyphs | yes | The current Waybar avoids heavy icon dependence, but this helps. |
| `quickshell` | required | AUR/upstream, sometimes pacman repo | power menu, calendar, sidebar | yes | The config expects the `qs` command. Installer uses an AUR helper if pacman cannot provide it. |

## Terminal

| Package | Needed | Source | Why | Replaceable | Notes |
| --- | --- | --- | --- | --- | --- |
| `kitty` | required | pacman | terminal emulator | yes | Selected to match the current workflow. |
| `zsh` | required | pacman | interactive shell | yes | Config is written for Zsh. |
| `fastfetch` | recommended | pacman | terminal system summary | yes | Cosmetic but requested. |
| `fzf` | recommended | pacman | fuzzy history/file helpers | yes | Used by shell workflow. |
| `eza` | recommended | pacman | modern `ls` replacement | yes | Aliases fall back poorly if missing. |
| `zsh-autosuggestions` | recommended | pacman | shell suggestions | yes | Plugin is optional but expected. |
| `zsh-syntax-highlighting` | recommended | pacman | shell command highlighting | yes | Plugin is optional but expected. |
| `ttf-jetbrains-mono-nerd` | recommended | pacman | terminal font | yes | Used by Kitty and UI text. |

## Clipboard

| Package | Needed | Source | Why | Replaceable | Notes |
| --- | --- | --- | --- | --- | --- |
| `cliphist` | required | pacman | clipboard history database | yes | Mature, simple Wayland option. |
| `wl-clipboard` | required | pacman | Wayland copy/paste commands | no | Provides `wl-copy`, `wl-paste`. |

## Wallpaper

| Package | Needed | Source | Why | Replaceable | Notes |
| --- | --- | --- | --- | --- | --- |
| `swww` or `awww` | required | pacman/AUR depending on system | wallpaper daemon | yes | `awww` is accepted as a compatible provider when `swww` is not available. |
| `imagemagick` | required | pacman | generate lockscreen cache | yes | Provides `magick`. |

## Audio, Brightness, Media

| Package | Needed | Source | Why | Replaceable | Notes |
| --- | --- | --- | --- | --- | --- |
| `pipewire` | required | pacman | audio stack | yes | Existing systems may already use it. |
| `wireplumber` | required | pacman | PipeWire session manager | yes | Needed for `wpctl`. |
| `pavucontrol` | recommended | pacman | graphical volume control | yes | Opened from Waybar/sidebar. |
| `brightnessctl` | recommended | pacman | brightness keys and slider | yes | Hardware support varies. |
| `playerctl` | recommended | pacman | media controls | yes | Used by media keys/panel. |

## Network

| Package | Needed | Source | Why | Replaceable | Notes |
| --- | --- | --- | --- | --- | --- |
| `networkmanager` | recommended | pacman | `nmtui` from Waybar network click | yes | No Bluetooth applet is included. |

## Power, Lock, Idle

| Package | Needed | Source | Why | Replaceable | Notes |
| --- | --- | --- | --- | --- | --- |
| `hyprlock` | required | pacman | lock screen | yes | Current lock config targets Hyprlock. |
| `hypridle` | recommended | pacman | idle lock/dim/suspend | yes | Can be disabled through script. |
| `mako` | required | pacman | notification daemon | yes | Selected for reliability and simplicity. |

## Effects And Utilities

| Package | Needed | Source | Why | Replaceable | Notes |
| --- | --- | --- | --- | --- | --- |
| `hyprpicker` | recommended | pacman | color picker | yes | Planned sidebar action. |
| `hyprsunset` | recommended | pacman | night light | yes | Toggle script included. |
| `hyprshade` | recommended | pacman/AUR depending on system | vibrance shader | yes | Autostarts vibrance if installed. |
| `grim` | recommended | pacman | screenshot capture | yes | Used by screenshot/OCR scripts. |
| `slurp` | recommended | pacman | area selection | yes | Used by screenshot/OCR scripts. |

## Optional

| Package | Needed | Source | Why | Replaceable | Notes |
| --- | --- | --- | --- | --- | --- |
| `nwg-look` | optional | pacman/AUR | GTK theme editing | yes | Kept because user requested it. |
| `qt6ct` | optional | pacman | Qt theme editing | yes | Kept because user requested it. |
| `tesseract` | optional | pacman | OCR backend | yes | Needed only if OCR script is used. |
| `tesseract-data-eng` | optional | pacman | English OCR data | yes | Add other language packs as needed. |
| `nautilus` | optional | pacman | default file manager keybind | yes | Change `file_manager` in `settings.lua` if using another file manager. |
| `zen-browser` | optional | AUR/upstream | default browser keybind | yes | Change `browser` in `settings.lua` if using another browser. |

## Removed From Scope

These are intentionally not part of the minimal config:

- Bluetooth applet and Bluetooth-specific UI.
- Emoji picker.
- Calculator menu.
- Low battery notification listener.
- HyprMod button.
- Scratchpad or special workspace workflow.
