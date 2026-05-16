pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.settings
import qs.services

PanelWindow {
    anchors.bottom: true
    anchors.left:   true
    anchors.right:  true

    implicitHeight: Properties.panelHeight
    color:          "transparent"
    visible:        PaneState.activePane === "bottom" || slideY < Properties.panelHeight

    property real slideY: Properties.panelHeight

    onVisibleChanged: {
        if (visible) {
            anim.enabled = false
            slideY = Properties.panelHeight
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
            if (PaneState.activePane !== "bottom") {
                anim.enabled = true
                slideY = Properties.panelHeight
            }
        }
    }

    Item {
        anchors.fill:         parent
        anchors.bottomMargin: Properties.panelBottomMargin
        anchors.leftMargin:   Properties.borderThickness
        anchors.rightMargin:  Properties.borderThickness
        clip:                 true

        Rectangle {
            width:  parent.width
            height: Properties.panelHeight
            color:  Theme.panelBg
            radius: Properties.cornerRadius

            transform: Translate { y: slideY }

            Text {
                anchors.centerIn: parent
                text:             "Bottom Pane"
                color:            Theme.panelFg
                font.pixelSize:   16
            }
        }
    }
}
