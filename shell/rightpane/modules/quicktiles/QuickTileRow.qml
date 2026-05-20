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
    height:               130
    radius:               15

    color:        Theme.neutralP5
    border.color: Qt.lighter(togglesCard.color, 1.45)
    border.width: 1

    Column {
        anchors.centerIn: parent
        spacing:          10

        // ── Row 1: Active toggles ──────────────────
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

            // Night light (wlsunset — Wayland)
            TilePill {
                glyphOn:       "\uf185"
                glyphOff:      "\uf186"
                glyphDisabled: "\uf186"
                pillState:     TilePill.State.Off
                commandOn:     ["wlsunset", "-l", "40", "-L", "20"]
                commandOff:    ["pkill", "wlsunset"]
            }

            // Lock screen
            TilePill {
                glyphOn:       "\uf3ed"
                glyphOff:      "\uf3ed"
                glyphDisabled: "\uf3ed"
                pillState:     TilePill.State.Off
                commandOn:     ["hyprlock"]
                commandOff:    []
            }

            // Notifications
            TilePill {
                glyphOn:       "\uf1f6"
                glyphOff:      "\uf0a2"
                glyphDisabled: "\uf0a2"
                pillState:     TilePill.State.Off
                commandOn:     []
                commandOff:    []
            }

            // Color picker
            TilePill {
                glyphOn:       "\uf493"
                glyphOff:      "\uf493"
                glyphDisabled: "\uf493"
                pillState:     TilePill.State.Off
                commandOn:     ["hyprpicker", "-a"]
                commandOff:    []
            }
        }

        // ── Row 2: X11-compat + disabled ──────────
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            // Picom compositor (X11) — \uf5aa = layer-group
            TilePill {
                glyphOn:       "\uf5aa"
                glyphOff:      "\uf5aa"
                glyphDisabled: "\uf5aa"
                pillState:     TilePill.State.Off
                commandOn:     ["picom", "--daemon"]
                commandOff:    ["pkill", "picom"]
            }

            // Redshift color temp (X11) — \uf7e0 = temperature-low
            TilePill {
                glyphOn:       "\uf7e0"
                glyphOff:      "\uf7e4"
                glyphDisabled: "\uf7e4"
                pillState:     TilePill.State.Off
                commandOn:     ["redshift", "-O", "3500"]
                commandOff:    ["redshift", "-x"]
            }

            // Audio mute (disabled — placeholder)
            TilePill {
                glyphOn:       "\uf028"
                glyphOff:      "\uf6a9"
                glyphDisabled: "\uf6a9"
                pillState:     TilePill.State.Disabled
                commandOn:     []
                commandOff:    []
            }

            // Bluetooth (disabled — last)
            TilePill {
                glyphOn:       "\uf294"
                glyphOff:      "\uf294"
                glyphDisabled: "\uf294"
                pillState:     TilePill.State.Disabled
                commandOn:     ["bluetoothctl", "power", "on"]
                commandOff:    ["bluetoothctl", "power", "off"]
            }

            // Aeroplane mode (disabled — last)
            TilePill {
                glyphOn:       "\uf072"
                glyphOff:      "\uf072"
                glyphDisabled: "\uf072"
                pillState:     TilePill.State.Disabled
                commandOn:     []
                commandOff:    []
            }
        }
    }
}
