# Agent Development Guide

This repository contains a lightweight Hyprland desktop configuration for Arch Linux.
The priority is safety, readability, reproducibility, and a small dependency surface.

## Core Rules

1. Do not modify, delete, move, download, install, or generate files unless the user has explicitly approved that action.
2. Before any command that changes state, explain in plain language:
   - what the command does;
   - which files or directories it may affect;
   - whether there is risk;
   - how to roll back.
3. Read-only commands may be used for analysis, but briefly explain why they are being run.
4. Do not use dangerous commands such as `rm -rf`, `sudo`, bulk moves, recursive overwrites, package installs, or directory replacement without separate explicit confirmation.
5. Before changes, verify the current path, important variables, and that expected directories exist.
6. Keep all changes minimal, understandable, and easy to review.
7. Keep the configuration lightweight.
8. Do not add dependencies unless they are necessary for an approved feature.
9. If a simple shell implementation is enough, prefer it over a heavy framework.
10. If an external template or code sample is used, document the source and explain exactly what was reused.
11. If code is written from scratch, explain the logic.
12. After writing code, check it for:
    - safety;
    - readability;
    - portability;
    - performance;
    - rollback behavior.
13. Before changing keybinds, check for conflicts.
14. Before changing autostart, explain which processes will run in the background.
15. Do not add hidden dependencies or non-obvious binaries.
16. Do not break the user's current active desktop configuration.
17. All shell scripts must use a safe style:
    - `set -Eeuo pipefail`;
    - quoted variables;
    - clear functions;
    - explicit error handling;
    - logging for install/switch scripts;
    - no unsafe globbing;
    - no unguarded destructive operations.
18. All changes must be compatible with a public GitHub repository.
19. Avoid personal names, private labels, or machine-specific identifiers in file and directory names.
20. At the end of each stage, report:
    - what was done;
    - which files changed;
    - which risks remain;
    - the proposed next step.

## Project Decisions

1. Hyprland configuration stays in Lua.
2. The main Hyprland entrypoint is `config/hypr/hyprland.lua`.
3. Hyprland settings should be split into logical Lua modules instead of one large file.
4. Installation is copy-based by default. Do not install configs as symlinks unless the user asks for a link mode.
5. Existing user configs must be backed up before replacement.
6. Backups must preserve symlink information when an existing config path is a symlink.
7. `install.sh` must not require root for user-level config installation.
8. Package installation must be opt-in.
9. VPN `tun` autoload setup must be opt-in and must clearly state that it writes to `/etc/modules-load.d/tun.conf`.
10. The default notification daemon is `mako`.
11. The workspace switcher should be lightweight and may use Rofi plus `hyprctl`.
12. Terminal configuration is part of the project: Kitty, Zsh, Fastfetch, and shell plugins are in scope.

## Desired Components

Core components:

- Hyprland Lua modules;
- Waybar;
- Rofi;
- Kitty;
- Zsh;
- Fastfetch;
- Hyprlock;
- Hypridle;
- Mako;
- Cliphist with wl-clipboard;
- wallpaper management;
- screenshot and OCR scripts;
- workspace switcher;
- power menu;
- sidebar;
- calendar.

Optional components:

- Quickshell UI panels;
- `nwg-look`;
- `qt6ct`;
- `swappy`;
- `grimblast`;
- OCR engine packages.

Do not include by default:

- Bluetooth applet;
- low battery listener;
- welcome/settings apps from another desktop config;
- dock/autohide dock;
- game mode toggle unless the user re-enables it;
- emoji picker;
- calculator;
- scratchpad/special workspace;
- Hyprland settings GUI button.

## Repository Layout

Expected high-level layout:

```text
hyprland-lite/
├── AGENTS.md
├── README.md
├── LICENSE
├── .gitignore
├── install.sh
├── uninstall.sh
├── switch-config.sh
├── check.sh
├── config/
│   ├── hypr/
│   ├── waybar/
│   ├── rofi/
│   ├── mako/
│   ├── kitty/
│   ├── zsh/
│   ├── fastfetch/
│   ├── quickshell/
│   └── wallpapers/
├── docs/
└── preview/
```

## Shell Script Standards

Every project shell script should:

1. Start with:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail
```

2. Use functions for major actions.
3. Quote variables.
4. Validate paths before writes.
5. Avoid deleting files. Prefer moving files into a timestamped backup.
6. Provide `--help` for user-facing scripts.
7. Support `--dry-run` when the script changes files.
8. Log important actions for install/switch/restore scripts.
9. Ask for confirmation before package installs or sudo actions.
10. Keep rollback instructions visible.

## Install Safety

`install.sh` must:

1. Work on Arch Linux.
2. Check whether Hyprland is installed or available.
3. Check required commands.
4. Create a timestamped backup before replacing configs.
5. Avoid overwriting important files without confirmation.
6. Show what will be changed.
7. Support dry-run mode.
8. Support restore mode.
9. Verify that backup data was created.
10. Fail clearly on critical errors.
11. Avoid root except for explicitly approved system-level actions.
12. Log actions to `~/.local/state/hyprland-lite/`.
13. Keep the current active desktop configuration recoverable.

## Config Style

1. Keep file names generic and public-friendly.
2. Do not include personal labels in file names.
3. Do not add branding text that ties the project to another configuration.
4. Use clear names such as `default`, `theme`, `accent`, `modules`, `scripts`, and `settings`.
5. Prefer static, understandable config over runtime self-modifying config.
6. Keep comments short and useful.

## Dependency Policy

Dependencies should be grouped as:

- core;
- Waybar;
- Rofi;
- terminal;
- clipboard;
- wallpapers;
- audio;
- power menu;
- lock screen;
- fonts;
- icons/themes;
- optional.

For each new dependency, document:

- package name;
- purpose;
- whether it is required;
- pacman or AUR source;
- replacement options;
- risks or side effects.

## Review Checklist

Before considering a stage complete:

1. Run syntax checks where possible.
2. Verify paths are correct.
3. Verify no active user config was modified unexpectedly.
4. Verify generated scripts are executable only when appropriate.
5. Confirm that rollback instructions exist.
6. Summarize changed files.
7. State remaining risks.
8. Propose the next step.
