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
    readonly property color base:      "#181b1f"
    readonly property color surface0:  "#181b1f"
    readonly property color surface1:  "#45475a"
    readonly property color accent:    "#cba6f7"
    readonly property color text:      "#cdd6f4"
    readonly property color textColor: "#ffffff"
    readonly property color launcherBg: Qt.rgba(1, 1, 1, 0.06)

    // ── Semantic ──────────────────────────────────────
    readonly property color frameColor: surface0

    // ── Launcher pill ─────────────────────────────────
    readonly property int    pillWidth:      28
    readonly property int    pillHeight:     28
    readonly property int    pillRadius:     16
    readonly property int    pillIconSize:   16
    readonly property int    pillTopPad:     0
    readonly property string nerdFontFamily: "Material Design Icons"
    readonly property bool showDesktopNumbers: false

}
