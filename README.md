# Hyprland Lite

A lightweight, public Hyprland configuration for Arch Linux.

The project keeps the desktop readable and easy to audit: Lua-based Hyprland
modules, a small Waybar, simple Rofi menus, Mako notifications, Kitty/Zsh
terminal setup, Hyprlock, Hypridle, Quickshell panels, and palette switching.

This repository is meant to be tested in a VM before using it on a main system.
The installer is intentionally blocked until `.install-ready` contains `ready`.

## Status

This config is under construction.

Current state:

- Hyprland config is split into Lua modules.
- Waybar, Rofi, Kitty, Mako, Fastfetch, Hyprlock, Hypridle, and Quickshell files exist.
- Quickshell power, calendar, and sidebar panels exist.
- Palette switching is implemented with JSON palette files.
- `install.sh` supports check, dry-run, backup-only, install, and restore modes.
- The installer uses copy-based installation and creates timestamped backups.
- The default wallpaper is included at `config/wallpapers/default.jpg`.

Not complete yet:

- dedicated Quickshell wallpaper panel beyond the current Rofi picker;
- final preview screenshots and videos;
- final VM validation.

## Preview

Preview files will live in:

```text
preview/
├── screenshots/
└── videos/
```

## Features

- Lua Hyprland entrypoint with logical modules.
- Top Waybar with workspace islands, active window, audio, battery, network,
  keyboard layout, clipboard, power, and clock.
- Minimal Rofi launcher with search on top and results below.
- Clipboard history on `Super + V` through `cliphist` and `wl-clipboard`.
- Workspace switcher on `Super + Tab` for fast jumps to any workspace.
- Wallpaper picker on `Super + Ctrl + W`.
- Quickshell power menu, top-centered calendar, and desktop sidebar.
- Mako notification daemon.
- Kitty, Zsh, and Fastfetch terminal profile.
- Hyprlock layout with generated wallpaper cache.
- Hypridle lock, dim, display-off, and suspend timers.
- Hyprsunset and Hyprshade toggles.
- Palette switching without changing layout or behavior.

## Repository Layout

```text
hyprland-lite/
├── AGENTS.md
├── LICENSE
├── README.md
├── .gitignore
├── install.sh
├── uninstall.sh
├── switch-config.sh
├── check.sh
├── config/
│   ├── fastfetch/
│   ├── hypr/
│   ├── kitty/
│   ├── mako/
│   ├── palettes/
│   ├── quickshell/
│   ├── rofi/
│   ├── theme/
│   ├── wallpapers/
│   ├── waybar/
│   └── zsh/
├── docs/
│   ├── customization.md
│   ├── dependencies.md
│   ├── install.md
│   ├── keybinds.md
│   ├── switching.md
│   ├── testing.md
│   ├── terminal.md
│   ├── ui-components.md
│   └── troubleshooting.md
└── preview/
    ├── screenshots/
    └── videos/
```

## Quick Start

Run checks only:

```bash
./install.sh --check
```

Preview the install plan without changing files:

```bash
./install.sh --dry-run
```

Create a backup only:

```bash
./install.sh --backup-only
```

Install after VM review and after `.install-ready` is changed to `ready`:

```bash
./install.sh --install
```

Restore a backup:

```bash
./install.sh --restore ~/.config-backups/hyprland-lite/<timestamp>
```

More details: [docs/install.md](docs/install.md).

List available switch sources:

```bash
./switch-config.sh --list
```

Preview switching to the repository config:

```bash
./switch-config.sh --to repo --dry-run
```

Switching details: [docs/switching.md](docs/switching.md).

Preview uninstalling managed config targets:

```bash
./uninstall.sh --dry-run
```

Run static project checks:

```bash
./check.sh
```

## Dependencies

The dependency list is split into required and optional groups in
[docs/dependencies.md](docs/dependencies.md).

The installer can check dependencies. It does not install packages unless
`--install-packages` is passed and the user confirms the pacman prompt.

## UI Components

The UI pieces and their commands are documented in
[docs/ui-components.md](docs/ui-components.md).

## Keybinds

The current keybind list is documented in [docs/keybinds.md](docs/keybinds.md).

Important bindings:

- `Super + Return`: terminal.
- `Super + Ctrl + Return`: application launcher.
- `Super + Tab`: workspace switcher.
- `Super + V`: clipboard history.
- `Super + Ctrl + W`: wallpaper picker.
- `Super + Ctrl + P`: power menu.
- `Super + Ctrl + C`: calendar.
- `Super + Ctrl + L`: lock screen.

## Palette Switching

Palettes live in `config/palettes/*.json`.

Generate theme files inside the repository:

```bash
./config/theme/apply-palette.sh warm --repo-root "$PWD" --no-reload
```

After installation:

```bash
~/.config/theme/apply-palette.sh warm
```

Palette files must keep the required color keys. The generator exits with an
error if a required key is missing or is not a `#RRGGBB` color.

More details: [docs/customization.md](docs/customization.md).

## Safety Model

The installer:

- does not run as root;
- does not modify active config without creating a backup first;
- copies directories instead of symlinking them;
- stores backups in `~/.config-backups/hyprland-lite/<timestamp>`;
- switchbacks are stored in `~/.config-switchbacks/hyprland-lite/<timestamp>`;
- writes logs to `~/.local/state/hyprland-lite`;
- refuses install while `.install-ready` is not `ready`;
- asks before package installation;
- asks before configuring `tun` autoload for VPN.

## Sources And Implementation Notes

The config is written as a new project.

- Shell scripts are written for this repository.
- Lua modules are written for this repository.
- Quickshell panels are written for this repository.
- The warm color palette is based on the user-provided palette reference image.
- Application choices and workflows come from read-only analysis of the user's
  existing desktop setup and follow-up decisions.

No third-party theme template is copied into this repository.

## License

MIT. See [LICENSE](LICENSE).

## Known Limits

- Quickshell panels need live-session testing; static QML linting is not enough
  for this setup.
- Screenshots and preview videos have not been added yet.
- Final package names may need small adjustments depending on pacman/AUR setup.

## Troubleshooting

See [docs/troubleshooting.md](docs/troubleshooting.md).
