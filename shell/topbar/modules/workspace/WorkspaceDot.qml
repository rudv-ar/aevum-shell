import QtQuick
import qs.settings

Item {
    id: root

    required property string name
    required property string state
    required property bool   expanded

    readonly property bool glyphMode: Properties.workspaceHasGlyphIndicator
    readonly property string _glyph: root.state === "occupied"  ? "󰊠"   // nf-md-ghost
                                : root.state === "focused" ? "󰮯"   // nf-md-pac_man
                                                            : "•"   // U+2B24 big dot
    signal leftClicked(string name)
    signal rightClicked(string name)

    readonly property bool  _visible:  expanded || state === "focused" || state === "occupied"
    readonly property real  _dotWidth: state === "focused"
                                       ? Properties.workspaceDotFocusedWidth
                                       : Properties.workspaceDotSize
    readonly property color _dotColor: state === "focused"  ? Theme.workspaceDotFocusedColor
                                     : state === "occupied" ? Theme.workspaceDotOccupiedColor
                                                            : Theme.workspaceDotEmptyColor

    // focused dot never shows a label — reserved for the separate component later
    readonly property bool _showLabel: {
        //if (state === "focused") return false
        var mode = Properties.workspaceDotLabelMode
        if (mode === "always")    return true
        if (mode === "collapsed") return !expanded
        if (mode === "expanded")  return expanded
        return false  // "none"
    }

    implicitWidth:  _visible
                    ? (_dotWidth + Properties.workspaceDotSpacing)
                    : 0
    implicitHeight: Properties.workspaceDotSize

    clip: true

    Behavior on implicitWidth {
        SmoothedAnimation {
            duration: Properties.workspaceDotAnimDuration
            velocity: -1
        }
    }

    Rectangle {
        id: _dotRect
        anchors.verticalCenter: parent.verticalCenter
        anchors.left:           parent.left
        height:                 Properties.workspaceDotSize
        radius:                 Properties.workspaceDotRadius

        width: root._dotWidth
        Behavior on width {
            SmoothedAnimation {
                duration: Properties.workspaceDotAnimDuration
                velocity: -1
            }
        }

        color: root._dotColor
        Behavior on color {
            ColorAnimation { duration: Properties.workspaceDotAnimDuration }
        }

        Text {
            anchors.centerIn: parent
            text:             root.glyphMode ? root._glyph : root.name
            //font.pixelSize:   root.glyphMode ? Properties.workspaceDotLabelFontSize + 3 : Properties.workspaceDotLabelFontSize
            font.pixelSize: root.glyphMode
                ? (root.state === "empty"
                   ? Properties.workspaceDotLabelFontSize + 10
                   : Properties.workspaceDotLabelFontSize + 3)
                : Properties.workspaceDotLabelFontSize
            font.family:      Theme.fontAwesome6
            color:            root._dotColor === Theme.workspaceDotEmptyColor
                              ? Theme.primaryP90
                              : Theme.barBackground
            // contrast: light text on dark empty dot, dark text on light/accent dots

            opacity: root._showLabel ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation { duration: Properties.workspaceDotAnimDuration }
            }
        }
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: root.leftClicked(root.name)
    }
    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: root.rightClicked(root.name)
    }
}

