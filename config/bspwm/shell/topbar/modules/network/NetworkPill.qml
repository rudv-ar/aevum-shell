import QtQuick
import Quickshell.Io
import qs.settings
import qs.components
import qs.services.network

Item {
    id: root

    implicitWidth:  _pill.implicitWidth
    implicitHeight: _pill.implicitHeight

    // ── Processes ─────────────────────────────────────────────────────────────
    Process {
        id: _editorProc
        running: false
    }

    Process {
        id: _connEditProc
        running: false
    }

    // ── Pill ──────────────────────────────────────────────────────────────────
    BasePill {
        id: _pill

        glyph:      NetworkService.iconGlyph
        fontFamily: Theme.fontAwesome6
        label:      NetworkService.label
        muted:      !NetworkService.connected

        accentColor:   Theme.basePillAccentColor
        //alwaysExpanded: true
        accentOnColor: Theme.basePillAccentOnColor

        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton) {
                _editorProc.command = Commands.networkEditor()
                _editorProc.running = true
            } else {
                _connEditProc.command = Commands.networkConnEdit()
                _connEditProc.running = true
            }
        }

        onScrolled: function(delta) {}
    }
}

