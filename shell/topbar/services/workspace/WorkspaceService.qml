pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.settings

Singleton {
    id: root

    property var    desktops:    []
    property string focusedName: ""   // ← now public

    function switchTo(name) {
        _switchProc.command = Commands.workspaceSwitch(name)
        _switchProc.running = true
    }

    property var _occupiedNames: []
    property int _queryPending:  0

    Process {
        id: _subscribeProc
        command: Commands.workspaceSubscribe()
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root._startQuery()
                _subscribeProc.running = true
            }
        }
    }

    Process {
        id: _focusedProc
        command: Commands.workspaceFocused()
        stdout: StdioCollector {
            onStreamFinished: {
                root.focusedName = this.text.trim()
                root._queryPending--
                if (root._queryPending === 0) root._rebuildDesktops()
            }
        }
    }

    Process {
        id: _occupiedProc
        command: Commands.workspaceOccupied()
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.trim().split("\n")
                root._occupiedNames = lines.filter(function(s) { return s.length > 0 })
                root._queryPending--
                if (root._queryPending === 0) root._rebuildDesktops()
            }
        }
    }

    Process {
        id: _switchProc
        running: false
    }

    Component.onCompleted: _startQuery()

    function _startQuery() {
        _queryPending        = 2
        _focusedProc.running = true
        _occupiedProc.running = true
    }

    function _rebuildDesktops() {
        var result = []
        var names  = Properties.workspaceNames
        for (var i = 0; i < names.length; i++) {
            var name  = names[i]
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

