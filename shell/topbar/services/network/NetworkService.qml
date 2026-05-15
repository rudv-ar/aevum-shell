pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.settings

Singleton {
    id: root

    property bool   connected:  false
    property bool   isWifi:     false
    property string ssid:       ""
    property string ipAddress:  ""
    property string device:     ""

    readonly property string label: {
        if (!connected) return ""
        if (Properties.networkHoverMode === "ip") return ipAddress
        return ssid
    }

    readonly property string iconGlyph: {
        if (!connected) return "\uf071"
        if (isWifi)     return "\uf1eb"
        return                 "\uf6ff"
    }

    property int _queryPending: 0

    Timer {
        interval: Properties.networkPollInterval
        running:  true
        repeat:   true
        onTriggered: root._startQuery()
    }

    Process {
        id: _stateProc
        command: Commands.networkState()
        stdout: StdioCollector {
            onStreamFinished: {
                root._parseState(this.text.trim())
                root._queryPending--
                if (root._queryPending === 0) root._startIpQuery()
            }
        }
    }

    Process {
        id: _ipProc
        stdout: StdioCollector {
            onStreamFinished: {
                root._parseIp(this.text.trim())
            }
        }
    }

    Component.onCompleted: _startQuery()

    function _startQuery() {
        _queryPending      = 1
        _stateProc.running = true
    }

    function _startIpQuery() {
        if (!connected || device === "") return
        _ipProc.command = Commands.networkIp(device)
        _ipProc.running = true
    }

    function _parseState(raw) {
        const lines = raw.split("\n")
        var found   = false
        for (var i = 0; i < lines.length; i++) {
            const parts = lines[i].split(":")
            if (parts.length >= 4
                    && parts[0] === "yes"
                    && parts[3] !== "lo"
                    && (parts[1] === "wifi"
                        || parts[1] === "802-11-wireless"
                        || parts[1] === "802-3-ethernet")) {
                root.connected = true
                root.isWifi    = parts[1] === "wifi" || parts[1] === "802-11-wireless"
                root.ssid      = parts[2]
                root.device    = parts[3]
                found          = true
                break
            }
        }
        if (!found) {
            root.connected = false
            root.isWifi    = false
            root.ssid      = ""
            root.device    = ""
            root.ipAddress = ""
        }
    }

    function _parseIp(raw) {
        const lines = raw.split("\n")
        for (var i = 0; i < lines.length; i++) {
            const parts = lines[i].split(":")
            if (parts.length >= 2 && parts[0].indexOf("IP4.ADDRESS") === 0) {
                root.ipAddress = parts[1].split("/")[0]
                return
            }
        }
        root.ipAddress = ""
    }
}
