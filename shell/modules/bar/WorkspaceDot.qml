pragma ComponentBehavior: Bound

import QtQuick
import qs.config
import qs.services

Item {
    id: root

    required property string name
    required property string state
    required property bool   expanded

    readonly property bool _focused:  state === "focused"
    readonly property bool _occupied: state === "occupied"
    readonly property bool _visible:  expanded || _focused || _occupied

    readonly property color _dotColor: _focused  ? Theme.wsDotFocusedColor
                                     : _occupied ? Theme.wsDotOccupiedColor
                                                 : Theme.wsDotEmptyColor

    readonly property int _baseSize:    Theme.wsDotSize        + (Theme.wsGlyphMode ? 10 : 0)
    readonly property int _focusedSize: Theme.wsDotFocusedSize + (Theme.wsGlyphMode ? 10 : 0)
    readonly property int _dotHeight:   _focused ? _focusedSize - 5 
                                                  : _baseSize
    readonly property int _dotRadius:   Theme.wsDotRadius      + (Theme.wsGlyphMode ? 10 : 0)

    readonly property string _glyph: _focused  ? "󰮯"
                                   : _occupied ? "󰊠"
                                               : "•"

    implicitWidth:  _baseSize
    implicitHeight: _visible ? (_dotHeight + Theme.wsDotSpacing) : 0

    clip: true

    Behavior on implicitHeight {
        SmoothedAnimation { duration: Theme.wsAnimDuration; velocity: -1 }
    }

    Rectangle {
        anchors.top:              parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        width:  root._baseSize
        height: root._dotHeight
        radius: root._dotRadius

        Behavior on height {
            SmoothedAnimation { duration: Theme.wsAnimDuration; velocity: -1 }
        }

        color: root._dotColor
        Behavior on color {
            ColorAnimation { duration: Theme.wsAnimDuration }
        }

        Text {
            anchors.centerIn: parent
            visible:          Theme.wsGlyphMode
            text:             root._glyph
            font.family:      Theme.nerdFontFamily
            font.pixelSize:   (root._focused ? 10 : 8) + (Theme.wsGlyphMode ? 5 : 0)
            color:            root._focused || root._occupied
                              ? Theme.base
                              : Theme.text

            Behavior on font.pixelSize {
                NumberAnimation { duration: Theme.wsAnimDuration }
            }
        }
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: WorkspaceService.switchTo(root.name)
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }
}
