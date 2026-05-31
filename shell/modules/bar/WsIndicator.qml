pragma ComponentBehavior: Bound

import QtQuick
import qs.config
import qs.services

Item {
    id: root

    implicitWidth:  Theme.holeLeft
    implicitHeight: _bg.height

    HoverHandler { id: _hover }

    readonly property bool _expanded: true

    Rectangle {
        id:      _bg
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top:              parent.top

        width:  Theme.wsDotSize + (Theme.wsGlyphMode ? 5 : 0) + Theme.wsIndicatorPadX * 2
        height: _col.implicitHeight + Theme.wsIndicatorPadY * 2
        radius: Theme.wsIndicatorRadius + 5

        color: _hover.hovered
               ? Theme.wsIndicatorBgHovered
               : Theme.wsIndicatorBg


        Behavior on color {
            ColorAnimation { duration: Theme.wsAnimDuration }
        }
        Behavior on border.color {
            ColorAnimation { duration: Theme.wsAnimDuration }
        }
        Behavior on height {
            NumberAnimation { duration: Theme.wsAnimDuration; easing.type: Easing.OutCubic }
        }
        Behavior on width {
            NumberAnimation { duration: Theme.wsAnimDuration; easing.type: Easing.OutCubic }
        }

        Column {
            id:                       _col
            anchors.top:              parent.top
            anchors.topMargin:        Theme.wsIndicatorPadY
            anchors.horizontalCenter: parent.horizontalCenter
            spacing:                  0

            Repeater {
                model: WorkspaceService.desktops

                WorkspaceDot {
                    required property var modelData

                    name:     modelData.name
                    state:    modelData.state
                    expanded: root._expanded
                }
            }
        }
    }
}  
