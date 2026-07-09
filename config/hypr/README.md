# Hyprland

Lua-based Hyprland configuration lives here.

Entrypoint:

```text
hyprland.lua
```

Module layout:

```text
modules/
├── settings.lua
├── monitors.lua
├── environment.lua
├── permissions.lua
├── appearance/
├── input/
├── autostart/
├── keybindings/
└── rules/
```

The entrypoint is intentionally small. It only requires module files. Behavior is
split by responsibility: appearance, input, autostart, keybindings, rules, and
shared settings.

Lock screen:

- `hyprlock.conf`: main lock screen layout;
- `colors-hyprlock.conf`: generated palette values;
- `scripts/lock.sh`: prepares the lockscreen wallpaper cache and starts Hyprlock.

Idle and night light:

- `hypridle.conf`: dim, lock, display-off, and suspend timers;
- `hyprsunset.conf`: documented default night-light temperature;
- `scripts/idle-toggle.sh`: optional helper for enabling/disabling Hypridle.
