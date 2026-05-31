pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import qs.config
import qs.modules.bar

PanelWindow {
    id: root

    required property ShellScreen screen

    // ── Hole margins ──────────────────────────────────
    readonly property int mLeft:   Theme.holeLeft
    readonly property int mTop:    Theme.holeTop
    readonly property int mRight:  Theme.holeRight
    readonly property int mBottom: Theme.holeBottom
    readonly property int mRadius: Theme.holeRadius

    readonly property color frameCol: Theme.frameColor

    // ── Hole rect ─────────────────────────────────────
    readonly property int hX: mLeft
    readonly property int hY: mTop
    readonly property int hW: width  - mLeft - mRight
    readonly property int hH: height - mTop  - mBottom

    // ── Click mask ────────────────────────────────────
    readonly property int maskX: hX + Theme.holeTop
    readonly property int maskY: hY + Theme.holeBottom
    readonly property int maskW: hW - Theme.holeRight
    readonly property int maskH: hH - 2 * Theme.holeRight

    screen:         root.screen
    anchors.top:    true
    anchors.bottom: true
    anchors.left:   true
    anchors.right:  true
    exclusionMode:  ExclusionMode.Ignore
    color:          "transparent"

    mask: Region {
        item:         clickHole
        intersection: Intersection.Xor
    }

    Item {
        id:     clickHole
        x:      root.maskX
        y:      root.maskY
        width:  root.maskW
        height: root.maskH
    }

    // ── Frame ─────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color:        root.frameCol

        layer.enabled: true
        layer.effect: MultiEffect {
            maskSource:       holeShape
            maskEnabled:      true
            maskInverted:     true
            maskThresholdMin: 0.5
            maskSpreadAtMin:  1.0
        }
    }

    Item {
        id:            holeShape
        anchors.fill:  parent
        layer.enabled: true
        visible:       false

        Rectangle {
            x:      root.hX
            y:      root.hY
            width:  root.hW
            height: root.hH
            radius: root.mRadius
        }
    }

    // ── Launcher pill ─────────────────────────────────
    Launcher {
        x: Math.round((root.mLeft - Theme.pillWidth)  / 2)
        y: root.mTop + Theme.pillTopPad
        z: 10
        onLeftClicked:  function () { }
        onRightClicked: function () { }
    }

    // ── Workspace indicator ───────────────────────────
    WsIndicator {
        x: 0
        y: root.mTop
            + Theme.pillTopPad
            + Theme.pillHeight
            + Theme.wsIndicatorTopGap
        z: 10
    }
}  
