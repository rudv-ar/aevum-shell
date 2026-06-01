pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.services

Item {
    id: root

    required property ShellScreen screen

    // ── Data from BspwmService ─────────────────────────
    readonly property var desktops: {
        // Explicitly reference monitors to establish binding dependency
        var mons = BspwmService.monitors
        for (var i = 0; i < mons.length; i++)
            if (mons[i].name === screen.name)
                return mons[i].desktops
        return []
    }

    readonly property string focusedDesktop: BspwmService.focusedDesktop

    readonly property int activeDtIdx: {
        var dts = root.desktops
        var foc = root.focusedDesktop
        for (var i = 0; i < dts.length; i++)
            if (dts[i].name === foc) return i
        return 0
    }

    // { desktopName: bool } — true if occupied
    readonly property var occupied: {
        var dts = root.desktops
        var o   = {}
        for (var i = 0; i < dts.length; i++)
            o[dts[i].name] = "OoUu".indexOf(dts[i].state) !== -1
        return o
    }

    // ── Sizing ─────────────────────────────────────────
    implicitWidth:  Theme.pillWidth
    implicitHeight: layout.implicitHeight
// ── Container background pill ──────────────────────
    Rectangle {
        visible: Theme.colorWorkspaceIndicator
        anchors.top:    layout.top 
        anchors.bottom: layout.bottom 
        anchors.left: parent.left 
        anchors.right: parent.right
        anchors.margins: 0
        anchors.topMargin: 0
        anchors.rightMargin: 1
        anchors.leftMargin: 0
        anchors.bottomMargin: 0
        radius:          Theme.pillRadius
        color:           Theme.colorWorkspaceIndicator ? Qt.rgba(1, 1, 1, 0.07) : "transparent"
    }
    // ── Occupied background pills ──────────────────────
    OccupiedBg {
        anchors.fill:   layout
        workspaces:     wsRepeater
        occupied:       root.occupied
    }

    // ── Workspace column ───────────────────────────────
    ColumnLayout {
        id:      layout
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 3

        Repeater {
            id: wsRepeater
            model: root.desktops

            Workspace {
                required property var modelData
                required property int index

                desktopName: modelData.name
                isActive:    root.activeDtIdx === index
                isOccupied:  root.occupied[modelData.name] ?? false
                isUrgent:    modelData.state === 'U' || modelData.state === 'u'
            }
        }
    }

    // ── Active indicator overlay ───────────────────────
    ActiveIndicator {
        anchors.left:   layout.left
        anchors.right:  layout.right
        anchors.top:    layout.top
        height:         layout.implicitHeight
        activeDtIdx:    root.activeDtIdx
        workspaces:     wsRepeater
    }

    // ── Click to switch desktop ────────────────────────
    MouseArea {
        anchors.fill: layout
        cursorShape:  Qt.PointingHandCursor
        onClicked: (event) => {
            for (var i = 0; i < wsRepeater.count; i++) {
                var ws = wsRepeater.itemAt(i)
                if (!ws) continue
                // map event position into each workspace's coordinate space
                var local = mapToItem(ws, event.x, event.y)
                if (local.x >= 0 && local.x <= ws.width &&
                    local.y >= 0 && local.y <= ws.height) {
                    BspwmService.dispatch("desktop -f " + ws.desktopName)
                    break
                }
            }
        }
    }
}
