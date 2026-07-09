# Install

The installer is `install.sh`.

It is intentionally conservative. It copies repository directories into
`~/.config`, creates backups first, and refuses to install while `.install-ready`
does not contain `ready`.

## What It Copies

Config directories:

```text
config/hypr        -> ~/.config/hypr
config/waybar      -> ~/.config/waybar
config/rofi        -> ~/.config/rofi
config/mako        -> ~/.config/mako
config/kitty       -> ~/.config/kitty
config/zsh         -> ~/.config/zsh
config/fastfetch   -> ~/.config/fastfetch
config/quickshell  -> ~/.config/quickshell
config/palettes    -> ~/.config/palettes
config/theme       -> ~/.config/theme
config/wallpapers  -> ~/.config/wallpapers
```

Home files:

```text
config/zsh/.zshrc  -> ~/.zshrc
```

## Check Only

```bash
./install.sh --check
```

This checks OS hints, Hyprland presence, free space, commands, and pacman
packages. It does not change files.

## Dry Run

```bash
./install.sh --dry-run
```

This prints the install plan and backup paths without copying files.
If `.install-ready` is not `ready`, dry-run prints a warning. Real install is
still refused until the repository is marked ready.

## Backup Only

```bash
./install.sh --backup-only
```

This copies current target paths into:

```text
~/.config-backups/hyprland-lite/<timestamp>
```

The backup includes a `manifest.txt` used by restore mode.

## Install

After reviewing in a VM, mark the repo as installable:

```bash
printf 'ready\n' > .install-ready
```

Then install:

```bash
./install.sh --install
```

The script asks for confirmation before copying files.

## Package Installation

Packages are not installed by default.

To allow the installer to ask about missing required packages:

```bash
./install.sh --install --install-packages
```

Behavior:

- the installer searches for `yay`, `paru`, or `pikaur`;
- if no AUR helper exists, it asks before bootstrapping `yay-bin` from AUR;
- missing required packages are installed with the detected helper through
  `<helper> -S --needed`;
- AUR helpers can install both repository packages and AUR packages.

The script asks before every package installation step.

## VPN tun Autoload

VPN support can require the `tun` kernel module. To configure autoload:

```bash
./install.sh --install --configure-tun
```

The script asks before writing:

```text
/etc/modules-load.d/tun.conf
```

Rollback:

```bash
sudo rm /etc/modules-load.d/tun.conf
sudo modprobe -r tun
```

## Restore

```bash
./install.sh --restore ~/.config-backups/hyprland-lite/<timestamp>
```

Restore mode reads `manifest.txt`, moves current target paths aside into a
pre-restore backup, and copies the old files back.

## Uninstall

The uninstall helper is:

```bash
./uninstall.sh --dry-run
./uninstall.sh --uninstall
```

It does not delete files. It moves managed targets into:

```text
~/.config-uninstalled/hyprland-lite/<timestamp>
```

Restore from that backup with:

```bash
./switch-config.sh --to backup --backup ~/.config-uninstalled/hyprland-lite/<timestamp>
```

## Logs

Logs are written to:

```text
~/.local/state/hyprland-lite/
```

## Safety Rules

- Do not run as root.
- Test in a VM first.
- Use `--dry-run` before `--install`.
- Keep the backup path printed by the installer.
- Do not set `.install-ready` to `ready` until the config has been reviewed.
