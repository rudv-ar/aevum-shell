pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import Quickshell
import qs.settings

ShellRoot {

    PanelWindow {
        id: win

        implicitWidth:  Screen.width
        implicitHeight: Screen.height
        color:          "transparent"
        mask:           Region {}

        property bool open: Properties.isOpen

        // grows rightMargin to shrink hole from the right
        property real _rightMargin: open
            ? Properties.borderThickness + Properties.panelWidth + Properties.panelRightMargin
            : Properties.borderThickness

        Behavior on _rightMargin {
            NumberAnimation { duration: Properties.animDuration; easing.type: Easing.OutCubic }
        }

        Rectangle {
            anchors.fill:      parent
            anchors.topMargin: Properties.marginCover
            color:             Theme.borderColor

            layer.enabled: true
            layer.effect: MultiEffect {
                maskSource:       innerMask
                maskEnabled:      true
                maskInverted:     true
                maskThresholdMin: 0.5
                maskSpreadAtMin:  1.0
            }
        }

        Item {
            id: innerMask
            anchors.fill: parent
            layer.enabled: true
            opacity: 0

            Rectangle {
                anchors.fill:         parent
                anchors.topMargin:    Properties.topOffset
                anchors.leftMargin:   Properties.borderThickness
                anchors.rightMargin:  win._rightMargin   // ← only this changes
                anchors.bottomMargin: Properties.borderThickness
                radius:               Properties.cornerRadius
            }
        }
    }
}
