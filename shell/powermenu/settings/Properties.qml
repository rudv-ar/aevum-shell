pragma Singleton
import QtQuick
import Quickshell.Io
import Quickshell

Singleton {
    id: root

    // ── Menu ──────────────────────────────────────────────────────────────────
    property int powerMenuWidthInitial:  0
    property int powerMenuWidthExpanded: 75
    property int powerMenuHeight:        280
    property int powerMenuBorderWidth:   1
    property int powerMenuImplicitWidth: 80

    // ── Derived from borders ───────────────────────────────────────────────────
    property int powerMenuCornerRadius:   18
    property int powerMenuShoulderRadius: 18
    property real boardPadding:           10

    // ── Board ─────────────────────────────────────────────────────────────────
    property real   boardUptimeStripWidth: 38
    property real   boardUptimeFontSize:   13

    // ── Pill ──────────────────────────────────────────────────────────────────
    property real pillWidth:    46
    property real pillHeight:   46
    property real pillRadius:   14
    property real pillIconSize: 20
    property real pillSpacing:  8

    FileView {
        id: configFile
        path: Quickshell.env("HOME") + "/.config/aevum/settings/config.json"
        watchChanges: true
        onFileChanged: retryTimer.restart()

        JsonAdapter {
            property var shell: ({})

            onShellChanged: {
                var b  = shell["borders"]   ?? {}
                var pm = shell["powerMenu"] ?? {}
                var mn = pm["menu"]         ?? {}
                var bd = pm["board"]        ?? {}
                var pl = pm["pill"]         ?? {}

                // derived from borders
                root.powerMenuCornerRadius   = b["cornerRadius"] ?? 18
                root.powerMenuShoulderRadius = b["cornerRadius"] ?? 18
                root.boardPadding            = b["thickness"]    ?? 10

                // menu
                root.powerMenuWidthInitial  = mn["normalWidth"]   ?? 0
                root.powerMenuWidthExpanded = mn["expandedWidth"] ?? 75
                root.powerMenuHeight        = mn["normalHeight"]  ?? 280
                root.powerMenuBorderWidth   = mn["borderWidth"]   ?? 1
                root.powerMenuImplicitWidth = mn["implicitWidth"] ?? 80

                // board
                root.boardUptimeStripWidth = bd["uptimeStripWidth"] ?? 38
                root.boardUptimeFontSize   = bd["uptimeFontSize"]   ?? 13

                // pill
                root.pillWidth    = pl["width"]    ?? 46
                root.pillHeight   = pl["height"]   ?? 46
                root.pillRadius   = pl["radius"]   ?? 14
                root.pillIconSize = pl["iconSize"] ?? 20
                root.pillSpacing  = pl["spacing"]  ?? 8
            }
        }
    }

    Timer {
        id: retryTimer
        interval: 200
        repeat: false
        onTriggered: configFile.reload()
    }
}
