import QtQuick
import qs.config

Item {
    id: root

    width:  Theme.pillWidth
    height: Theme.pillHeight

    // ── Signals ───────────────────────────────────────
    signal leftClicked()
    signal rightClicked()

    // ── Pill body ─────────────────────────────────────
    Rectangle {
        id:     pill
        anchors.fill: parent
        radius:       Theme.pillRadius

        // Lighten on hover, animate the transition
        color: mouse.containsMouse
               ? Qt.lighter(Theme.launcherBg, 1.25)
               : Theme.launcherBg

        Behavior on color {
            ColorAnimation { duration: 120; easing.type: Easing.OutCubic }
        }

        // Faint inner highlight
        Rectangle {
            anchors {
                fill:        parent
                topMargin:   1
                leftMargin:  1
                rightMargin: 1
            }
            height:  parent.height * 0.45
            radius:  Theme.pillRadius
            color:   "transparent"
        }

        // ── Arch Linux glyph ──────────────────────────
        Text {
            anchors.centerIn: parent
            text:             "\uf303"
            font.family:      Theme.nerdFontFamily
            font.pixelSize:   Theme.pillIconSize
            color:            Theme.textColor
            renderType:       Text.NativeRendering
        }
    }

    // ── Mouse area ────────────────────────────────────
    MouseArea {
        id:            mouse
        anchors.fill:  parent
        hoverEnabled:  true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape:   Qt.PointingHandCursor

        onClicked: (event) => {
            if (event.button === Qt.LeftButton)
                root.leftClicked()
            else if (event.button === Qt.RightButton)
                root.rightClicked()
        }
    }
}
