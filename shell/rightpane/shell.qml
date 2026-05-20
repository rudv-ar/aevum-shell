pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import qs.settings

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
                spring:  10
                damping: 0.5
                mass:    0.5
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

        // ── Pane content ──────────────────────────────────────
        Rectangle {
            anchors.top:          parent.top
            anchors.right:        parent.right
            anchors.bottom:       parent.bottom
            anchors.topMargin:    Properties.marginCover + Properties.topOffset
            anchors.bottomMargin: Properties.borderThickness
            anchors.rightMargin:  Properties.borderThickness

            width:   win.animatedRight - Properties.borderThickness - 10
            color:   Theme.surfaceColor
            radius: Properties.cornerRadius
            clip:    true
            enabled: win.paneOpen
            opacity: Math.max(0, (win.animatedRight - Properties.borderThickness - 20) / (Properties.paneWidth - Properties.borderThickness - 20))
            visible: opacity > 0

            Column {
                anchors.top:         parent.top
                anchors.left:        parent.left
                anchors.right:       parent.right
                anchors.topMargin:   5
                anchors.leftMargin:  5
                anchors.rightMargin: 5
                spacing: 16

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:           "Right Pane"
                    color:          Theme.foreground
                    font.pixelSize: 14
                    font.bold:      true
                }

                Rectangle {
                    width:   parent.width
                    height:  1
                    color:   Theme.borderColor
                    opacity: 0.4
                }

                Text {
                    text:           "Content here"
                    color:          Theme.foreground
                    font.pixelSize: 12
                    opacity:        0.6
                }
            }
        }
    }
}
