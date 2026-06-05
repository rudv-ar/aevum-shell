pragma Singleton
import QtQuick
import Quickshell.Io
import Quickshell

Singleton {
    id: root

    property int  borderThickness: 10
    property int  topOffset:       0
    property real cornerRadius:    13.0
    property int  marginCover:     0
    property int  paneWidth:       350

    property real pillWidth:    40
    property real pillHeight:   30
    property real pillRadius:   10
    property real pillIconSize: 14
    property real pillSpacing:  0

    FileView {
        id: configFile
        path: Quickshell.env("HOME") + "/.config/aevum/settings/config.json"
        watchChanges: true
        onFileChanged: retryTimer.restart()

        JsonAdapter {
            property var shell: ({})

            onShellChanged: {
                var b   = shell["borders"]   ?? {}
                var tb  = shell["topbar"]    ?? {}
                var bar = tb["bar"]          ?? {}
                var rp  = shell["rightPane"] ?? {}
                var pn  = rp["pane"]         ?? {}
                var qt  = rp["quickToggles"] ?? {}

                root.borderThickness = b["thickness"]    ?? 10
                root.topOffset       = b["topOffset"]    ?? 4
                root.cornerRadius    = b["cornerRadius"] ?? 18.0
                root.marginCover     = bar["height"]     ?? 32

                root.paneWidth    = pn["width"]       ?? 350
                root.pillWidth    = qt["pillWidth"]   ?? 40
                root.pillHeight   = qt["pillHeight"]  ?? 30
                root.pillRadius   = qt["pillRadius"]  ?? 10
                root.pillIconSize = qt["pillIconSize"] ?? 14
                root.pillSpacing  = qt["pillSpacing"]  ?? 0
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
