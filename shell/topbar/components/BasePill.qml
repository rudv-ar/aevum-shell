import QtQuick
import qs.settings

Item {
    id: root

    property string glyph:        "\uf128"
    property string fontFamily:   Properties.nerdFontFamily
    property string label:        ""
    property bool   popoutOpen:   false
    property bool   muted:        false
    property bool   alwaysExpanded: false
    property color  accentColor:  Theme.basePillAccentColor
    property color  accentOnColor: Theme.basePillAccentOnColor

    signal clicked(var mouse)
    signal scrolled(real delta)

    readonly property real sceneCenterX: mapToItem(null, width / 2, 0).x
    readonly property bool hovered:      _mouse.containsMouse

    readonly property bool _active: alwaysExpanded || hovered

    implicitWidth:  _bg.implicitWidth
    implicitHeight: Properties.basePillHeight

    Rectangle {
        id: _bg

        height: Properties.basePillHeight
        radius: Properties.basePillRadius

        color: root.popoutOpen
               ? Theme.basePillPopoutOpenColor
               : root.muted
                 ? Qt.rgba(Theme.audioError.r,
                           Theme.audioError.g,
                           Theme.audioError.b, 0.18)
                 : root.hovered
                   ? Theme.secondaryP20
                   : Theme.secondaryP15

        implicitWidth: {
            const base = Properties.basePillPadding
                       + Properties.basePillIconBgSize
                       + Properties.basePillPadding
            if (root._active
                    && Properties.basePillHoverEnabled
                    && _label.implicitWidth > 0)
                return base
                     + Properties.basePillSpacing
                     + _label.implicitWidth
            return base
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

        Rectangle {
            id: _iconBg

            anchors.left:           parent.left
            anchors.leftMargin:     Properties.basePillPadding
            anchors.verticalCenter: parent.verticalCenter

            width:  Properties.basePillIconBgSize
            height: Properties.basePillIconBgSize
            radius: Properties.basePillIconBgRadius

            color: root._active && Properties.basePillHoverEnabled
                   ? (root.muted ? Theme.audioError : root.accentColor)
                   : Theme.secondaryP15

            Behavior on color {
                ColorAnimation { duration: Properties.basePillExpandDuration }
            }

            Text {
                id: _iconText

                anchors.centerIn: parent
                text:             root.glyph
                font.pixelSize:   Properties.basePillIconSize
                font.family:      root.fontFamily
                font.weight:      Font.Black

                color: root._active && Properties.basePillHoverEnabled
                       ? (root.muted ? Theme.secondaryP20 : root.accentOnColor)
                       : (root.muted ? Theme.audioError : Theme.basePillOnSurface)

                rotation: root._active
                          && Properties.basePillIconRotateEnabled ? 360 : 0

                Behavior on rotation {
                    NumberAnimation {
                        duration:    Properties.basePillIconRotateDuration
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on color {
                    ColorAnimation { duration: Properties.basePillExpandDuration }
                }
            }
        }

        Text {
            id: _label

            anchors.left:           _iconBg.right
            anchors.leftMargin:     Properties.basePillSpacing
            anchors.verticalCenter: parent.verticalCenter

            text:           root.label
            font.pixelSize: Properties.basePillFontSize
            font.weight:    Font.Medium
            color:          Theme.basePillOnSurface

            opacity: root._active && Properties.basePillHoverEnabled ? 1.0 : 0.0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation {
                    duration:    Properties.basePillExpandDuration
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    MouseArea {
        id:              _mouse
        anchors.fill:    parent
        hoverEnabled:    true
        cursorShape:     Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: (mouse) => root.clicked(mouse)
        onWheel:   (wheel) => root.scrolled(wheel.angleDelta.y > 0 ? 1.0 : -1.0)
    }
}
