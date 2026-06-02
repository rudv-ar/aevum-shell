pragma ComponentBehavior: Bound

import QtQuick
import qs.config

Item {
    id: root

    required property Repeater workspaces
    required property var      occupied   // { desktopName: bool }

    // ── Rebuild pill groups when occupancy changes ────
    onOccupiedChanged: Qt.callLater(_rebuild)
    onWorkspacesChanged: Qt.callLater(_rebuild)
    Component.onCompleted: Qt.callLater(_rebuild)

    function _rebuild() {
        pillModel.clear()
        var inGroup = false
        var startIdx = 0

        for (var i = 0; i < workspaces.count; i++) {
            var ws = workspaces.itemAt(i)
            if (!ws) continue
            var occ = occupied[ws.desktopName] ?? false

            if (occ && !inGroup) {
                startIdx = i
                inGroup  = true
            }
            if (!occ && inGroup) {
                pillModel.append({ startIdx: startIdx, endIdx: i - 1 })
                inGroup = false
            }
        }
        // close last group if still open
        if (inGroup)
            pillModel.append({ startIdx: startIdx, endIdx: workspaces.count - 1 })
    }

    // ── Pill data ─────────────────────────────────────
    ListModel {
        id: pillModel
    }

    // ── Render pills ──────────────────────────────────
    Repeater {
        model: pillModel

        Rectangle {
            required property int startIdx
            required property int endIdx

            readonly property var startItem: root.workspaces.count > startIdx
                                             ? root.workspaces.itemAt(startIdx) : null
            readonly property var endItem:   root.workspaces.count > endIdx
                                             ? root.workspaces.itemAt(endIdx)   : null

            anchors.horizontalCenter: parent.horizontalCenter
            y:      startItem ? startItem.y - 1 : 0
            width:  Theme.pillWidth - 2
            height: (startItem && endItem)
                    ? endItem.y + endItem.implicitHeight - startItem.y + 2
                    : 0
            radius: Theme.pillRadius
            color:  Theme.wsOccupiedBg
            visible: height > 2

            Behavior on y      { NumberAnimation { duration: 0; easing.type: Easing.OutCubic } }
            Behavior on height { NumberAnimation { duration: 0; easing.type: Easing.OutCubic } }
        }
    }
}
