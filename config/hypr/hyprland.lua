-- Main Hyprland Lua entrypoint.
-- Keep this file small; put real settings in modules/.

require("modules.settings")

require("modules.monitors")
require("modules.environment")
require("modules.permissions")

require("modules.appearance.general")
require("modules.appearance.decoration")
require("modules.appearance.animations")
require("modules.appearance.layouts")
require("modules.appearance.misc")

require("modules.input.keyboard")
require("modules.input.mouse")
require("modules.input.touchpad")
require("modules.input.gestures")
require("modules.input.devices")

require("modules.autostart.core")
require("modules.autostart.desktop")
require("modules.autostart.services")
require("modules.autostart.optional")

require("modules.keybindings.init")

require("modules.rules.workspaces")
require("modules.rules.windows")
require("modules.rules.layers")
