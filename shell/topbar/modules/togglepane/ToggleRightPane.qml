import QtQuick
import Quickshell.Io
import qs.settings
import qs.components

Item {
    id: root

    implicitWidth:  _pill.implicitWidth
    implicitHeight: _pill.implicitHeight

    // ── Processes ─────────────────────────────────────────────────────────────
    Process {
        id: _actionsProc
        running: false
    }

    // ── Pill ──────────────────────────────────────────────────────────────────
    BasePill {
        id: _pill

        glyph:      Properties.rightbarPaneGlyph
        fontFamily: Properties.fontAwesome6
        label:      "actions"

        onClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                _actionsProc.command = Commands.openActions()
                _actionsProc.running = true
            }
        }

        onScrolled: function(delta) {}
    }
}
