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

    visible: PaneState.activePane === "bottom"

    // slideY: 0 = fully in, panelHeight = fully off below
    property real slideY: Properties.panelHeight

    onVisibleChanged: if (visible) slideY = 0

    Behavior on slideY {
        NumberAnimation { duration: Properties.animDuration; easing.type: Easing.OutCubic }
    }

    Rectangle {
        anchors.fill:         parent
        anchors.bottomMargin: Properties.panelBottomMargin
        anchors.leftMargin:   Properties.borderThickness
        anchors.rightMargin:  Properties.borderThickness
        color:                Theme.panelBg
        radius:               Properties.cornerRadius
        clip:                 true

        transform: Translate { y: slideY }

        Text {
            anchors.centerIn: parent
            text:             "Bottom Pane"
            color:            Theme.panelFg
            font.pixelSize:   16
        }
    }
}
