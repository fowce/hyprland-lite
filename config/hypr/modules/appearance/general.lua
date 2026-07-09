local colors = require("modules.theme.colors")

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 14,
        border_size = 2,

        col = {
            active_border = { colors = { colors.rgba("accent", "ee"), colors.rgba("accent_hover", "ee") }, angle = 45 },
            inactive_border = colors.rgba("border", "aa"),
        },

        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
    },
})
