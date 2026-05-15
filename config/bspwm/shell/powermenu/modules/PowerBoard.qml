import QtQuick
import Quickshell
import Quickshell.Io
import qs.settings
import qs.components

Item {
    id: board

    // ── Uptime ────────────────────────────────────────────────────
    property string uptimeText: "–"
    readonly property string currentUser: Quickshell.env("USER")

    Process {
        id: uptimeProc
        command: ["sh", "-c", "uptime -p | sed 's/up //'"]
        running: true
        stdout: SplitParser {
            onRead: data => board.uptimeText = data.trim()
        }
    }

    Timer {
        interval: 60000
        running:  true
        repeat:   true
        onTriggered: { if (!uptimeProc.running) uptimeProc.running = true }
    }

    // ── Uptime strip (col 1) ──────────────────────────────────────
    Item {
        id: uptimeStrip
        anchors {
            left:   parent.left
            top:    parent.top
            bottom: parent.bottom
        }
        width: Properties.boardUptimeStripWidth

        Text {
            anchors.centerIn: parent
            rotation:         90
            text:             board.currentUser + "  ·  " + board.uptimeText
            font.pixelSize:   Properties.boardUptimeFontSize
            font.family:      Theme.fontPoppins
            font.bold:        false
            color:            Theme.primaryP100
            opacity:          0.55
        }       

    }

    // ── Pill area (col 2) ─────────────────────────────────────────
    Item {
        id: pillArea
        anchors {
            left:        uptimeStrip.right
            right:       parent.right
            top:         parent.top
            bottom:      parent.bottom
            rightMargin: Properties.boardPadding
        }

        Column {
            anchors.centerIn: parent
            spacing:          Properties.pillSpacing

            PowerMenuPill { glyph: "lock";               command: Commands.powerLock()    }
            PowerMenuPill { glyph: "bedtime";            command: Commands.powerSuspend() }
            PowerMenuPill { glyph: "logout";             command: Commands.powerLogout()  }
            PowerMenuPill { glyph: "restart_alt";        command: Commands.powerReboot()  }
            PowerMenuPill { glyph: "power_settings_new"; command: Commands.powerOff()     }
        }
    }
}
