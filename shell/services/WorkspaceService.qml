pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root

    property var    desktops:    []
    property string focusedName: ""

    function switchTo(name) {
        _switchProc.command = ["bspc", "desktop", "-f", name]
        _switchProc.running = true
    }

    property var _occupiedNames: []
    property int _queryPending:  0

    // ── Subscribe: restart on every event ─────────────
    Process {
        id: _subscribeProc
        command: ["bspc", "subscribe", "-c", "1",
                  "desktop_focus", "node_add", "node_remove", "node_transfer"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root._startQuery()
                _subscribeProc.running = false
                _subscribeProc.running = true
            }
        }
    }

    // ── Query focused desktop ─────────────────────────
    Process {
        id: _focusedProc
        command: ["bspc", "query", "-D", "-d", "focused", "--names"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.focusedName = this.text.trim()
                root._queryPending--
                if (root._queryPending === 0) root._rebuildDesktops()
            }
        }
    }

    // ── Query occupied desktops ───────────────────────
    Process {
        id: _occupiedProc
        command: ["bspc", "query", "-D", "-d", ".occupied", "--names"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.trim().split("\n")
                root._occupiedNames = lines.filter(function(s) { return s.length > 0 })
                root._queryPending--
                if (root._queryPending === 0) root._rebuildDesktops()
            }
        }
    }

    // ── Switch ────────────────────────────────────────
    Process {
        id: _switchProc
        running: false
    }

    Component.onCompleted: _startQuery()

    function _startQuery() {
        _queryPending         = 2
        _focusedProc.running  = false
        _focusedProc.running  = true
        _occupiedProc.running = false
        _occupiedProc.running = true
    }

    function _rebuildDesktops() {
        var result = []
        var names  = Theme.workspaceNames
        for (var i = 0; i < names.length; i++) {
            var name = names[i]
            var state
            if (name === focusedName)
                state = "focused"
            else if (_occupiedNames.indexOf(name) !== -1)
                state = "occupied"
            else
                state = "empty"
            result.push({ name: name, state: state })
        }
        desktops = result
    }
}
