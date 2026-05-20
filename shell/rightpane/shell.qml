pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import qs.settings
import qs.modules

ShellRoot {

    PanelWindow {
        id: win 
        implicitWidth:  Screen.width
        implicitHeight: Screen.height
        color:          "transparent"
        mask:           Region{}

        property bool paneOpen: false

        property real animatedRight: paneOpen ? Properties.paneWidth : Properties.borderThickness

        Behavior on animatedRight {
            SpringAnimation {
                spring:  7
                damping: 0.6
                mass:    1
                epsilon: 0.5
            }
        }

        IpcHandler {
            target: "rightpane"

            function toggle(): void { win.paneOpen = !win.paneOpen }
            function open(): void   { win.paneOpen = true          }
            function close(): void  { win.paneOpen = false         }
        }

        // ── Visible surface ───────────────────────────────────
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

        PaneContent{}

        // ── Mask hole ─────────────────────────────────────────
        Item {
            id: innerMask
            anchors.fill: parent
            layer.enabled: true
            visible: false

            Rectangle {
                anchors.fill:         parent
                anchors.topMargin:    Properties.topOffset
                anchors.leftMargin:   Properties.borderThickness
                anchors.rightMargin:  win.animatedRight
                anchors.bottomMargin: Properties.borderThickness
                radius:               Properties.cornerRadius
            }
        }

  }
}
