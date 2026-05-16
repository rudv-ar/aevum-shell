pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.settings
import qs.services

PanelWindow {
    anchors.left:   true
    anchors.top:    true
    anchors.bottom: true

    implicitWidth: Properties.panelWidth
    color:         "transparent"
    visible:       PaneState.activePane === "left" || slideX > -Properties.panelWidth

    property real slideX: -Properties.panelWidth

    onVisibleChanged: {
        if (visible) {
            anim.enabled = false
            slideX = -Properties.panelWidth
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
            if (PaneState.activePane !== "left") {
                anim.enabled = true
                slideX = -Properties.panelWidth
            }
        }
    }

    Rectangle {
        anchors.fill:         parent
        anchors.leftMargin:   Properties.panelLeftMargin
        anchors.topMargin:    Properties.marginCover + Properties.topOffset
        anchors.bottomMargin: Properties.borderThickness
        color:                Theme.panelBg
        radius:               Properties.cornerRadius
        clip:                 true

        transform: Translate { x: slideX }

        Text {
            anchors.centerIn: parent
            text:             "Left Pane"
            color:            Theme.primary
            font.pixelSize:   16
        }
    }
}
