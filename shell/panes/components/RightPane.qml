pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.settings
import qs.services

PanelWindow {
    anchors.right:  true
    anchors.top:    true
    anchors.bottom: true

    implicitWidth: Properties.panelWidth
    color:         "transparent"

    // Visible only when this direction is active.
    // The inner content slides in from the right on show.
    visible: PaneState.activePane === "right"

    // slideX: 0 = fully in, panelWidth = fully off to the right
    property real slideX: Properties.panelWidth

    // Trigger slide-in as soon as the window becomes visible
    onVisibleChanged: if (visible) slideX = 0

    Behavior on slideX {
        NumberAnimation { duration: Properties.animDuration; easing.type: Easing.OutCubic }
    }

    // ── Content ─────────────────────────────────────────────────────
    Rectangle {
        anchors.fill:         parent
        anchors.rightMargin:  Properties.panelRightMargin
        anchors.topMargin:    Properties.marginCover + Properties.topOffset
        anchors.bottomMargin: Properties.borderThickness
        color:                Theme.panelBg
        radius:               Properties.cornerRadius
        clip:                 true

        transform: Translate { x: slideX }

        // ── Put your right-pane content here ────────────────────────
        Text {
            anchors.centerIn: parent
            text:             "Right Pane"
            color:            Theme.panelFg
            font.pixelSize:   16
        }
    }
}
