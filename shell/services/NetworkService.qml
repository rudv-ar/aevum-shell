pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ── State ─────────────────────────────────────────
    readonly property list<QtObject> networks: []
    readonly property QtObject active: {
        for (const n of networks) if (n.active) return n
        return null
    }

    property bool         wifiEnabled:           true
    property bool         isConnected:           false
    property string       activeInterface:       "wlan0"
    property string       activeConnection:      ""
    readonly property bool scanning:             rescanProc.running

    property list<string> savedConnections:      []
    property list<var>    wirelessInterfaces:    []
    property var          wirelessDeviceDetails: null
    property var          pendingConnection:     null
    property list<var>    activeProcesses:       []

    // Ethernet stubs (iwd is wifi-only)
    property list<var>    ethernetDevices:       []
    readonly property var activeEthernet:        null
    property list<var>    ethernetInterfaces:    []
    property var          ethernetDeviceDetails: null

    signal connectionFailed(string ssid)

    // ── Core executor ─────────────────────────────────
    function executeCommand(args: list<string>, callback: var): void {
        const proc    = commandProc.createObject(root)
        proc.cmdArgs  = ["iwctl", ...args]
        proc.callback = callback
        activeProcesses.push(proc)
        proc.processFinished.connect(() => {
            const idx = activeProcesses.indexOf(proc)
            if (idx >= 0) activeProcesses.splice(idx, 1)
        })
        Qt.callLater(() => proc.exec(proc.cmdArgs))
    }

    // ── Read: wifi networks ───────────────────────────
    function getNetworks(callback: var): void {
        executeCommand(["station", activeInterface, "show"], showResult => {
            const connectedSsid = parseStationShow(showResult.output)
            executeCommand(["station", activeInterface, "get-networks"], result => {
                if (!result.success) { callback?.([]); return }

                const fresh  = parseNetworkOutput(result.output, connectedSsid)
                const rNets  = root.networks
                const newMap = new Map()
                for (const n of fresh) newMap.set(n.ssid, n)

                for (let i = rNets.length - 1; i >= 0; i--) {
                    const rn = rNets[i]
                    if (!newMap.has(rn.ssid)) { rNets.splice(i, 1); rn.destroy() }
                }
                const existing = new Map()
                for (const rn of rNets) existing.set(rn.ssid, rn)
                for (const [key, n] of newMap) {
                    const match = existing.get(key)
                    if (match) match.lastIpcObject = n
                    else rNets.push(apComp.createObject(root, { lastIpcObject: n }))
                }
                callback?.(root.networks)
                checkPendingConnection()
            })
        })
    }

    // ── Read: wifi status ─────────────────────────────
    function getWifiStatus(callback: var): void {
        executeCommand(["device", "list"], result => {
            if (!result.success) { callback?.(false); return }
            const line = result.output.split("\n")
                .find(l => l.replace(/\x1B\[[0-9;]*m/g, "").includes(activeInterface))
            root.wifiEnabled = line ? line.replace(/\x1B\[[0-9;]*m/g, "").includes(" on ") : false
            callback?.(root.wifiEnabled)
        })
    }

    // ── Read: interfaces ──────────────────────────────
    function getWirelessInterfaces(callback: var): void {
        executeCommand(["device", "list"], result => {
            root.wirelessInterfaces = parseDeviceList(result.output)
            callback?.(root.wirelessInterfaces)
        })
    }

    function getEthernetInterfaces(callback: var): void { callback?.([]) }

    // ── Read: device details ──────────────────────────
    function getWirelessDeviceDetails(interfaceName: string, callback: var): void {
        const iface = interfaceName || activeInterface
        executeCommand(["station", iface, "show"], result => {
            root.wirelessDeviceDetails = result.success
                ? parseStationDetails(result.output) : null
            callback?.(root.wirelessDeviceDetails)
        })
    }

    function getEthernetDeviceDetails(interfaceName: string, callback: var): void {
        callback?.(null)
    }

    // ── Read: saved connections ───────────────────────
    function loadSavedConnections(callback: var): void {
        executeCommand(["known-networks", "list"], result => {
            if (!result.success) { root.savedConnections = []; callback?.([]); return }
            root.savedConnections = parseKnownNetworks(result.output)
            callback?.(root.savedConnections)
        })
    }

    // ── Write: wifi toggle ────────────────────────────
    function enableWifi(enabled: bool, callback: var): void {
        executeCommand(["device", activeInterface, "set-property", "Powered", enabled ? "on" : "off"],
            result => {
                if (result.success) root.wifiEnabled = enabled
                callback?.(result)
            })
    }

    function toggleWifi(callback: var): void { enableWifi(!wifiEnabled, callback) }

    function rescanWifi(): void { rescanProc.running = true }

    // ── Write: connect wifi ───────────────────────────
    function connectToNetwork(ssid: string, password: string, bssid: string, callback: var): void {
        connectWireless(ssid, password, callback)
    }

    function connectToNetworkWithPasswordCheck(ssid: string, isSecure: bool, callback: var, bssid: string): void {
        connectWireless(ssid, "", result => {
            if (result.success) {
                callback?.({ success: true, usedSavedPassword: true, output: result.output, error: "", exitCode: 0 })
            } else {
                callback?.(result)
            }
        })
    }

    function connectWireless(ssid: string, password: string, callback: var): void {
        root.pendingConnection = { ssid, callback }
        connectionCheckTimer.start()
        immediateCheckTimer.checkCount = 0
        immediateCheckTimer.start()

        const args = password
            ? ["--passphrase=" + password, "station", activeInterface, "connect", ssid]
            : ["station", activeInterface, "connect", ssid]

        executeCommand(args, result => {
            if (result.needsPassword) { callback?.(result) }
        })
    }

    // ── Write: disconnect ─────────────────────────────
    function disconnectFromNetwork(): void {
        executeCommand(["station", activeInterface, "disconnect"],
            result => { if (result.success) getNetworks(() => {}) })
    }

    function disconnect(interfaceName: string, callback: var): void {
        executeCommand(["station", interfaceName || activeInterface, "disconnect"],
            result => callback?.(result.success ? result.output : ""))
    }

    // ── Write: forget network ─────────────────────────
    function forgetNetwork(ssid: string, callback: var): void {
        if (!ssid) { callback?.({ success: false }); return }
        executeCommand(["known-networks", ssid, "forget"], result => {
            if (result.success) Qt.callLater(() => loadSavedConnections(() => {}), 500)
            callback?.(result)
        })
    }

    // Ethernet stubs
    function connectEthernet(connectionName: string, interfaceName: string, callback: var): void {
        callback?.({ success: false, error: "Ethernet not supported by iwd" })
    }
    function disconnectEthernet(connectionName: string, callback: var): void {
        callback?.({ success: false, error: "Ethernet not supported by iwd" })
    }

    // ── Helpers ───────────────────────────────────────
    function hasSavedProfile(ssid: string): bool {
        if (!ssid) return false
        const low = ssid.toLowerCase().trim()
        return active?.ssid?.toLowerCase() === low
            || savedConnections.some(s => s.toLowerCase().trim() === low)
    }

    function isConnectedState(state: string): bool {
        return !!state && state === "connected"
    }

    function refreshOnConnectionChange(): void {
        getNetworks(() => {})
        getWirelessInterfaces(() => {})
    }

    function checkPendingConnection(): void {
        if (!pendingConnection) return
        Qt.callLater(() => {
            if (root.active?.ssid === root.pendingConnection?.ssid) {
                connectionCheckTimer.stop(); immediateCheckTimer.stop()
                root.pendingConnection?.callback?.({ success: true, output: "Connected", error: "", exitCode: 0 })
                root.pendingConnection = null
            }
        })
    }

    function detectPasswordRequired(error: string): bool {
        if (!error) return false
        return error.includes("passphrase") || error.includes("PSK") ||
               error.includes("credentials") || error.includes("password")
    }

    function handlePasswordRequired(proc: var, error: string, output: string, code: int): bool {
        if (!proc || !error || !pendingConnection?.callback) return false
        if (!detectPasswordRequired(error) || proc.callbackCalled) return false
        connectionCheckTimer.stop(); immediateCheckTimer.stop()
        immediateCheckTimer.checkCount = 0
        const pending = root.pendingConnection; root.pendingConnection = null
        proc.callbackCalled = true
        const result = { success: false, output, error, exitCode: code, needsPassword: true }
        pending.callback?.(result)
        if (proc.callback && proc.callback !== pending.callback) proc.callback?.(result)
        return true
    }

    // ── Parsers ───────────────────────────────────────
    function parseStationShow(output: string): string {
        if (!output) return ""
        for (const line of output.split("\n")) {
            const clean = line.replace(/\x1B\[[0-9;]*m/g, "")
            const match = clean.match(/Connected network\s+(.+)/)
            if (match) return match[1].trim()
        }
        return ""
    }

    function parseStationDetails(output: string): var {
        const d = {
            ipAddress: "", ipv6Address: "", gateway: "", dns: [],
            macAddress: "", state: "", ssid: "", frequency: 0,
            rssi: 0, security: ""
        }
        if (!output) return d
        for (const line of output.split("\n")) {
            const clean = line.replace(/\x1B\[[0-9;]*m/g, "")
            const match = clean.match(/^\s+(\S.*\S)\s{2,}(.+)$/)
            if (!match) continue
            const key = match[1].trim(), val = match[2].trim()
            if      (key === "State")             d.state       = val
            else if (key === "Connected network") d.ssid        = val
            else if (key === "IPv4 address")      d.ipAddress   = val
            else if (key === "IPv6 address")      d.ipv6Address = val
            else if (key === "Frequency")         d.frequency   = parseInt(val)
            else if (key === "RSSI")              d.rssi        = parseInt(val)
            else if (key === "Security")          d.security    = val
        }
        return d
    }

    // Signal bars **** → 0-100
    function signalToStrength(signal: string): int {
        const stars = (signal.match(/\*/g) || []).length
        return Math.round((stars / 4) * 100)
    }

    function parseNetworkOutput(output: string, connectedSsid: string): list<var> {
        if (!output) return []
        const results = []
        for (const line of output.split("\n")) {
            const clean = line.replace(/\x1B\[[0-9;]*m/g, "").trim()
            if (!clean || clean.startsWith("-") || clean.startsWith("Network name") ||
                clean.startsWith("Available")) continue
            // Match: optional "> " prefix (connected marker), then name, security, signal
            const match = clean.match(/^(>\s+)?(.+?)\s{2,}(psk|open|8021x)\s{2,}([*]+)/)
            if (!match) continue
            const ssid     = match[2].trim()
            const security = match[3].trim()
            const signal   = match[4].trim()
            if (!ssid) continue
            results.push({
                active:    ssid === connectedSsid,
                strength:  signalToStrength(signal),
                frequency: 0,
                ssid,
                bssid:     "",
                security
            })
        }
        return results
    }

    function parseDeviceList(output: string): list<var> {
        if (!output) return []
        const result = []
        for (const line of output.split("\n")) {
            const clean = line.replace(/\x1B\[[0-9;]*m/g, "").trim()
            if (!clean || clean.startsWith("-") || clean.startsWith("Name") ||
                clean.startsWith("Devices") || clean.startsWith("Available")) continue
            const parts = clean.split(/\s+/)
            if (parts.length < 3) continue
            result.push({
                device:     parts[0],
                macAddress: parts[1] ?? "",
                powered:    parts[2] === "on",
                adapter:    parts[3] ?? "",
                mode:       parts[4] ?? "",
                state:      parts[2] === "on" ? "available" : "unavailable",
                connection: ""
            })
        }
        return result
    }

    function parseKnownNetworks(output: string): list<string> {
        if (!output) return []
        const result = []
        for (const line of output.split("\n")) {
            const clean = line.replace(/\x1B\[[0-9;]*m/g, "").trim()
            if (!clean || clean.startsWith("-") || clean.startsWith("Name") ||
                clean.startsWith("Known")) continue
            const parts = clean.split(/\s{2,}/)
            if (parts[0]) result.push(parts[0].trim())
        }
        return result
    }

    // ── Startup ───────────────────────────────────────
    Component.onCompleted: {
        getWifiStatus(() => {})
        getNetworks(() => {})
        loadSavedConnections(() => {})
        Qt.callLater(() => {
            getWirelessDeviceDetails("", () => {})
            getWirelessInterfaces(() => {})
        }, 2000)
    }

    // ── Background processes ──────────────────────────
    Process {
        id: rescanProc
        command: ["iwctl", "station", root.activeInterface, "scan"]
        onExited: root.getNetworks(() => {}) // qmllint disable signal-handler-parameters
    }

    // Poll every 5s since iwd has no monitor command
    Timer {
        interval: 5000
        running:  true
        repeat:   true
        onTriggered: root.refreshOnConnectionChange()
    }

    Timer {
        id: connectionCheckTimer
        interval: 4000
        onTriggered: {
            if (!root.pendingConnection) return
            if (root.active?.ssid === root.pendingConnection.ssid) {
                root.pendingConnection = null; immediateCheckTimer.stop(); return
            }
            const pending = root.pendingConnection
            root.pendingConnection = null
            immediateCheckTimer.stop(); immediateCheckTimer.checkCount = 0
            root.connectionFailed(pending.ssid)
            pending.callback?.({ success: false, output: "", error: "Connection timeout",
                                  exitCode: -1, needsPassword: false })
        }
    }

    Timer {
        id: immediateCheckTimer
        property int checkCount: 0
        interval: 500
        repeat:   true
        onTriggered: {
            if (!root.pendingConnection) { stop(); checkCount = 0; return }
            checkCount++
            if (root.active?.ssid === root.pendingConnection.ssid) {
                connectionCheckTimer.stop(); stop(); checkCount = 0
                root.pendingConnection.callback?.({ success: true, output: "Connected", error: "", exitCode: 0 })
                root.pendingConnection = null
            } else if (checkCount >= 6) { stop(); checkCount = 0 }
        }
    }

    // ── Components ────────────────────────────────────
    Component {
        id: commandProc
        Process {
            id: proc
            property var          callback:       null
            property list<string> cmdArgs:        []
            property bool         callbackCalled: false
            signal processFinished
            environment: ({ LANG: "C.UTF-8", LC_ALL: "C.UTF-8", TERM: "dumb" })
            stdout: StdioCollector { id: out }
            stderr: StdioCollector { id: err
                onStreamFinished: {
                    const e = text.trim()
                    if (e) root.handlePasswordRequired(proc, e, out.text ?? "", -1)
                }
            }
            onExited: code => { // qmllint disable signal-handler-parameters
                Qt.callLater(() => {
                    if (callbackCalled) { processFinished(); return }
                    const o = out.text ?? "", e = err.text ?? ""
                    if (root.handlePasswordRequired(proc, e, o, code)) { processFinished(); return }
                    callbackCalled = true
                    callback?.({ success: code === 0, output: o, error: e, exitCode: code,
                                 needsPassword: root.detectPasswordRequired(e) })
                    processFinished()
                })
            }
            function exec(args: list<string>): void { command = args; running = true }
        }
    }

    Component {
        id: apComp
        QtObject {
            required property var    lastIpcObject
            readonly property string ssid:      lastIpcObject.ssid
            readonly property string bssid:     lastIpcObject.bssid
            readonly property int    strength:  lastIpcObject.strength
            readonly property int    frequency: lastIpcObject.frequency
            readonly property bool   active:    lastIpcObject.active
            readonly property string security:  lastIpcObject.security
            readonly property bool   isSecure:  security !== "open" && security.length > 0
        }
    }
}
