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

    visible: PaneState.activePane === "top"

    // slideY: 0 = fully in, -panelHeight = fully off above
    property real slideY: -Properties.panelHeight

    onVisibleChanged: if (visible) slideY = 0

    Behavior on slideY {
        NumberAnimation { duration: Properties.animDuration; easing.type: Easing.OutCubic }
    }

    Rectangle {
        anchors.fill:        parent
        anchors.topMargin:   Properties.topOffset + Properties.marginCover
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
