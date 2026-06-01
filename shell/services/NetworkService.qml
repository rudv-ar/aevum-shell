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

    property list<var>    ethernetDevices:       []
    readonly property var activeEthernet:        ethernetDevices.find(d => d.connected) ?? null

    property bool         wifiEnabled:           true
    property bool         isConnected:           false
    property string       activeInterface:       ""
    property string       activeConnection:      ""
    readonly property bool scanning:             rescanProc.running

    property list<string> savedConnections:      []
    property list<string> savedConnectionSsids:  []
    property list<var>    wirelessInterfaces:    []
    property list<var>    ethernetInterfaces:    []
    property var          wirelessDeviceDetails: null
    property var          ethernetDeviceDetails: null
    property var          pendingConnection:     null
    property list<var>    activeProcesses:       []
    property int          currentSsidQueryIndex: 0
    property list<var>    wifiConnectionQueue:   []

    signal connectionFailed(string ssid)

    // ── Constants ─────────────────────────────────────
    readonly property string deviceTypeWifi:         "wifi"
    readonly property string deviceTypeEthernet:     "ethernet"
    readonly property string connectionTypeWireless: "802-11-wireless"
    readonly property string securityKeyMgmt:        "802-11-wireless-security.key-mgmt"
    readonly property string securityPsk:            "802-11-wireless-security.psk"
    readonly property string keyMgmtWpaPsk:          "wpa-psk"

    // ── Core executor ─────────────────────────────────
    function executeCommand(args: list<string>, callback: var): void {
        const proc    = commandProc.createObject(root)
        proc.cmdArgs  = ["nmcli", ...args]
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
        executeCommand(["-g", "ACTIVE,SIGNAL,FREQ,SSID,BSSID,SECURITY", "d", "w"], result => {
            if (!result.success) { callback?.([]); return }

            const fresh    = deduplicateNetworks(parseNetworkOutput(result.output))
            const rNets    = root.networks
            const newMap   = new Map()
            for (const n of fresh) newMap.set(`${n.frequency}:${n.ssid}:${n.bssid}`, n)

            for (let i = rNets.length - 1; i >= 0; i--) {
                const rn = rNets[i]
                if (!newMap.has(`${rn.frequency}:${rn.ssid}:${rn.bssid}`)) {
                    rNets.splice(i, 1); rn.destroy()
                }
            }
            const existing = new Map()
            for (const rn of rNets) existing.set(`${rn.frequency}:${rn.ssid}:${rn.bssid}`, rn)
            for (const [key, n] of newMap) {
                const match = existing.get(key)
                if (match) match.lastIpcObject = n
                else rNets.push(apComp.createObject(root, { lastIpcObject: n }))
            }
            callback?.(root.networks)
            checkPendingConnection()
        })
    }

    // ── Read: wifi status ─────────────────────────────
    function getWifiStatus(callback: var): void {
        executeCommand(["radio", "wifi"], result => {
            root.wifiEnabled = result.output.trim() === "enabled"
            callback?.(root.wifiEnabled)
        })
    }

    // ── Read: interfaces ──────────────────────────────
    function getWirelessInterfaces(callback: var): void {
        executeCommand(["-t", "-f", "DEVICE,TYPE,STATE,CONNECTION", "device", "status"], result => {
            root.wirelessInterfaces = parseDeviceStatusOutput(result.output, deviceTypeWifi)
            callback?.(root.wirelessInterfaces)
        })
    }

    function getEthernetInterfaces(callback: var): void {
        executeCommand(["-t", "-f", "DEVICE,TYPE,STATE,CONNECTION", "device", "status"], result => {
            const ifaces = parseDeviceStatusOutput(result.output, deviceTypeEthernet)
            root.ethernetInterfaces = ifaces
            root.ethernetDevices    = ifaces.map(i => ({
                interface:  i.device,
                type:       i.type,
                state:      i.state,
                connection: i.connection,
                connected:  isConnectedState(i.state)
            }))
            callback?.(ifaces)
        })
    }

    // ── Read: device details ──────────────────────────
    function getWirelessDeviceDetails(interfaceName: string, callback: var): void {
        const iface = interfaceName
            || root.wirelessInterfaces.find(i => isConnectedState(i.state))?.device
        if (!iface) { callback?.(null); return }
        executeCommand(["device", "show", iface], result => {
            root.wirelessDeviceDetails = result.success
                ? parseDeviceDetails(result.output, false) : null
            callback?.(root.wirelessDeviceDetails)
        })
    }

    function getEthernetDeviceDetails(interfaceName: string, callback: var): void {
        const iface = interfaceName
            || root.ethernetInterfaces.find(i => isConnectedState(i.state))?.device
        if (!iface) { callback?.(null); return }
        executeCommand(["device", "show", iface], result => {
            root.ethernetDeviceDetails = result.success
                ? parseDeviceDetails(result.output, true) : null
            callback?.(root.ethernetDeviceDetails)
        })
    }

    // ── Read: saved connections ───────────────────────
    function loadSavedConnections(callback: var): void {
        executeCommand(["-t", "-f", "NAME,TYPE", "connection", "show"], result => {
            if (!result.success) {
                root.savedConnections = []; root.savedConnectionSsids = []
                callback?.([]); return
            }
            parseConnectionList(result.output, callback)
        })
    }

    // ── Write: wifi toggle ────────────────────────────
    function enableWifi(enabled: bool, callback: var): void {
        executeCommand(["radio", "wifi", enabled ? "on" : "off"], result => {
            if (result.success) root.wifiEnabled = enabled
            callback?.(result)
        })
    }

    function toggleWifi(callback: var): void { enableWifi(!wifiEnabled, callback) }
    function rescanWifi(): void { rescanProc.running = true }

    // ── Write: connect wifi ───────────────────────────
    function connectToNetwork(ssid: string, password: string, bssid: string, callback: var): void {
        connectWireless(ssid, password, bssid, callback, 0)
    }

    function connectToNetworkWithPasswordCheck(ssid: string, isSecure: bool, callback: var, bssid: string): void {
        if (isSecure) {
            connectWireless(ssid, "", bssid ?? "", result => {
                callback?.(result.success
                    ? { success: true,  usedSavedPassword: true, output: result.output, error: "", exitCode: 0 }
                    : result.needsPassword
                        ? { success: false, needsPassword: true, output: result.output, error: result.error, exitCode: result.exitCode }
                        : result)
            }, 0)
        } else {
            connectWireless(ssid, "", bssid ?? "", callback, 0)
        }
    }

    function connectWireless(ssid: string, password: string, bssid: string, callback: var, retryCount: int): void {
        const retries = retryCount ?? 0
        if (callback) {
            root.pendingConnection      = { ssid, bssid: bssid ?? "", callback, retryCount: retries }
            connectionCheckTimer.start()
            immediateCheckTimer.checkCount = 0
            immediateCheckTimer.start()
        }
        if (password && bssid) {
            createConnectionWithPassword(ssid, bssid.toUpperCase(), password, callback)
            return
        }
        let cmd = ["device", "wifi", "connect", ssid]
        if (password) cmd.push("password", password)
        executeCommand(cmd, result => {
            if (result.needsPassword) { callback?.(result); return }
            if (!result.success && root.pendingConnection && retries < 2)
                Qt.callLater(() => connectWireless(ssid, password, bssid, callback, retries + 1), 1000)
        })
    }

    function createConnectionWithPassword(ssid: string, bssidUpper: string, password: string, callback: var): void {
        checkAndDeleteConnection(ssid, () => {
            executeCommand([
                "connection", "add", "type", deviceTypeWifi,
                "con-name", ssid, "ifname", "*", "ssid", ssid,
                "802-11-wireless.bssid", bssidUpper,
                securityKeyMgmt, keyMgmtWpaPsk, securityPsk, password
            ], result => {
                if (result.success) {
                    loadSavedConnections(() => {})
                    activateConnection(ssid, callback)
                } else {
                    const isDup = result.error?.includes("another connection with the name")
                    if (isDup) {
                        loadSavedConnections(() => {})
                        activateConnection(ssid, callback)
                    } else {
                        executeCommand(["device", "wifi", "connect", ssid, "password", password],
                                       r => callback?.(r))
                    }
                }
            })
        })
    }

    function activateConnection(name: string, callback: var): void {
        executeCommand(["connection", "up", name], result => callback?.(result))
    }

    function checkAndDeleteConnection(ssid: string, callback: var): void {
        executeCommand(["connection", "show", ssid], result => {
            if (result.success)
                executeCommand(["connection", "delete", ssid], () => Qt.callLater(callback, 300))
            else
                callback?.()
        })
    }

    // ── Write: disconnect wifi ────────────────────────
    function disconnectFromNetwork(): void {
        const cmd = active?.ssid
            ? ["connection", "down", active.ssid]
            : ["device", "disconnect", deviceTypeWifi]
        executeCommand(cmd, result => { if (result.success) getNetworks(() => {}) })
    }

    function disconnect(interfaceName: string, callback: var): void {
        executeCommand(["device", "disconnect", interfaceName || deviceTypeWifi],
                       result => callback?.(result.success ? result.output : ""))
    }

    function forgetNetwork(ssid: string, callback: var): void {
        if (!ssid) { callback?.({ success: false }); return }
        const name = savedConnections.find(c => c.toLowerCase() === ssid.toLowerCase()) ?? ssid
        executeCommand(["connection", "delete", name], result => {
            if (result.success) Qt.callLater(() => loadSavedConnections(() => {}), 500)
            callback?.(result)
        })
    }

    // ── Write: connect ethernet ───────────────────────
    function connectEthernet(connectionName: string, interfaceName: string, callback: var): void {
        const cmd = connectionName
            ? ["connection", "up", connectionName]
            : ["device", "connect", interfaceName]
        executeCommand(cmd, result => {
            if (result.success) Qt.callLater(() => getEthernetInterfaces(() => {}), 500)
            callback?.(result)
        })
    }

    function disconnectEthernet(connectionName: string, callback: var): void {
        if (!connectionName) { callback?.({ success: false, error: "No connection name" }); return }
        executeCommand(["connection", "down", connectionName], result => {
            if (result.success) {
                root.ethernetDeviceDetails = null
                Qt.callLater(() => getEthernetInterfaces(() => {}), 500)
            }
            callback?.(result)
        })
    }

    // ── Helpers ───────────────────────────────────────
    function hasSavedProfile(ssid: string): bool {
        if (!ssid) return false
        const low = ssid.toLowerCase().trim()
        return active?.ssid?.toLowerCase() === low
            || savedConnectionSsids.some(s => s.toLowerCase().trim() === low)
            || savedConnections.some(c => c.toLowerCase().trim() === low)
    }

    function isConnectedState(state: string): bool {
        return !!state && (state === "connected" || state.startsWith("connected"))
    }

    function refreshOnConnectionChange(): void {
        getNetworks(() => {})
        getWirelessInterfaces(() => {})
        getEthernetInterfaces(() => {})
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
        return (error.includes("Secrets were required") ||
                error.includes("No secrets provided") ||
                error.includes("802-11-wireless-security.psk") ||
                (error.includes("password") && !error.includes("Connection activated"))) &&
               !error.includes("Connection activated")
    }

    function handlePasswordRequired(proc: var, error: string, output: string, code: int): bool {
        if (!proc || !error || !pendingConnection?.callback) return false
        if (!detectPasswordRequired(error) || proc.callbackCalled)  return false
        connectionCheckTimer.stop(); immediateCheckTimer.stop(); immediateCheckTimer.checkCount = 0
        const pending = root.pendingConnection; root.pendingConnection = null
        proc.callbackCalled = true
        const result = { success: false, output, error, exitCode: code, needsPassword: true }
        pending.callback?.(result)
        if (proc.callback && proc.callback !== pending.callback) proc.callback?.(result)
        return true
    }

    // ── Parsers ───────────────────────────────────────
    function parseNetworkOutput(output: string): list<var> {
        if (!output) return []
        const PH = "STRINGSEP"
        return output.trim().split("\n").filter(l => l).map(line => {
            const p = line.replace(/\\:/g, PH).split(":")
            return {
                active:    p[0] === "yes",
                strength:  parseInt(p[1] ?? "0") || 0,
                frequency: parseInt(p[2] ?? "0") || 0,
                ssid:      (p[3] ?? "").replace(new RegExp(PH, "g"), ":").trim(),
                bssid:     (p[4] ?? "").replace(new RegExp(PH, "g"), ":").trim(),
                security:  (p[5] ?? "").trim()
            }
        }).filter(n => n.ssid)
    }

    function deduplicateNetworks(nets: list<var>): list<var> {
        const map = new Map()
        for (const n of nets) {
            const ex = map.get(n.ssid)
            if (!ex || (n.active && !ex.active) ||
                (!n.active && !ex.active && n.strength > ex.strength))
                map.set(n.ssid, n)
        }
        return Array.from(map.values())
    }

    function parseDeviceStatusOutput(output: string, filterType: string): list<var> {
        if (!output) return []
        return output.trim().split("\n").map(l => {
            const p = l.split(":")
            return p.length >= 2 ? { device: p[0], type: p[1], state: p[2] ?? "", connection: p[3] ?? "" } : null
        }).filter(i => i?.type === filterType)
    }

    function parseConnectionList(output: string, callback: var): void {
        const all = [], wifi = []
        for (const line of output.trim().split("\n").filter(l => l)) {
            const [name, type] = line.split(":")
            if (name) {
                all.push(name)
                if (type === connectionTypeWireless) wifi.push(name)
            }
        }
        root.savedConnections = all
        if (wifi.length > 0) {
            root.wifiConnectionQueue   = wifi
            root.currentSsidQueryIndex = 0
            root.savedConnectionSsids  = []
            queryNextSsid(callback)
        } else {
            root.savedConnectionSsids = []
            callback?.([])
        }
    }

    function queryNextSsid(callback: var): void {
        if (currentSsidQueryIndex >= wifiConnectionQueue.length) {
            root.wifiConnectionQueue = []; root.currentSsidQueryIndex = 0
            callback?.(root.savedConnectionSsids); return
        }
        const name = wifiConnectionQueue[currentSsidQueryIndex++]
        executeCommand(["-t", "-f", "802-11-wireless.ssid", "connection", "show", name], result => {
            if (result.success) {
                const line = result.output.trim().split("\n")
                    .find(l => l.startsWith("802-11-wireless.ssid:"))
                if (line) {
                    const ssid = line.slice("802-11-wireless.ssid:".length).trim()
                    if (ssid && !savedConnectionSsids.some(s => s.toLowerCase() === ssid.toLowerCase()))
                        root.savedConnectionSsids = [...root.savedConnectionSsids, ssid]
                }
            }
            queryNextSsid(callback)
        })
    }

    function parseDeviceDetails(output: string, isEthernet: bool): var {
        const d = { ipAddress: "", gateway: "", dns: [], subnet: "", macAddress: "", speed: "" }
        if (!output) return d
        for (const line of output.trim().split("\n")) {
            const idx = line.indexOf(":")
            if (idx < 0) continue
            const key = line.slice(0, idx).trim()
            const val = line.slice(idx + 1).trim()
            if      (key.startsWith("IP4.ADDRESS")) {
                const [ip, cidr] = val.split("/")
                d.ipAddress = ip
                if (cidr) d.subnet = cidrToSubnetMask(cidr)
            }
            else if (key === "IP4.GATEWAY") { if (val !== "--") d.gateway = val }
            else if (key.startsWith("IP4.DNS")) { if (val !== "--" && val) d.dns.push(val) }
            else if (isEthernet  && key === "WIRED-PROPERTIES.MAC")   d.macAddress = val
            else if (isEthernet  && key === "WIRED-PROPERTIES.SPEED") d.speed      = val
            else if (!isEthernet && key === "GENERAL.HWADDR")         d.macAddress = val
        }
        return d
    }

    function cidrToSubnetMask(cidr: string): string {
        const n = parseInt(cidr)
        if (isNaN(n) || n < 0 || n > 32) return ""
        const m = (0xffffffff << (32 - n)) >>> 0
        return [(m>>>24)&0xff, (m>>>16)&0xff, (m>>>8)&0xff, m&0xff].join(".")
    }

    // ── Startup ───────────────────────────────────────
    Component.onCompleted: {
        getWifiStatus(() => {})
        getNetworks(() => {})
        loadSavedConnections(() => {})
        getEthernetInterfaces(() => {})
        Qt.callLater(() => {
            getWirelessDeviceDetails("", () => {})
            getEthernetDeviceDetails("", () => {})
        }, 2000)
    }

    // ── Background processes ──────────────────────────
    Process {
        id: rescanProc
        command: ["nmcli", "dev", "wifi", "list", "--rescan", "yes"]
        onExited: root.getNetworks(() => {}) // qmllint disable signal-handler-parameters
    }

    Process {
        id: monitorProc
        running: true
        command: ["nmcli", "monitor"]
        environment: ({ LANG: "C.UTF-8", LC_ALL: "C.UTF-8" })
        stdout: SplitParser { onRead: root.refreshOnConnectionChange() }
        onExited: monitorRestartTimer.start() // qmllint disable signal-handler-parameters
    }

    Timer {
        id: monitorRestartTimer
        interval: 2000
        onTriggered: monitorProc.running = true
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
            pending.callback?.({ success: false, output: "", error: "Connection timeout", exitCode: -1, needsPassword: false })
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
            environment: ({ LANG: "C.UTF-8", LC_ALL: "C.UTF-8" })
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
            readonly property bool   isSecure:  security.length > 0
        }
    }
}
