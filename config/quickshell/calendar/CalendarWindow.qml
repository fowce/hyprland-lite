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
    property int currentMonth: new Date().getMonth()
    property int currentYear: new Date().getFullYear()
    property int todayDate: new Date().getDate()
    property int todayMonth: new Date().getMonth()
    property int todayYear: new Date().getFullYear()

    property var monthNames: [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    property var dayNames: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

    ColorPalette {
        id: palette
    }

    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: WlrLayershell.Ignore

    implicitWidth: 372
    implicitHeight: 368
    color: "transparent"
    visible: showWindow

    anchors {
        top: true
    }

    property real currentTopMargin: isOpen ? 12 : -420

    margins {
        top: currentTopMargin
    }

    Behavior on currentTopMargin {
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
        target: "calendar"

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

    ListModel {
        id: dayModel
    }

    onIsOpenChanged: {
        if (isOpen) {
            showWindow = true
            refreshToday()
            panel.forceActiveFocus()
        }
    }

    Component.onCompleted: updateCalendar(currentYear, currentMonth)

    function refreshToday() {
        const now = new Date()
        todayDate = now.getDate()
        todayMonth = now.getMonth()
        todayYear = now.getFullYear()
        updateCalendar(currentYear, currentMonth)
    }

    function goToday() {
        const now = new Date()
        currentMonth = now.getMonth()
        currentYear = now.getFullYear()
        refreshToday()
    }

    function prevMonth() {
        if (currentMonth === 0) {
            currentMonth = 11
            currentYear--
        } else {
            currentMonth--
        }
        updateCalendar(currentYear, currentMonth)
    }

    function nextMonth() {
        if (currentMonth === 11) {
            currentMonth = 0
            currentYear++
        } else {
            currentMonth++
        }
        updateCalendar(currentYear, currentMonth)
    }

    function updateCalendar(year, month) {
        dayModel.clear()

        const firstDay = new Date(year, month, 1)
        const startCell = firstDay.getDay() === 0 ? 6 : firstDay.getDay() - 1
        const daysInMonth = new Date(year, month + 1, 0).getDate()
        const daysInPrevMonth = new Date(year, month, 0).getDate()

        for (let i = 0; i < 42; i++) {
            if (i < startCell) {
                dayModel.append({
                    day: daysInPrevMonth - startCell + i + 1,
                    current: false,
                    today: false
                })
            } else if (i < startCell + daysInMonth) {
                const dayNumber = i - startCell + 1
                dayModel.append({
                    day: dayNumber,
                    current: true,
                    today: dayNumber === todayDate && month === todayMonth && year === todayYear
                })
            } else {
                dayModel.append({
                    day: i - startCell - daysInMonth + 1,
                    current: false,
                    today: false
                })
            }
        }
    }

    Item {
        id: panel
        anchors.fill: parent
        anchors.margins: 16
        focus: true

        Keys.onLeftPressed: root.prevMonth()
        Keys.onRightPressed: root.nextMonth()
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Home) {
                root.goToday()
                event.accepted = true
            }
        }

        Rectangle {
            anchors.fill: parent
            color: palette.background
            border.color: palette.border
            border.width: 1
            radius: 12
            opacity: 0.94
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: monthNames[currentMonth] + " " + currentYear
                        color: palette.text
                        font.family: "Fira Sans Semibold"
                        font.pixelSize: 18
                    }

                    Text {
                        text: Qt.formatDate(new Date(), "dddd, d MMMM")
                        color: palette.textSecondary
                        font.family: "Fira Sans"
                        font.pixelSize: 12
                    }
                }

                component HeaderButton: Rectangle {
                    id: button

                    property string label: ""
                    signal activated()

                    implicitWidth: 32
                    implicitHeight: 32
                    radius: 9
                    color: mouse.containsMouse ? palette.hover : palette.surface
                    border.color: palette.border
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: button.label
                        color: palette.accent
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14
                    }

                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: button.activated()
                    }
                }

                HeaderButton {
                    label: "‹"
                    onActivated: root.prevMonth()
                }

                HeaderButton {
                    label: "•"
                    onActivated: root.goToday()
                }

                HeaderButton {
                    label: "›"
                    onActivated: root.nextMonth()
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 7
                columnSpacing: 6
                rowSpacing: 6

                Repeater {
                    model: dayNames

                    Text {
                        required property string modelData

                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 24
                        text: modelData
                        color: modelData === "Sa" || modelData === "Su" ? palette.accent : palette.textSecondary
                        font.family: "Fira Sans Semibold"
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 7
                columnSpacing: 6
                rowSpacing: 6

                Repeater {
                    model: dayModel

                    Rectangle {
                        required property int day
                        required property bool current
                        required property bool today

                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 32
                        radius: 10
                        color: today ? palette.accent : "transparent"
                        border.color: !today && current ? palette.border : "transparent"
                        border.width: !today && current ? 1 : 0

                        Text {
                            anchors.centerIn: parent
                            text: day
                            color: today ? palette.background : (current ? palette.text : palette.textDisabled)
                            font.family: today ? "Fira Sans Semibold" : "Fira Sans"
                            font.pixelSize: 13
                        }
                    }
                }
            }
        }
    }
}
