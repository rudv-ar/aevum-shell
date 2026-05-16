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
    visible:       PaneState.activePane === "right" || slideX < Properties.panelWidth

    property real slideX: Properties.panelWidth

    onVisibleChanged: {
        if (visible) {
            anim.enabled = false
            slideX = Properties.panelWidth
            anim.enabled = true
            slideX = 0
        }
    }

    Behavior on slideX {
        id: anim
        SpringAnimation {
            spring:  5
            damping: 0.8
            epsilon: 0.5
        }
    }

    Connections {
        target: PaneState
        function onActivePaneChanged() {
            if (PaneState.activePane !== "right") {
                anim.enabled = true
                slideX = Properties.panelWidth   // slide out, visible stays true until this finishes
            }
        }
    }

    Rectangle {
        anchors.fill:         parent
        anchors.rightMargin:  Properties.panelRightMargin
        anchors.topMargin:    Properties.marginCover + Properties.topOffset
        anchors.bottomMargin: Properties.borderThickness
        color:                Theme.panelBg
        radius:               Properties.cornerRadius
        clip:                 true

        transform: Translate { x: slideX }

        Text {
            anchors.centerIn: parent
            text:             "Right Pane"
            color:            Theme.primary
            font.pixelSize:   16
        }
    }
}
