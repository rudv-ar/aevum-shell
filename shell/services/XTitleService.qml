pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ── Public state ──────────────────────────────────
    property string title:        ""
    property string className:    ""
    property string displayTitle: ""

    // ── Format title for display ──────────────────────
    function _formatTitle(raw) {
        var s = (!raw || !raw.trim().length) ? "Desktop" : raw.trim()
        displayTitle = s.length > 5 ? s.substring(0, 5) + "…" : s
    }

    // ── Live title stream (xtitle -s) ─────────────────
    Process {
        command: ["xtitle", "-s", "-f", "%s\n"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                root.title = line
                root._formatTitle(line)
                root._queryClass()
            }
        }
    }

    // ── One-shot: resolve className via bspc ──────────
    function _queryClass() {
        if (!classProc.running)
            classProc.running = true
    }

    Process {
        id: classProc
        command: ["bspc", "query", "-T", "-n", "focused"]
        running: false
        stdout: SplitParser {
            onRead: line => {
                try {
                    var node = JSON.parse(line)
                    root.className = node.client?.className ?? ""
                } catch (e) {}
            }
        }
        onRunningChanged: {
            if (!running) running = false
        }
    }
}
