pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // "" | "right" | "left" | "top" | "bottom"
    property string activePane: ""

    IpcHandler {
        target: "panes"

        // qs ipc call panes toggle right
        function toggle(direction: string): void {
            root.activePane = (root.activePane === direction) ? "" : direction
        }

        // qs ipc call panes open right
        function open(direction: string): void {
            root.activePane = direction
        }

        // qs ipc call panes close
        function close(): void {
            root.activePane = ""
        }
    }
}
