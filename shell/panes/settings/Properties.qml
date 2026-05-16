pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell

Singleton {
    // ── Border frame ────────────────────────────────────────────────
    readonly property real borderThickness:   10
    readonly property real cornerRadius:      18
    readonly property real marginCover:       32   // px from top where frame begins (bar height)
    readonly property real topOffset:         4   // top of the hole (bar + small gap)
    readonly property int  animDuration:      300

    // ── Pane dimensions ─────────────────────────────────────────────
    readonly property real panelWidth:        320  // left / right panes
    readonly property real panelHeight:       280  // top  / bottom panes

    // Gap between pane content and the screen edge, inside the border
    readonly property real panelRightMargin:  10
    readonly property real panelLeftMargin:   10
    readonly property real panelTopMargin:    10
    readonly property real panelBottomMargin: 10
}
