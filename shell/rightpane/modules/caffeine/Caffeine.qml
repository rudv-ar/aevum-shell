import qs.settings
import Quickshell
import Quickshell.Io
import qs.components
import QtQuick

// ── Caffeine Card ─────────────────────────────────
Rectangle {
    id: caffeineCard
    anchors.bottom:       parent.bottom
    anchors.left:         parent.left
    anchors.right:        parent.right
    anchors.bottomMargin: Properties.pillHeight + 230
    anchors.leftMargin:   10
    anchors.rightMargin:  10
    height:               Properties.pillHeight + 30
    radius:               15

    color: Qt.lighter(Theme.neutralP5, 1.50)

    // ── State Management ──────────────────────────────
    property bool isCaffeinated: false
    property string stateFile: Quickshell.env("HOME") + "/.config/aevum/settings/states/.caffeine.state"

    // Initial check on load
    Process {
        id: initCaffeine
        command: ["bash", "-c", `
            STATE_FILE="${stateFile}"
            if [ ! -f "$STATE_FILE" ]; then
                mkdir -p "$(dirname "$STATE_FILE")"
                echo "false" > "$STATE_FILE"
                pkill caffeine || true
                echo "false"
            else
                cat "$STATE_FILE"
            fi
        `]
        running: true

        onStdoutChanged: {
            if (stdout) {
                let outStr = Array.isArray(stdout) ? stdout.join("") : stdout.toString();
                if (outStr.includes("true")) {
                    isCaffeinated = true;
                } else if (outStr.includes("false")) {
                    isCaffeinated = false;
                }
            }
        }
    }

    Process {
        id: toggleCaffeineAction
    }

    // ── Row Layout ────────────────────────────────────
    Row {
        anchors.fill:           parent
        anchors.leftMargin:     14
        anchors.rightMargin:    14
        anchors.verticalCenter: parent.verticalCenter
        spacing:                12

        // ── Font Awesome Icon ─────────────────────────
        Rectangle {
            width:   30
            height:  30
            radius:  20
            anchors.verticalCenter: parent.verticalCenter
            color: isCaffeinated ? Theme.secondaryP30 : Theme.secondaryP20

            Text {
                id:          coffeeIcon
                anchors.centerIn: parent
                text:        "\uf0f4"
                font.family: Theme.fontAwesome6
                font.pixelSize: 14
                color: isCaffeinated ? Theme.error : Theme.secondaryP90
            }
        }

        // ── Labels ────────────────────────────────────
        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            // Stretch to fill space between icon and toggle pill
            width: caffeineCard.width - 14 - 30 - 12 - 44 - 14 - 12

            Text {
                text:        "Keep Awake"
                font.bold:   false
                font.pixelSize: 12
                font.family: Theme.fontPoppins
                color:       Theme.primaryP90
            }

            Text {
                text: isCaffeinated ? "Session is caffeinated" : "Normal power management"
                font.pointSize: 8
                color: Theme.secondaryP60
            }
        }

        // ── Toggle Pill ───────────────────────────────
        Rectangle {
            id:     togglePill
            width:  44
            height: 24
            radius: 12
            anchors.verticalCenter: parent.verticalCenter
            color: isCaffeinated ? Theme.primaryP40 : Theme.neutralP30

            Rectangle {
                width:  20
                height: 20
                radius: 10
                anchors.verticalCenter: parent.verticalCenter
                x: isCaffeinated ? parent.width - width - 2 : 2
                color: Qt.lighter(Theme.neutralP5, 1.50)

                Behavior on x {
                    NumberAnimation {
                        duration:    150
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    isCaffeinated = !isCaffeinated
                    let bashCmd = isCaffeinated
                        ? `echo "true" > "${stateFile}" && caffeine &`
                        : `echo "false" > "${stateFile}" && pkill caffeine || true`
                    toggleCaffeineAction.command = ["bash", "-c", bashCmd]
                    toggleCaffeineAction.running = true
                }
            }
        }
    }
}
