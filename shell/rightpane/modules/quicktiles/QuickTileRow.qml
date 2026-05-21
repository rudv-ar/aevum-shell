import qs.settings
import Quickshell
import Quickshell.Io
import qs.components
import QtQuick

// ── Quick Toggles ─────────────────────────────────
Rectangle {
    id: togglesCard
    anchors.bottom:       parent.bottom
    anchors.left:         parent.left
    anchors.right:        parent.right
    anchors.bottomMargin: 10
    anchors.leftMargin:   10
    anchors.rightMargin:  10
    height:               80
    radius:               15

    color:        Qt.lighter(Theme.neutralP5, 1.50)
    //border.color: Qt.lighter(Theme.neutralP5, 1.50)
    //border.width: 1

    Column {
        anchors.fill:          parent
        anchors.leftMargin:    14
        anchors.rightMargin:   14
        anchors.topMargin:     12
        anchors.bottomMargin:  12
        spacing:               10

        // ── Label ─────────────────────────────────
        Text {
            text:  "Quick Toggles"
            font.bold:        false
            font.pixelSize:   12
            font.family:      Theme.fontPoppins
            color:            Theme.primaryP90
            horizontalAlignment: Text.AlignLeft
        }

        // ── Single row of 6 toggles ────────────────
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            // Wi-Fi
            TilePill {
                glyphOn:       "\uf1eb"
                glyphOff:      "\uf1eb"
                glyphDisabled: "\uf1eb"
                pillState:     TilePill.State.On
                commandOn:     ["nmcli", "radio", "wifi", "on"]
                commandOff:    ["nmcli", "radio", "wifi", "off"]
            }

            // Bluetooth
            TilePill {
                glyphOn:       "\uf294"
                glyphOff:      "\uf294"
                glyphDisabled: "\uf294"
                pillState:     TilePill.State.Off
                commandOn:     ["bluetoothctl", "power", "on"]
                commandOff:    ["bluetoothctl", "power", "off"]
            }

            // DND — silence dunst
            TilePill {
                glyphOn:       "\uf1f6"
                glyphOff:      "\uf0a2"
                glyphDisabled: "\uf0a2"
                pillState:     TilePill.State.Off
                commandOn:     ["dunstctl", "set-paused", "true"]
                commandOff:    ["dunstctl", "set-paused", "false"]
            }

            // Light / Dark — redshift toggle (X11)
            TilePill {
                glyphOn:       "\uf185"
                glyphOff:      "\uf186"
                glyphDisabled: "\uf186"
                pillState:     TilePill.State.Off
                commandOn:     ["redshift", "-O", "3500"]
                commandOff:    ["redshift", "-x"]
            }

            // VPN — nmcli connection
            TilePill {
                glyphOn:       "\uf505"
                glyphOff:      "\uf505"
                glyphDisabled: "\uf505"
                pillState:     TilePill.State.Off
                commandOn:     ["nmcli", "connection", "up", "vpn"]
                commandOff:    ["nmcli", "connection", "down", "vpn"]
            }

            // Microphone mute — pactl (PulseAudio/Pipewire)
            TilePill {
                glyphOn:       "\uf130"
                glyphOff:      "\uf131"
                glyphDisabled: "\uf131"
                pillState:     TilePill.State.On
                commandOn:     ["pactl", "set-source-mute", "@DEFAULT_SOURCE@", "0"]
                commandOff:    ["pactl", "set-source-mute", "@DEFAULT_SOURCE@", "1"]
            }
        }
    }
}
