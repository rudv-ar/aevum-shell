import QtQuick
import qs.settings

Item {
    id: root

    // --- Left side
    property string leftGlyph:       "\uf128"
    property string leftLabel:       ""
    property color  leftAccentColor:  Theme.basePillAccentColor
    property color  leftAccentOnColor: Theme.basePillAccentOnColor
    property bool   leftMuted:       false
    property bool   leftPopoutOpen:  false
    property bool   leftAlwaysExpanded: false

    // --- Right side
    property string rightGlyph:       "\uf128"
    property string rightLabel:       ""
    property color  rightAccentColor:  Theme.basePillAccentColor
    property color  rightAccentOnColor: Theme.basePillAccentOnColor
    property bool   rightMuted:       false
    property bool   rightPopoutOpen:  false
    property bool   rightAlwaysExpanded: false

    property string fontFamily: Properties.nerdFontFamily

    signal leftClicked(var mouse)
    signal rightClicked(var mouse)
    signal leftScrolled(real delta)
    signal rightScrolled(real delta)

    readonly property bool _leftActive:  leftAlwaysExpanded  || _leftMouse.containsMouse
    readonly property bool _rightActive: rightAlwaysExpanded || _rightMouse.containsMouse

    readonly property real _leftExpandedWidth:
        Properties.basePillSpacing + _leftLabel.implicitWidth

    readonly property real _rightExpandedWidth:
        Properties.basePillSpacing + _rightLabel.implicitWidth

    implicitWidth:  _bg.implicitWidth
    implicitHeight: Properties.basePillHeight

    Rectangle {
        id: _bg

        height: Properties.basePillHeight
        radius: Properties.basePillRadius

        color: (root.leftPopoutOpen || root.rightPopoutOpen)
               ? Theme.basePillPopoutOpenColor
               : (_leftMouse.containsMouse || _rightMouse.containsMouse)
                 ? Theme.secondaryP30
                 : Theme.secondaryP30

        implicitWidth: {
            const pad      = Properties.basePillPadding
            const iconSize = Properties.basePillIconBgSize
            const sp       = Properties.basePillSpacing
            const divider  = 1 + sp * 2

            let w = pad + iconSize
            if (root._leftActive && Properties.basePillHoverEnabled && _leftLabel.implicitWidth > 0)
                w += root._leftExpandedWidth
            w += divider
            if (root._rightActive && Properties.basePillHoverEnabled && _rightLabel.implicitWidth > 0)
                w += root._rightExpandedWidth
            w += iconSize + pad
            return w
        }

        Behavior on implicitWidth {
            NumberAnimation {
                duration:    Properties.basePillExpandDuration
                easing.type: Easing.OutCubic
            }
        }

        Behavior on color {
            ColorAnimation { duration: Properties.basePillExpandDuration }
        }

        // ── Left icon bg ──────────────────────────────────────────────
        Rectangle {
            id: _leftIconBg

            anchors.left:           parent.left
            anchors.leftMargin:     Properties.basePillPadding
            anchors.verticalCenter: parent.verticalCenter

            width:  Properties.basePillIconBgSize
            height: Properties.basePillIconBgSize
            radius: Properties.basePillIconBgRadius

            color: root._leftActive && Properties.basePillHoverEnabled
                   ? (root.leftMuted ? Theme.audioError : root.leftAccentColor)
                   : Theme.secondaryP30

            Behavior on color {
                ColorAnimation { duration: Properties.basePillExpandDuration }
            }

            Text {
                anchors.centerIn: parent
                text:             root.leftGlyph
                font.pixelSize:   Properties.basePillIconSize
                font.family:      root.fontFamily
                font.weight:      Font.Black

                color: root._leftActive && Properties.basePillHoverEnabled
                       ? (root.leftMuted ? Theme.secondaryP20 : root.leftAccentOnColor)
                       : (root.leftMuted ? Theme.audioError   : Theme.basePillOnSurface)

                Behavior on color {
                    ColorAnimation { duration: Properties.basePillExpandDuration }
                }
            }
        }

        // ── Left label ────────────────────────────────────────────────
        Text {
            id: _leftLabel

            anchors.left:           _leftIconBg.right
            anchors.leftMargin:     Properties.basePillSpacing
            anchors.verticalCenter: parent.verticalCenter

            text:           root.leftLabel
            font.pixelSize: Properties.basePillFontSize
            font.weight:    Font.Medium
            color:          Theme.basePillOnSurface

            opacity: root._leftActive && Properties.basePillHoverEnabled ? 1.0 : 0.0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation {
                    duration:    Properties.basePillExpandDuration
                    easing.type: Easing.OutCubic
                }
            }
        }

        // ── Divider ───────────────────────────────────────────────────
        Rectangle {
            id: _divider

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter:   parent.verticalCenter

            width:  1
            height: Properties.basePillIconBgSize
            color:  Theme.secondaryP70
            opacity: 0.5
        }

        // ── Right icon bg ─────────────────────────────────────────────
        Rectangle {
            id: _rightIconBg

            anchors.right:          parent.right
            anchors.rightMargin:    Properties.basePillPadding
            anchors.verticalCenter: parent.verticalCenter

            width:  Properties.basePillIconBgSize
            height: Properties.basePillIconBgSize
            radius: Properties.basePillIconBgRadius

            color: root._rightActive && Properties.basePillHoverEnabled
                   ? (root.rightMuted ? Theme.audioError : root.rightAccentColor)
                   : Theme.secondaryP30

            Behavior on color {
                ColorAnimation { duration: Properties.basePillExpandDuration }
            }

            Text {
                anchors.centerIn: parent
                text:             root.rightGlyph
                font.pixelSize:   Properties.basePillIconSize
                font.family:      root.fontFamily
                font.weight:      Font.Black

                color: root._rightActive && Properties.basePillHoverEnabled
                       ? (root.rightMuted ? Theme.secondaryP20 : root.rightAccentOnColor)
                       : (root.rightMuted ? Theme.audioError   : Theme.basePillOnSurface)

                Behavior on color {
                    ColorAnimation { duration: Properties.basePillExpandDuration }
                }
            }
        }

        // ── Right label ───────────────────────────────────────────────
        Text {
            id: _rightLabel

            anchors.right:          _rightIconBg.left
            anchors.rightMargin:    Properties.basePillSpacing
            anchors.verticalCenter: parent.verticalCenter

            text:           root.rightLabel
            font.pixelSize: Properties.basePillFontSize
            font.weight:    Font.Medium
            color:          Theme.basePillOnSurface

            opacity: root._rightActive && Properties.basePillHoverEnabled ? 1.0 : 0.0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation {
                    duration:    Properties.basePillExpandDuration
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    // ── Mouse areas ───────────────────────────────────────────────────
    MouseArea {
        id:           _leftMouse
        x:            0
        y:            0
        width:        _bg.width / 2
        height:       root.height
        hoverEnabled: true
        cursorShape:  Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: (mouse) => root.leftClicked(mouse)
        onWheel:   (wheel) => root.leftScrolled(wheel.angleDelta.y > 0 ? 1.0 : -1.0)
    }

    MouseArea {
        id:           _rightMouse
        x:            _bg.width / 2
        y:            0
        width:        _bg.width / 2
        height:       root.height
        hoverEnabled: true
        cursorShape:  Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: (mouse) => root.rightClicked(mouse)
        onWheel:   (wheel) => root.rightScrolled(wheel.angleDelta.y > 0 ? 1.0 : -1.0)
    }
}
