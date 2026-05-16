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

    visible: PaneState.activePane === "left"

    // slideX: 0 = fully in, -panelWidth = fully off to the left
    property real slideX: -Properties.panelWidth

    onVisibleChanged: if (visible) slideX = 0

    Behavior on slideX {
        NumberAnimation { duration: Properties.animDuration; easing.type: Easing.OutCubic }
    }

    Rectangle {
        anchors.fill:        parent
        anchors.leftMargin:  Properties.panelLeftMargin
        anchors.topMargin:   Properties.topOffset + Properties.marginCover
        anchors.bottomMargin: Properties.borderThickness
        color:               Theme.panelBg
        radius:              Properties.cornerRadius
        clip:                true

        transform: Translate { x: slideX }

        Text {
            anchors.centerIn: parent
            text:             "Left Pane"
            color:            Theme.panelFg
            font.pixelSize:   16
        }
    }
}
