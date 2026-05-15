import QtQuick
import qs.settings
import qs.components
import Quickshell
import Quickshell.Io

Item {
    id: root

    implicitWidth:  _pill.implicitWidth
    implicitHeight: _pill.implicitHeight

    DualPill {
        id: _pill

        leftGlyph:  Properties.rightbarSettingsGlyph
        leftLabel:  ""
        leftAlwaysExpanded: false

        rightGlyph: Properties.rightbarPowerGlyph
        rightLabel: ""
        rightAlwaysExpanded: false

        onRightClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                _proc.command = Commands.powerMenu()
                _proc.running = true
            }
        }
    }

    Process {
        id: _proc
        running: false
    }
}
