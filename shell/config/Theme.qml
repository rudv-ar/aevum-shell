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
    readonly property int    pillWidth:      24
    readonly property int    pillHeight:     24
    readonly property int    pillRadius:     12
    readonly property int    pillIconSize:   16
    readonly property int    pillTopPad:     0
    readonly property string nerdFontFamily: "JetBrainsMono Nerd Font"

    // ── Workspace names ───────────────────────────────
    readonly property var workspaceNames: ["1","2","3","4","5", "6", "7", "8"]

    // ── Workspace dot ─────────────────────────────────
    readonly property int   wsDotSize:        8    // width always; height when not focused
    readonly property int   wsDotFocusedSize: 24   // height when focused (elongated pill)
    readonly property int   wsDotRadius:      4    // half of wsDotSize → circle / pill
    readonly property int   wsDotSpacing:     6    // gap between dots

    // ── Workspace dot colors ──────────────────────────
    readonly property color wsDotFocusedColor:  accent
    readonly property color wsDotOccupiedColor: Qt.rgba(text.r, text.g, text.b, 0.6)
    readonly property color wsDotEmptyColor:    Qt.rgba(surface1.r, surface1.g, surface1.b, 0.4)

    // ── Indicator container ───────────────────────────
    readonly property int   wsIndicatorPadX:      6
    readonly property int   wsIndicatorPadY:      8
    readonly property int   wsIndicatorRadius:    8
    readonly property color wsIndicatorBg:        Qt.rgba(1, 1, 1, 0.06)
    readonly property color wsIndicatorBgHovered: Qt.rgba(1, 1, 1, 0.08)
    readonly property int   wsIndicatorTopGap:    10   // gap below launcher pill
    readonly property int   wsAnimDuration:       150
    readonly property bool wsGlyphMode: true
}
