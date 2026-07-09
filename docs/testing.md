# Testing

Test this repository in a VM before using it on a main system.

## VM Test Plan

Use this plan on a clean Arch Linux VM with Hyprland installed.

The goal is not to make the VM pretty immediately. The goal is to prove that the
config can be checked, installed, opened, used, and rolled back without damaging
an existing desktop.

## VM Assumptions

Expected VM baseline:

- Arch Linux;
- a normal non-root user;
- Hyprland session available;
- internet access for package installation;
- `git` installed or another way to copy this repository into the VM.

Do not test first on the main system.

## VM Package Setup

Install the core packages needed for the first test.

Example pacman command:

```bash
sudo pacman -S --needed \
  hyprland xdg-desktop-portal-hyprland polkit-gnome \
  waybar rofi kitty zsh fastfetch fzf eza jq \
  zsh-autosuggestions zsh-syntax-highlighting \
  ttf-jetbrains-mono-nerd ttf-font-awesome \
  pipewire wireplumber networkmanager pavucontrol \
  cliphist wl-clipboard hyprlock hypridle mako \
  brightnessctl playerctl hyprpicker hyprsunset \
  grim slurp imagemagick swww libnotify \
  nautilus qt6ct
```

Optional packages:

```bash
sudo pacman -S --needed tesseract tesseract-data-eng nwg-look
```

Quickshell may come from AUR or upstream packaging depending on the VM setup.
For this config it is required, because power menu, calendar, and sidebar are
implemented as Quickshell panels. The config expects the command:

```bash
qs
```

If `qs` is missing, Waybar can still start, but power/calendar/sidebar panels
will not open and `install.sh --check` should report it as missing.

If you run:

```bash
./install.sh --install --install-packages
```

the installer searches for an AUR helper. If no helper exists, it asks before
bootstrapping `yay-bin`. After a helper is available, missing required packages
are installed through that helper with `<helper> -S --needed`.

## Clone Or Copy The Repository

Recommended path in the VM:

```bash
cd ~
git clone <repo-url> hyprland-lite
cd hyprland-lite
```

If the repository is not on GitHub yet, copy the directory into the VM by any
safe method and enter it:

```bash
cd ~/hyprland-lite
```

## Pre-Install Checks

Run:

```bash
./check.sh
./install.sh --check
./install.sh --dry-run
./switch-config.sh --list
./uninstall.sh --dry-run
```

Expected result:

- `check.sh` passes;
- `install.sh --check` lists missing packages, if any;
- `install.sh --dry-run` prints the copy plan and may warn that `.install-ready`
  is not `ready`;
- `switch-config.sh --list` shows available sources;
- `uninstall.sh --dry-run` prints what would be moved;
- no files in `~/.config` are replaced by dry-run commands.

If required commands are missing, install the missing packages and repeat the
checks.

Wallpaper note:

- first-stage wallpaper switching is implemented with Rofi, not a Quickshell
  wallpaper panel;
- `Super + Ctrl + W` opens the Rofi wallpaper picker;
- the default test wallpaper is `config/wallpapers/default.jpg`;
- a dedicated Quickshell wallpaper panel is intentionally postponed until after
  the first VM test.

## Mark The Repo Ready

The installer refuses real installation until the repository is explicitly
marked ready:

```bash
printf 'ready\n' > .install-ready
```

This is a deliberate safety gate. Do it only inside the VM during this stage.

## Install In The VM

Run:

```bash
./install.sh --install
```

Read the plan printed by the installer. Confirm only if the source and
destination paths look correct.

Expected result:

- a backup is created in `~/.config-backups/hyprland-lite/<timestamp>`;
- config directories are copied into `~/.config`;
- `.zshrc` is copied into `$HOME`;
- rollback instructions are printed.

Save the printed backup path.

## Optional VPN tun Test

Only if the VM is meant to test VPN behavior:

```bash
./install.sh --install --configure-tun
```

The script should ask before writing:

```text
/etc/modules-load.d/tun.conf
```

Rollback:

```bash
sudo rm /etc/modules-load.d/tun.conf
sudo modprobe -r tun
```

## First Hyprland Login

Log out and start the Hyprland session.

Expected startup:

- Waybar appears at the top;
- Mako starts;
- wallpaper restore script runs without breaking the session;
- clipboard watcher starts;
- Hypridle starts;
- Quickshell starts.

Useful checks:

```bash
pgrep -a waybar
pgrep -a mako
pgrep -a hypridle
pgrep -a wl-paste
pgrep -a qs
```

## Live UI Checks

Run these inside the VM Hyprland session:

| Check | Expected result |
| --- | --- |
| `Super + Return` | Kitty opens. |
| `Super + Ctrl + Return` | Rofi application launcher opens. |
| `Super + Tab` | Workspace switcher opens and can jump to a workspace. |
| `Super + V` | Clipboard history opens. |
| `Super + Ctrl + W` | Wallpaper picker opens. |
| Waybar network click | `kitty -e nmtui` opens. |
| Waybar clock click | Calendar opens top-center. |
| `Super + Ctrl + C` | Calendar toggles. |
| Waybar power click | Power menu opens. |
| `Super + Ctrl + P` | Power menu toggles. |
| Waybar sidebar click | Sidebar opens. |
| `Super + Ctrl + S` | Sidebar toggles. |
| Sidebar Palette | Palette picker opens and applies selected palette. |
| Sidebar Waybar | Waybar toggles. |
| Sidebar Night | Hyprsunset toggles. |
| Sidebar Vibrance | Hyprshade toggles if installed/configured. |
| `Super + Ctrl + L` | Hyprlock opens. |

Do not test poweroff/reboot on the first pass unless you are ready to restart the
VM.

## Screenshot And OCR Checks

Screenshot:

```text
Super + Print
Super + Alt + F
Super + Alt + S
```

Expected result:

- screenshot file appears in `~/Pictures`;
- screenshot path is copied to clipboard;
- notification appears if `notify-send` works.

OCR:

```text
Super + Alt + A
```

Expected result:

- area selector opens;
- recognized text is copied to clipboard;
- notification appears.

OCR requires `tesseract` and a language data package.

## Palette Switching Checks

Repository mode:

```bash
./config/theme/apply-palette.sh warm --repo-root "$PWD" --no-reload
```

Installed mode:

```bash
~/.config/theme/apply-palette.sh warm
```

Expected result:

- generated files update in `~/.config/theme`;
- Waybar/Rofi/Kitty/Mako/Quickshell colors follow the palette;
- layout does not change.

## Rollback Test

Use the backup printed by `install.sh --install`:

```bash
./install.sh --restore ~/.config-backups/hyprland-lite/<timestamp>
```

Expected result:

- current targets are moved aside into a pre-restore backup;
- original backup files are copied back;
- the script prints what it restored.

Then test switching back to repository config:

```bash
./switch-config.sh --to repo --dry-run
./switch-config.sh --to repo
```

## Uninstall Test

Dry run:

```bash
./uninstall.sh --dry-run
```

Real VM uninstall:

```bash
./uninstall.sh --uninstall
```

Expected result:

- managed config targets are moved into
  `~/.config-uninstalled/hyprland-lite/<timestamp>`;
- files are not deleted;
- restore instructions are printed.

Restore from uninstall backup:

```bash
./switch-config.sh --to backup --backup ~/.config-uninstalled/hyprland-lite/<timestamp>
```

## Quickshell Notes

Quickshell panels must be tested in a live Wayland session. Static QML checks may
not understand Quickshell-specific imports on every system.
