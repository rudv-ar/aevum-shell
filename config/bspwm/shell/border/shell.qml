// x11border.qml — standalone desktop border for X11 / bspwm
// Run: quickshell -p x11border.qml
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
        color:  "transparent"
        mask:   Region{}

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: Properties.marginCover
            color:        Theme.borderColor

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
            visible: false

            Rectangle {
                anchors.fill:         parent
                anchors.topMargin:    Properties.topOffset
                anchors.leftMargin:   Properties.borderThickness
                anchors.rightMargin:  Properties.borderThickness
                anchors.bottomMargin: Properties.borderThickness
                radius:               Properties.cornerRadius
            }
        }
    }
}

