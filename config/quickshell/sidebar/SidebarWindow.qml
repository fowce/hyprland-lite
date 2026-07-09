import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../theme"

PanelWindow {
    id: root

    property bool isOpen: false
    property bool showWindow: false

    ColorPalette {
        id: palette
    }

    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: WlrLayershell.Ignore

    implicitWidth: 336
    color: "transparent"
    visible: showWindow

    anchors {
        left: true
        top: true
        bottom: true
    }

    property real currentLeftMargin: isOpen ? 12 : -380

    margins {
        left: currentLeftMargin
        top: 52
        bottom: 12
    }

    Behavior on currentLeftMargin {
        NumberAnimation {
            id: slideAnimation
            duration: 220
            easing.type: Easing.OutCubic
            onRunningChanged: {
                if (!running && !root.isOpen) {
                    root.showWindow = false
                }
            }
        }
    }

    HyprlandFocusGrab {
        windows: [root]
        active: root.isOpen && root.showWindow
        onCleared: root.isOpen = false
    }

    Shortcut {
        sequence: "Escape"
        onActivated: root.isOpen = false
    }

    IpcHandler {
        target: "sidebar"

        function toggle(): void {
            root.isOpen = !root.isOpen
        }

        function open(): void {
            root.isOpen = true
        }

        function close(): void {
            root.isOpen = false
        }
    }

    onIsOpenChanged: {
        if (isOpen) {
            showWindow = true
            panel.forceActiveFocus()
        }
    }

    function run(command, closePanel) {
        Quickshell.execDetached(["bash", "-lc", command])
        if (closePanel) {
            root.isOpen = false
        }
    }

    Item {
        id: panel
        anchors.fill: parent
        focus: true

        Rectangle {
            anchors.fill: parent
            color: palette.background
            border.color: palette.border
            border.width: 1
            radius: 14
            opacity: 0.94
        }

        ScrollView {
            anchors.fill: parent
            anchors.margins: 16
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 14

                Text {
                    text: "Desktop"
                    color: palette.text
                    font.family: "Fira Sans Semibold"
                    font.pixelSize: 18
                }

                Text {
                    text: "Controls"
                    color: palette.accent
                    font.family: "Fira Sans Semibold"
                    font.pixelSize: 12
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    ActionButton {
                        label: "Picker"
                        glyph: ""
                        onActivated: root.run("hyprpicker -a", true)
                    }

                    ActionButton {
                        label: "Waybar"
                        glyph: "󰖲"
                        onActivated: root.run("~/.config/hypr/scripts/waybar-toggle.sh", false)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    ActionButton {
                        label: "Wallpaper"
                        glyph: ""
                        onActivated: root.run("~/.config/hypr/scripts/wallpaper-picker.sh", true)
                    }

                    ActionButton {
                        label: "Palette"
                        glyph: ""
                        onActivated: root.run("~/.config/hypr/scripts/palette-picker.sh", true)
                    }
                }

                SectionLabel {
                    text: "Audio"
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    ActionButton {
                        label: "Prev"
                        glyph: "󰒮"
                        onActivated: root.run("playerctl previous", false)
                    }

                    ActionButton {
                        label: "Play"
                        glyph: ""
                        onActivated: root.run("playerctl play-pause", false)
                    }

                    ActionButton {
                        label: "Next"
                        glyph: "󰒭"
                        onActivated: root.run("playerctl next", false)
                    }
                }

                ControlRow {
                    title: "Volume"
                    value: 50
                    onChanged: function(amount) {
                        root.run("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ " + amount + "%", false)
                    }
                }

                ActionButton {
                    Layout.fillWidth: true
                    label: "Volume Mixer"
                    glyph: ""
                    onActivated: root.run("pavucontrol", true)
                }

                SectionLabel {
                    text: "Display"
                }

                ControlRow {
                    title: "Brightness"
                    value: 60
                    onChanged: function(amount) {
                        root.run("brightnessctl set " + amount + "%", false)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    ActionButton {
                        label: "Night"
                        glyph: "󰖔"
                        onActivated: root.run("~/.config/hypr/scripts/hyprsunset-toggle.sh", false)
                    }

                    ActionButton {
                        label: "Vibrance"
                        glyph: "󰸌"
                        onActivated: root.run("~/.config/hypr/scripts/hyprshade-toggle.sh", false)
                    }
                }

                SectionLabel {
                    text: "Capture"
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    ActionButton {
                        label: "Area"
                        glyph: "󰹑"
                        onActivated: root.run("~/.config/hypr/scripts/screenshot.sh --area", true)
                    }

                    ActionButton {
                        label: "Screen"
                        glyph: "󰍹"
                        onActivated: root.run("~/.config/hypr/scripts/screenshot.sh --screen", true)
                    }

                    ActionButton {
                        label: "OCR"
                        glyph: "󰊄"
                        onActivated: root.run("~/.config/hypr/scripts/ocr.sh", true)
                    }
                }

                SectionLabel {
                    text: "System"
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    ActionButton {
                        label: "Network"
                        glyph: "󰤨"
                        onActivated: root.run("kitty -e nmtui", true)
                    }

                    ActionButton {
                        label: "GTK"
                        glyph: "󰒓"
                        onActivated: root.run("nwg-look", true)
                    }

                    ActionButton {
                        label: "Qt"
                        glyph: "󰖳"
                        onActivated: root.run("qt6ct", true)
                    }
                }
            }
        }
    }

    component SectionLabel: Text {
        color: palette.accent
        font.family: "Fira Sans Semibold"
        font.pixelSize: 12
    }

    component ActionButton: Rectangle {
        id: button

        property string label: ""
        property string glyph: ""
        signal activated()

        Layout.fillWidth: true
        implicitHeight: 42
        radius: 10
        color: mouse.containsMouse ? palette.hover : palette.surface
        border.color: palette.border
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 8

            Text {
                text: button.glyph
                color: palette.accent
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 15
                Layout.preferredWidth: 22
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                text: button.label
                color: palette.text
                font.family: "Fira Sans Semibold"
                font.pixelSize: 13
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: button.activated()
        }
    }

    component ControlRow: ColumnLayout {
        id: control

        property string title: ""
        property int value: 50
        signal changed(int amount)

        Layout.fillWidth: true
        spacing: 6

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: control.title
                color: palette.text
                font.family: "Fira Sans Semibold"
                font.pixelSize: 13
                Layout.fillWidth: true
            }

            Text {
                text: Math.round(slider.value) + "%"
                color: palette.textSecondary
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
            }
        }

        Slider {
            id: slider
            Layout.fillWidth: true
            from: 0
            to: 100
            value: control.value
            stepSize: 5
            onMoved: control.changed(Math.round(value))
        }
    }
}
