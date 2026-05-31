pragma Singleton

import QtQuick
import Quickshell

Singleton {
    // ── Hole margins ───────────────────────────────────
    readonly property int holeLeft:   35
    readonly property int holeTop:    10
    readonly property int holeRight:  10
    readonly property int holeBottom: 10
    readonly property int holeRadius: 12

    // ── Palette (Catppuccin Mocha) ─────────────────────
    readonly property color base:     "#181b1f"
    readonly property color surface0: "#181b1f"
    readonly property color surface1: "#45475a"
    readonly property color accent:   "#cba6f7"
    readonly property color text:     "#cdd6f4"
    readonly property color textColor: "#ffffff"
    readonly property color launcherBg: Qt.lighter(base, 3.0)

    // ── Semantic ──────────────────────────────────────
    readonly property color frameColor: surface0

    // ── Launcher pill ─────────────────────────────────
    readonly property int    pillWidth:      24
    readonly property int    pillHeight:     24
    readonly property int    pillRadius:     12   // width/2 → perfect capsule ends
    readonly property int    pillIconSize:   16
    readonly property int    pillTopPad:     0   // gap from mTop to pill top edge
    readonly property string nerdFontFamily: "JetBrainsMono Nerd Font"
}
