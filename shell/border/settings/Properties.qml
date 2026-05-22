pragma Singleton
import QtQuick
import Quickshell.Io
import Quickshell

Singleton {
    id: root

    property int borderThickness: 10
    property int topOffset: 4
    property real cornerRadius: 18.0
    property int marginCover: 32

    FileView {
        id: configFile
        path: Quickshell.env("HOME") + "/.config/aevum/settings/config.json"
        watchChanges: true
        onFileChanged: retryTimer.restart()

        JsonAdapter {
            property var shell: ({})

            onShellChanged: {
                var borders = shell["borders"] ?? {} 
                var topbar = shell["topbar"] ?? {} 
                var bar = topbar["bar"] ?? {}
                root.borderThickness  = borders["thickness"]    ?? 10
                root.topOffset              = borders["topOffset"]          ?? 4
                root.cornerRadius     = borders["cornerRadius"] ?? 18.0
                root.marginCover            = bar["height"]        ?? 32
            }
        }
    }

    Timer {
        id: retryTimer
        interval: 200
        repeat: false
        onTriggered: configFile.reload()
    }
}
