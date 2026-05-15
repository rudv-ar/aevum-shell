pragma Singleton
import QtQuick
import Quickshell

QtObject {
    // ── Workspace ─────────────────────────────────────────────────────────────
    function workspaceSubscribe() {
        return ["bspc", "subscribe", "-c", "1",
                "desktop_focus", "node_add", "node_remove", "node_transfer"]
    }
    function workspaceFocused() {
        return ["bspc", "query", "-D", "-d", "focused", "--names"]
    }
    function workspaceOccupied() {
        return ["bspc", "query", "-D", "-d", ".occupied", "--names"]
    }
    function workspaceSwitch(name) {
        return ["bspc", "desktop", "-f", name]
    }
    // ── Launcher ──────────────────────────────────────────────────────────────
    function rofiLauncher() {
        return ["rofi_launcher"]
    }


    // ── Network ───────────────────────────────────────────────────────────────
    function networkState() {
        return ["nmcli", "-t", "-f", "active,type,name,device",
                "connection", "show", "--active"]
    }
    function networkIp(device) {
        return ["nmcli", "-t", "-f", "IP4.ADDRESS",
                "device", "show", device]
    }
    function networkEditor() {
        return ["nm-connection-editor"]
    }
    function networkConnEdit() {
        return ["vicinae", "deeplink", "vicinae://launch/@dagimg-dot/store.vicinae.wifi-commander/scan-wifi"]
    }

  function powerMenu() {
      return ["qs", "-p", Quickshell.env("HOME") + "/.config/bspwm/shell/powermenu/shell.qml", "ipc", "call", "powermenu", "toggle"]
  }      
}



