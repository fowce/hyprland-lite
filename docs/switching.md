# Switching Configs

The switch helper is:

```text
switch-config.sh
```

It exists for testing and rollback between:

- the current live `~/.config`;
- this repository config;
- `~/.config.backup`;
- timestamped installer backups;
- timestamped switchback backups.
- timestamped uninstall backups.

## List Sources

```bash
./switch-config.sh --list
```

This prints:

- current live config path;
- repository config path;
- whether `~/.config.backup` exists;
- install backups in `~/.config-backups/hyprland-lite`;
- switchback backups in `~/.config-switchbacks/hyprland-lite`;
- uninstall backups in `~/.config-uninstalled/hyprland-lite`;
- repository readiness.

## Dry Run

```bash
./switch-config.sh --to repo --dry-run
```

Dry run prints what would be copied and where the pre-switch backup would be
created. It does not copy or move files.

## Switch To Repository Config

The repository must be marked ready first:

```bash
printf 'ready\n' > .install-ready
```

Then:

```bash
./switch-config.sh --to repo
```

The script asks before changing files.

## Switch To ~/.config.backup

```bash
./switch-config.sh --to config-backup
```

This copies matching directories from `~/.config.backup`.

If a source path is missing, the script keeps the current target unchanged. It
does not delete paths just because they are absent in `~/.config.backup`.

## Switch To A Backup

```bash
./switch-config.sh --to backup --backup ~/.config-backups/hyprland-lite/<timestamp>
```

The same command also works with switchback backups:

```bash
./switch-config.sh --to backup --backup ~/.config-switchbacks/hyprland-lite/<timestamp>
```

And uninstall backups:

```bash
./switch-config.sh --to backup --backup ~/.config-uninstalled/hyprland-lite/<timestamp>
```

## What Gets Switched

Config directories:

```text
hypr
waybar
rofi
mako
kitty
zsh
fastfetch
quickshell
palettes
theme
wallpapers
```

Home files:

```text
.zshrc
```

## Safety Behavior

- The script does not run as root.
- The script asks before real switching.
- The script creates a pre-switch backup first.
- Existing targets are moved into `replaced/` inside the same backup.
- Missing source paths are skipped instead of being deleted.
- The script does not kill, reload, or restart Hyprland.

## Rollback

After every real switch, the script prints a rollback source like:

```text
~/.config-switchbacks/hyprland-lite/<timestamp>
```

Use it as a backup source:

```bash
./switch-config.sh --to backup --backup ~/.config-switchbacks/hyprland-lite/<timestamp>
```
