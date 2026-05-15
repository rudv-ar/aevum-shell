import QtQuick
import qs.settings
import qs.components
import qs.services.audio

Item {
    id: root

    signal audioPillToggled(bool open)

    readonly property real sceneCenterX: _pill.sceneCenterX
    property bool popoutOpen: false

    implicitWidth:  _pill.implicitWidth
    implicitHeight: _pill.implicitHeight

    BasePill {
        id: _pill

        glyph:         AudioService.iconGlyph
        fontFamily:    Theme.fontAwesome6
        label:         AudioService.volumeString
        popoutOpen:    root.popoutOpen
        alwaysExpanded: false
        muted:         AudioService.muted
        accentColor:   Theme.basePillAccentColor
        accentOnColor: Theme.basePillAccentOnColor

        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton) {
                AudioService.toggleMute()
            } else {
                root.popoutOpen = !root.popoutOpen
                root.audioPillToggled(root.popoutOpen)
            }
        }

        onScrolled: function(delta) {
            AudioService.adjustVolume(delta * 0.05)
        }
    }
}

