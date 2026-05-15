import QtQuick
import Quickshell
import qs.modules
import qs.settings

ShellRoot {
    PanelWindow {
        id: win

        anchors.right:  true
        anchors.bottom: true
        exclusiveZone:  0

        margins {
            right:  10
            bottom: 10
        }

        implicitWidth:  Properties.notifBackgroundWidth
        implicitHeight: Properties.notifBackgroundHeight

        color: "transparent"

        NotifBackground {
            id: notifBg
            anchors.right:  parent.right
            anchors.bottom: parent.bottom
        }

        mask: Region {
            item: inputArea
        }

        Item {
            id: inputArea
            anchors.right:  parent.right
            anchors.bottom: parent.bottom
            width:  Properties.notifBackgroundWidth
            height: notifBg.drawnH + 15
        }
    }
}
