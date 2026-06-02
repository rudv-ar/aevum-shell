import QtQuick
import qs.config

Item {
    id: root

    required property int     activeDtIdx
    required property Repeater workspaces

    // ── Track active workspace geometry ───────────────
    readonly property var  _item:    workspaces.count > root.activeDtIdx
                                     ? workspaces.itemAt(root.activeDtIdx)
                                     : null
    readonly property real _targetY: _item ? _item.y              : 0
    readonly property real _targetH: _item ? _item.size           : 16

    // ── Stretchy leading / trailing ───────────────────
    // Both animate toward _targetY, but at different speeds.
    // The gap between them during transition creates the stretch effect.
    property real leading:  _targetY
    property real trailing: _targetY

    // When target changes, explicitly assign so Behavior fires on both
    on_TargetYChanged: {
        leading  = _targetY
        trailing = _targetY
    }

    // ── Pill ──────────────────────────────────────────
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        y:       Math.min(root.leading, root.trailing)
        width:   Theme.pillWidth - 4
        height:  Math.abs(root.leading - root.trailing) + root._targetH
        radius:  Theme.pillRadius
        color:   Theme.wsActiveBg
        opacity: 0.28

        Behavior on height {
            NumberAnimation { duration: 80; easing.type: Easing.OutCubic }
        }
    }

    // leading is fast — moves to the target quickly
    Behavior on leading {
        NumberAnimation { duration: 0; easing.type: Easing.OutCubic }
    }

    // trailing is slow — lags behind, creating the stretch
    Behavior on trailing {
        NumberAnimation { duration: 0; easing.type: Easing.OutCubic }
    }
}
