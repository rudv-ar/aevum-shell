pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ── Public state ──────────────────────────────────
    // { "1": ["firefox","kitty"], "2": ["code"], ... }
    property var windowsByDesktop: ({})

    // ── Internal queue ────────────────────────────────
    property var    _queue:  []
    property bool   _busy:   false
    property string _curDt:  ""
    property string _buf:    ""

    // ── API ───────────────────────────────────────────
    function refreshAll() {
        var names = []
        var mons  = BspwmService.monitors   // explicit dep for binding reactivity

        for (var i = 0; i < mons.length; i++) {
            var dts = mons[i].desktops
            for (var j = 0; j < dts.length; j++) {
                var dt = dts[j]
                if ("OoUu".indexOf(dt.state) !== -1) {
                    // occupied — queue for query
                    if (_queue.indexOf(dt.name) === -1)
                        _queue.push(dt.name)
                } else {
                    // free — clear stale data
                    if (root.windowsByDesktop.hasOwnProperty(dt.name)) {
                        var m = Object.assign({}, root.windowsByDesktop)
                        delete m[dt.name]
                        root.windowsByDesktop = m
                    }
                }
            }
        }
        _processQueue()
    }

    // ── Queue processing ──────────────────────────────
    function _processQueue() {
        if (_busy || _queue.length === 0) return
        _busy  = true
        _curDt = _queue.shift()
        _buf   = ""
        queryProc.command = ["bspc", "query", "-T", "-d", _curDt]
        queryProc.running = true
    }

    // ── Recursive tree walker ─────────────────────────
    function _extractClasses(node) {
        if (!node) return []
        var result = []
        if (node.client && node.client.className)
            result.push(node.client.className)
        return result
            .concat(_extractClasses(node.firstChild))
            .concat(_extractClasses(node.secondChild))
    }

    // ── Single reusable query process ─────────────────
    Process {
        id: queryProc
        running: false

        stdout: SplitParser {
            // bspc query -T outputs multi-line JSON — accumulate it all
            onRead: line => root._buf += line
        }

        onRunningChanged: {
            if (running) return
            try {
                var tree    = JSON.parse(root._buf)
                var classes = root._extractClasses(tree.root)
                var map     = Object.assign({}, root.windowsByDesktop)
                map[root._curDt] = classes
                root.windowsByDesktop = map
            } catch (e) {
                // parse error: leave existing data for this desktop
            }
            root._busy = false
            root._processQueue()
        }
    }

    // ── React to BspwmService events ─────────────────
    Connections {
        target: BspwmService
        function onWindowsChanged()  { debounce.restart() }
        function onMonitorsChanged() { debounce.restart() }
    }

    // ── Debounce rapid events (e.g. bulk window open) ─
    Timer {
        id: debounce
        interval: 80
        onTriggered: root.refreshAll()
    }

    Component.onCompleted: Qt.callLater(root.refreshAll)
}
