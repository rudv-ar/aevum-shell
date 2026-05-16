pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.settings
import qs.services

PanelWindow {
    anchors.top:   true
    anchors.left:  true
    anchors.right: true

    implicitHeight: Properties.panelHeight
    color:          "transparent"
    visible:        PaneState.activePane === "top" || slideY > -Properties.panelHeight

    property real slideY: -Properties.panelHeight

    onVisibleChanged: {
        if (visible) {
            anim.enabled = false
            slideY = -Properties.panelHeight
            anim.enabled = true
            slideY = 0
        }
    }

    Behavior on slideY {
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
            if (PaneState.activePane !== "top") {
                anim.enabled = true
                slideY = -Properties.panelHeight
            }
        }
    }

    Rectangle {
        anchors.fill:        parent
        anchors.topMargin:   Properties.marginCover + Properties.topOffset
        anchors.leftMargin:  Properties.borderThickness
        anchors.rightMargin: Properties.borderThickness
        color:               Theme.panelBg
        radius:              Properties.cornerRadius
        clip:                true

        transform: Translate { y: slideY }

        Text {
            anchors.centerIn: parent
            text:             "Top Pane"
            color:            Theme.panelFg
            font.pixelSize:   16
        }
    }
}
