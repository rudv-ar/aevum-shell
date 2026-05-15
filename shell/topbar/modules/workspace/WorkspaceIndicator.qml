import QtQuick
import qs.settings
import qs.services.workspace

Item {
    id: root

    property bool alwaysExpanded: Properties.workspaceIndicatorAlwaysExpanded

    implicitWidth:  _icon.implicitWidth + Properties.workspaceIconGap + _bg.width
    implicitHeight: Properties.barHeight

    WorkspaceIcon {
        id: _icon
        anchors.verticalCenter: parent.verticalCenter
        anchors.left:           parent.left
    }

    Rectangle {
        id: _bg
        anchors.verticalCenter: parent.verticalCenter
        anchors.left:           _icon.right
        anchors.leftMargin:     Properties.workspaceIconGap

        HoverHandler {
            id: _dotsHover
            cursorShape: Qt.PointingHandCursor
        }

        readonly property bool _expanded: alwaysExpanded || _dotsHover.hovered

        width: _dotsRow.implicitWidth
               + Properties.workspaceIndicatorPaddingX * 2

        Behavior on width {
            NumberAnimation {
                duration:    Properties.workspaceDotAnimDuration
                easing.type: Easing.OutCubic
            }
        }

        height: root.implicitHeight
                - Properties.workspaceIndicatorPaddingY * 2

        radius: Properties.workspaceIndicatorRadius

        color: _dotsHover.hovered
               ? Theme.workspaceIndicatorBackgroundHovered
               : Theme.workspaceIndicatorBackground

        Behavior on color {
            ColorAnimation { duration: Properties.workspaceDotAnimDuration }
        }

        Row {
            id: _dotsRow
            anchors.verticalCenter: parent.verticalCenter
            anchors.left:           parent.left
            anchors.leftMargin:     Properties.workspaceIndicatorPaddingX
            spacing: 0

            Repeater {
                model: WorkspaceService.desktops

                WorkspaceDot {
                    required property var modelData

                    name:     modelData.name
                    state:    modelData.state
                    expanded: _bg._expanded

                    onLeftClicked: (n) => WorkspaceService.switchTo(n)
                }
            }
        }
    }
}
