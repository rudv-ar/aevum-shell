pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import qs.settings
import qs.modules.container

ShellRoot {

    PanelWindow {
        id: win 
        implicitWidth:  Screen.width
        implicitHeight: Screen.height
        color:          "transparent"
        mask:           Region{
            x:      Screen.width - win.animatedRight - Properties.borderThickness - Properties.borderThickness
            y:      Properties.marginCover + Properties.topOffset
            width:  win.animatedRight + Properties.borderThickness + Properties.borderThickness
            height: Screen.height - Properties.marginCover
        }

        property bool paneOpen: false

        property real animatedRight: paneOpen ? Properties.paneWidth : Properties.borderThickness

        Behavior on animatedRight {
          NumberAnimation {
            duration: 30
            easing.type: Easing.OutQuart
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
            anchors.rightMargin: Properties.borderThickness
            anchors.bottomMargin: Properties.borderThickness
            color:             Theme.borderColor
            visible: win.paneOpen
            topRightRadius: Properties.cornerRadius + 1
            bottomRightRadius: Properties.cornerRadius - 3
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
                anchors.bottomMargin: 0
                radius:               Properties.cornerRadius
            }
        }

  }
}
