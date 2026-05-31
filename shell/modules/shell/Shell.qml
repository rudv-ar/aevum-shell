pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import qs.config
import qs.modules.bar          // ← new

PanelWindow {
    id: root

    // ── Required ──────────────────────────────────────
    required property ShellScreen screen

    // ── Hole margins ──────────────────────────────────
    readonly property int mLeft:   Theme.holeLeft
    readonly property int mTop:    Theme.holeTop
    readonly property int mRight:  Theme.holeRight
    readonly property int mBottom: Theme.holeBottom
    readonly property int mRadius: Theme.holeRadius

    // ── Color ─────────────────────────────────────────
    readonly property color frameCol: Theme.frameColor

    // ── Hole rect ─────────────────────────────────────
    readonly property int hX: mLeft
    readonly property int hY: mTop
    readonly property int hW: width  - mLeft - mRight
    readonly property int hH: height - mTop  - mBottom

    // ── Click mask bounds ─────────────────────────────
    readonly property int maskX: hX + Theme.holeTop
    readonly property int maskY: hY + Theme.holeBottom
    readonly property int maskW: hW - Theme.holeRight
    readonly property int maskH: hH - 2 * Theme.holeRight

    // ── Window ────────────────────────────────────────
    screen:         root.screen
    anchors.top:    true
    anchors.bottom: true
    anchors.left:   true
    anchors.right:  true
    exclusionMode:  ExclusionMode.Ignore
    color:          "transparent"

    // ── Click mask ────────────────────────────────────
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

    // ── Frame with hole punched via MultiEffect ────────
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

    // ── Hole shape source ─────────────────────────────
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

    // ── Launcher pill (left strip, near top) ──────────
    // x: centered in the 35px left strip
    // y: mTop + pillTopPad so it breathes below the frame edge
    Launcher {
        x: Math.round((root.mLeft - Theme.pillWidth)  / 2)
        y: root.mTop + Theme.pillTopPad
        z: 10   // above frame rectangle
        onLeftClicked: function () { }
        onRightClicked: function () { }
    }
}
