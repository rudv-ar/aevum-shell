pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string activePane: ""

    IpcHandler {
        target: "panes"

        function toggle(direction: string): void {
            root.activePane = (root.activePane === direction) ? "" : direction
        }

        function open(direction: string): void {
            root.activePane = direction
        }

        function close(): void {
            root.activePane = ""
        }
    }
}
