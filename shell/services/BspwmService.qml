pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ── Public state ──────────────────────────────────
    // [{name, focused, desktops: [{name, state}]}]
    // state chars: O=occupied focused  o=occupied unfocused
    //              F=free focused      f=free unfocused
    //              U=urgent focused    u=urgent unfocused
    property var    monitors:       []
    property string focusedMonitor: ""
    property string focusedDesktop: ""

    // ── Signals ───────────────────────────────────────
    signal windowsChanged()

    // ── Dispatch ──────────────────────────────────────
    function dispatch(cmd) {
        if (dispatchProc.running) return
        dispatchProc.command = ["bspc"].concat(cmd.trim().split(/\s+/))
        dispatchProc.running = true
    }

    // ── Report parser ─────────────────────────────────
    function _parseReport(line) {
        if (!line.length) return

        var items   = line.split(":")
        var mons    = []
        var cur     = null
        var focMon  = ""
        var focDt   = ""

        for (var i = 0; i < items.length; i++) {
            var item = items[i]
            if (!item.length) continue
            var t = item[0]
            var v = item.slice(1)

            if (t === 'M') {
                cur = { name: v, focused: true, desktops: [] }
                mons.push(cur)
                focMon = v
            } else if (t === 'm') {
                cur = { name: v, focused: false, desktops: [] }
                mons.push(cur)
            } else if (cur && "OoFfUu".indexOf(t) !== -1) {
                cur.desktops.push({ name: v, state: t })
                if ("OFU".indexOf(t) !== -1 && cur.focused)
                    focDt = v
            }
        }

        monitors       = mons
        focusedMonitor = focMon
        focusedDesktop = focDt
    }

    // ── Bootstrap: get initial state immediately ──────
    Process {
        command: ["bspc", "subscribe", "report", "--count", "1"]
        running: true
        stdout: SplitParser {
            onRead: line => root._parseReport(line)
        }
    }

    // ── Live report stream ────────────────────────────
    Process {
        command: ["bspc", "subscribe", "report"]
        running: true
        stdout: SplitParser {
            onRead: line => root._parseReport(line)
        }
    }

    // ── Node events → signal WindowService ───────────
    Process {
        command: ["bspc", "subscribe",
                  "node_add", "node_remove", "node_transfer"]
        running: true
        stdout: SplitParser {
            onRead: _ => root.windowsChanged()
        }
    }

    // ── One-shot dispatch ─────────────────────────────
    Process {
        id: dispatchProc
        running: false
    }
}
