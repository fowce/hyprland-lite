# Quickshell

Optional lightweight QML panels live here.

Current entrypoint:

- `shell.qml`

Current panels:

- `power/PowerWindow.qml`: vertical power menu opened with `qs ipc call power toggle`.
- `calendar/CalendarWindow.qml`: top-centered calendar opened with `qs ipc call calendar toggle`.
- `sidebar/SidebarWindow.qml`: desktop controls opened with `qs ipc call sidebar toggle`.

Palette:

- `theme/ColorPalette.qml`: generated color object used by QML panels.

Planned panels:

- wallpaper selector.
