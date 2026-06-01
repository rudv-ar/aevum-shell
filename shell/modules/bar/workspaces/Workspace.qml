pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import qs.utils

ColumnLayout {
    id: root

    required property string desktopName
    required property bool   isActive
    required property bool   isOccupied
    required property bool   isUrgent

    readonly property real size: implicitHeight

    readonly property var windows:  WindowService.windowsByDesktop[desktopName] ?? []
    readonly property int maxIcons: 5
    readonly property int overflow: Math.max(0, windows.length - maxIcons)

    implicitWidth: Theme.pillWidth
    Layout.alignment: Qt.AlignHCenter
    spacing: 1

    // ── Case: occupied → window icons only ────────────
    Column {
        Layout.fillWidth: true
        spacing: -6
        visible: root.isOccupied

        Repeater {
            model: Math.min(root.windows.length, root.maxIcons)

            Text {
                required property int index

                width:               layout.width
                height:              Theme.pillWidth - 4
                text:                Icons.getIcon(root.windows[index])
                font.family:         Icons.fontFamily
                font.pixelSize:      15
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment:   Text.AlignVCenter

                color: root.isActive
                       ? Theme.accent
                       : Qt.rgba(Theme.text.r,
                                 Theme.text.g,
                                 Theme.text.b, 0.55)

                Behavior on color {
                    ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
                }
            }
        }

        Text {
            visible:             root.overflow > 0
            width:               parent.width
            height:              Theme.pillWidth - 4
            text:                "+" + root.overflow
            font.family:         Icons.fontFamily
            font.pixelSize:      10
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment:   Text.AlignVCenter
            color:               Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.4)
        }
    }

    // ── Case: empty + focused → pacman ────────────────
    Text {
        Layout.fillWidth:    true

        height:              Theme.pillWidth - 4
        visible:             !root.isOccupied && root.isActive
        text:                "󰮯"
        font.family:         Icons.fontFamily
        font.pixelSize:      15
        horizontalAlignment: Text.AlignHLeft
        verticalAlignment:   Text.AlignVCenter
        color:               Theme.accent
    }

    // ── Case: empty + unfocused → dot or number ───────
    Text {
        Layout.fillWidth:    true
        height:              Theme.pillWidth - 4
        visible:             !root.isOccupied && !root.isActive
        text:                Theme.showDesktopNumbers ? root.desktopName : String.fromCodePoint(0xF09DE)
        font.family:         Icons.fontFamily
        font.pixelSize:      Theme.showDesktopNumbers ? 10 : 14
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment:   Text.AlignVCenter
        color:               Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.35)
    }
}
