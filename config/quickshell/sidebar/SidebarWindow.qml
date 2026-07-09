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
    property bool waybarEnabled: true
    property bool nightEnabled: false
    property bool vibranceEnabled: false

    ColorPalette {
        id: colors
    }

    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: WlrLayershell.Ignore

    implicitWidth: 392
    color: "transparent"
    visible: showWindow

    anchors {
        right: true
        top: true
        bottom: true
    }

    property real currentRightMargin: isOpen ? 12 : -430

    margins {
        right: currentRightMargin
        top: 52
        bottom: 12
    }

    Behavior on currentRightMargin {
        NumberAnimation {
            id: slideAnimation
            duration: 230
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
            color: colors.background
            border.color: colors.border
            border.width: 1
            radius: 16
            opacity: 0.96
        }

        ScrollView {
            anchors.fill: parent
            anchors.margins: 18
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 14

                Text {
                    text: "Desktop"
                    color: colors.text
                    font.family: "Fira Sans Semibold"
                    font.pixelSize: 20
                }

                SectionLabel {
                    text: "Controls"
                }

                ActionRow {
                    title: "Color picker"
                    subtitle: "Copy pixel color"
                    glyph: ""
                    onActivated: root.run("hyprpicker -a", true)
                }

                ToggleRow {
                    title: "Waybar"
                    subtitle: "Show or hide top panel"
                    glyph: "󰖲"
                    checked: root.waybarEnabled
                    onActivated: {
                        root.waybarEnabled = !root.waybarEnabled
                        root.run("~/.config/hypr/scripts/waybar-toggle.sh", false)
                    }
                }

                ActionRow {
                    title: "Wallpaper"
                    subtitle: "Choose desktop image"
                    glyph: ""
                    onActivated: root.run("~/.config/hypr/scripts/wallpaper-picker.sh", true)
                }

                ActionRow {
                    title: "Palette"
                    subtitle: "Switch color palette"
                    glyph: ""
                    onActivated: root.run("~/.config/hypr/scripts/palette-picker.sh", true)
                }

                SectionLabel {
                    text: "Player"
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 116
                    radius: 14
                    color: colors.surface
                    border.color: colors.border
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 12

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Rectangle {
                                Layout.preferredWidth: 42
                                Layout.preferredHeight: 42
                                radius: 12
                                color: colors.hover

                                Text {
                                    anchors.centerIn: parent
                                    text: ""
                                    color: colors.accent
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 19
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: "Media"
                                    color: colors.text
                                    font.family: "Fira Sans Semibold"
                                    font.pixelSize: 14
                                }

                                Text {
                                    text: "playerctl controls"
                                    color: colors.textSecondary
                                    font.family: "Fira Sans"
                                    font.pixelSize: 12
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            MediaButton {
                                glyph: "󰒮"
                                onActivated: root.run("playerctl previous", false)
                            }

                            MediaButton {
                                glyph: ""
                                primary: true
                                onActivated: root.run("playerctl play-pause", false)
                            }

                            MediaButton {
                                glyph: "󰒭"
                                onActivated: root.run("playerctl next", false)
                            }
                        }
                    }
                }

                ControlRow {
                    title: "Volume"
                    value: 55
                    onChanged: function(amount) {
                        root.run("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ " + amount + "%", false)
                    }
                }

                ActionRow {
                    title: "Volume mixer"
                    subtitle: "Open pavucontrol"
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

                ToggleRow {
                    title: "Night light"
                    subtitle: "hyprsunset"
                    glyph: "󰖔"
                    checked: root.nightEnabled
                    onActivated: {
                        root.nightEnabled = !root.nightEnabled
                        root.run("~/.config/hypr/scripts/hyprsunset-toggle.sh", false)
                    }
                }

                ToggleRow {
                    title: "Vibrance"
                    subtitle: "hyprshade"
                    glyph: "󰸌"
                    checked: root.vibranceEnabled
                    onActivated: {
                        root.vibranceEnabled = !root.vibranceEnabled
                        root.run("~/.config/hypr/scripts/hyprshade-toggle.sh", false)
                    }
                }

                SectionLabel {
                    text: "Capture"
                }

                ActionRow {
                    title: "Screenshot area"
                    subtitle: "Select region"
                    glyph: "󰹑"
                    onActivated: root.run("~/.config/hypr/scripts/screenshot.sh --area", true)
                }

                ActionRow {
                    title: "Screenshot screen"
                    subtitle: "Full output"
                    glyph: "󰍹"
                    onActivated: root.run("~/.config/hypr/scripts/screenshot.sh --screen", true)
                }

                ActionRow {
                    title: "OCR"
                    subtitle: "Read selected text"
                    glyph: "󰊄"
                    onActivated: root.run("~/.config/hypr/scripts/ocr.sh", true)
                }

                SectionLabel {
                    text: "System"
                }

                ActionRow {
                    title: "Network"
                    subtitle: "Open nmtui"
                    glyph: "󰤨"
                    onActivated: root.run("kitty -e nmtui", true)
                }

                ActionRow {
                    title: "GTK settings"
                    subtitle: "Open nwg-look"
                    glyph: "󰒓"
                    onActivated: root.run("nwg-look", true)
                }

                ActionRow {
                    title: "Qt settings"
                    subtitle: "Open qt6ct"
                    glyph: "󰖳"
                    onActivated: root.run("qt6ct", true)
                }
            }
        }
    }

    component SectionLabel: Text {
        color: colors.accent
        font.family: "Fira Sans Semibold"
        font.pixelSize: 12
    }

    component ActionRow: Rectangle {
        id: row

        property string title: ""
        property string subtitle: ""
        property string glyph: ""
        signal activated()

        Layout.fillWidth: true
        implicitHeight: 58
        radius: 13
        color: mouse.containsMouse ? colors.hover : colors.surface
        border.color: colors.border
        border.width: 1
        scale: mouse.pressed ? 0.985 : 1

        Behavior on scale {
            NumberAnimation { duration: 90 }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 13
            anchors.rightMargin: 13
            spacing: 12

            Text {
                text: row.glyph
                color: colors.accent
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 18
                Layout.preferredWidth: 26
                horizontalAlignment: Text.AlignHCenter
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: row.title
                    color: colors.text
                    font.family: "Fira Sans Semibold"
                    font.pixelSize: 13
                }

                Text {
                    text: row.subtitle
                    color: colors.textSecondary
                    font.family: "Fira Sans"
                    font.pixelSize: 11
                    visible: row.subtitle.length > 0
                }
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: row.activated()
        }
    }

    component ToggleRow: ActionRow {
        id: toggleRow

        property bool checked: false

        Rectangle {
            width: 42
            height: 22
            radius: 11
            color: toggleRow.checked ? colors.accent : colors.hover
            border.color: toggleRow.checked ? colors.accent : colors.border
            anchors.right: parent.right
            anchors.rightMargin: 13
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                width: 16
                height: 16
                radius: 8
                color: toggleRow.checked ? colors.background : colors.textSecondary
                anchors.verticalCenter: parent.verticalCenter
                x: toggleRow.checked ? 22 : 4

                Behavior on x {
                    NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
                }
            }
        }
    }

    component MediaButton: Rectangle {
        id: mediaButton

        property string glyph: ""
        property bool primary: false
        signal activated()

        Layout.fillWidth: true
        implicitHeight: 38
        radius: 12
        color: primary ? colors.accent : colors.hover
        border.color: primary ? colors.accent : colors.border
        border.width: 1
        scale: mouse.containsMouse ? 0.96 : 1

        Behavior on scale {
            NumberAnimation { duration: 90 }
        }

        Text {
            anchors.centerIn: parent
            text: mediaButton.glyph
            color: mediaButton.primary ? colors.background : colors.accent
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 17
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: mediaButton.activated()
        }
    }

    component ControlRow: ColumnLayout {
        id: control

        property string title: ""
        property int value: 50
        signal changed(int amount)

        Layout.fillWidth: true
        spacing: 8

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: control.title
                color: colors.text
                font.family: "Fira Sans Semibold"
                font.pixelSize: 13
                Layout.fillWidth: true
            }

            Text {
                text: Math.round(slider.value) + "%"
                color: colors.textSecondary
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

            background: Rectangle {
                x: slider.leftPadding
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                width: slider.availableWidth
                height: 8
                radius: 4
                color: colors.hover

                Rectangle {
                    width: slider.visualPosition * parent.width
                    height: parent.height
                    radius: 4
                    color: colors.accent
                }
            }

            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                width: 18
                height: 18
                radius: 9
                color: colors.text
                border.color: colors.accent
                border.width: 2
            }
        }
    }
}
