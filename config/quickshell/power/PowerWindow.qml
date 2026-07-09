import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "../theme"

PanelWindow {
    id: root

    property bool isOpen: false
    property int selectedIndex: -1
    property int buttonCount: 5

    ColorPalette {
        id: palette
    }

    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: WlrLayershell.Ignore

    implicitWidth: 96
    implicitHeight: panel.implicitHeight + 32
    color: "transparent"
    visible: isOpen || slideAnimation.running

    anchors {
        right: true
    }

    margins {
        right: currentMargin
    }

    property real currentMargin: isOpen ? 10 : -130

    Behavior on currentMargin {
        NumberAnimation {
            id: slideAnimation
            duration: 220
            easing.type: Easing.OutCubic
        }
    }

    HyprlandFocusGrab {
        windows: [root]
        active: root.isOpen
        onCleared: root.isOpen = false
    }

    Shortcut {
        sequence: "Escape"
        onActivated: root.isOpen = false
    }

    IpcHandler {
        target: "power"

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

    function run(command) {
        Quickshell.execDetached(["bash", "-lc", command])
        root.isOpen = false
    }

    function activateSelected() {
        const commands = [
            "~/.config/hypr/scripts/power.sh --lock",
            "~/.config/hypr/scripts/power.sh --suspend",
            "~/.config/hypr/scripts/power.sh --logout",
            "~/.config/hypr/scripts/power.sh --reboot",
            "~/.config/hypr/scripts/power.sh --poweroff"
        ]

        if (selectedIndex >= 0 && selectedIndex < commands.length) {
            run(commands[selectedIndex])
        }
    }

    onIsOpenChanged: {
        if (isOpen) {
            selectedIndex = -1
            panel.forceActiveFocus()
        }
    }

    Item {
        id: panel
        implicitWidth: 76
        implicitHeight: buttons.implicitHeight + 28
        anchors.centerIn: parent
        focus: true

        Keys.onUpPressed: {
            selectedIndex = selectedIndex <= 0 ? buttonCount - 1 : selectedIndex - 1
        }

        Keys.onDownPressed: {
            selectedIndex = selectedIndex >= buttonCount - 1 ? 0 : selectedIndex + 1
        }

        Keys.onReturnPressed: root.activateSelected()
        Keys.onEnterPressed: root.activateSelected()

        Rectangle {
            anchors.fill: parent
            color: palette.background
            border.color: palette.border
            border.width: 1
            radius: 38
            opacity: 0.94
        }

        ColumnLayout {
            id: buttons
            anchors.centerIn: parent
            spacing: 14

            component PowerButton: Rectangle {
                id: button

                property string label: ""
                property string glyph: ""
                property string command: ""
                property bool selected: false
                property bool danger: false

                signal activated()

                implicitWidth: 48
                implicitHeight: 48
                radius: 24

                color: mouse.containsMouse || selected ? (danger ? palette.error : palette.accent) : "transparent"
                border.color: danger ? palette.error : palette.accent
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: button.glyph
                    color: mouse.containsMouse || button.selected ? palette.background : (button.danger ? palette.error : palette.accent)
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: button.activated()
                }
            }

            PowerButton {
                glyph: ""
                selected: root.selectedIndex === 0
                onActivated: root.run("~/.config/hypr/scripts/power.sh --lock")
            }

            PowerButton {
                glyph: "󰤄"
                selected: root.selectedIndex === 1
                onActivated: root.run("~/.config/hypr/scripts/power.sh --suspend")
            }

            PowerButton {
                glyph: "󰍃"
                selected: root.selectedIndex === 2
                onActivated: root.run("~/.config/hypr/scripts/power.sh --logout")
            }

            PowerButton {
                glyph: "󰜉"
                selected: root.selectedIndex === 3
                onActivated: root.run("~/.config/hypr/scripts/power.sh --reboot")
            }

            PowerButton {
                glyph: ""
                selected: root.selectedIndex === 4
                danger: true
                onActivated: root.run("~/.config/hypr/scripts/power.sh --poweroff")
            }
        }
    }
}
