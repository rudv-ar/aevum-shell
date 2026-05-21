import qs.settings
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls

Rectangle {
    id: srcrecCard
    anchors.left:        parent.left
    anchors.right:       parent.right
    anchors.bottom:      parent.bottom 
    anchors.bottomMargin: Properties.pillHeight + 70
    anchors.leftMargin:  10
    anchors.rightMargin: 10
    height:              Properties.pillHeight + 120
    radius:              15
    color:               Qt.lighter(Theme.neutralP5, 1.50)
    clip:                true

    property string recState:    "idle"
    property string currentFile: ""
    property string elapsedTime: "00:00:00"
    property string recMode:     "fullscreen"
    property int    elapsedSecs: 0

    property var recordings: []

    // ── Elapsed timer ────────────────────────────────────────
    Timer {
        id: elapsedTimer
        interval: 1000
        repeat:   true
        running:  srcrecCard.recState === "recording"
        onTriggered: {
            srcrecCard.elapsedSecs++
            let s   = srcrecCard.elapsedSecs
            let h   = Math.floor(s / 3600)
            let m   = Math.floor((s % 3600) / 60)
            let sec = s % 60
            srcrecCard.elapsedTime = String(h).padStart(2,"0") + ":"
                                   + String(m).padStart(2,"0") + ":"
                                   + String(sec).padStart(2,"0")
        }
    }

    // ── Recorder process ─────────────────────────────────────
    Process {
        id: recProcess
        command: ["srcrec"]

        stdout: SplitParser {
            onRead: function(line) {
                if (line.indexOf("starting recording") !== -1
                    && srcrecCard.recState === "selecting") {
                    srcrecCard.recState    = "recording"
                    srcrecCard.elapsedSecs = 0
                    srcrecCard.elapsedTime = "00:00:00"
                }
            }
        }

        onExited: function(code, status) {
            let recs = srcrecCard.recordings.slice()
            for (let i = 0; i < recs.length; i++) {
                if (recs[i].active) {
                    recs[i].active   = false
                    recs[i].duration = srcrecCard.elapsedTime
                    break
                }
            }
            srcrecCard.recordings  = recs
            srcrecCard.recState    = "idle"
            srcrecCard.elapsedSecs = 0
            srcrecCard.elapsedTime = "00:00:00"
        }
    }

    Process {
        id: mpvProcess
        command: ["mpv", "--really-quiet", ""]
    }

    // ── Helpers ──────────────────────────────────────────────
    function startRecording() {
        let ts    = Qt.formatDateTime(new Date(), "yyyyMMdd_hhmmss")
        let home  = Quickshell.env("HOME")
        let fname = home + "/Videos/output_" + ts + ".mp4"
        srcrecCard.currentFile = fname

        let cmd = ["srcrec", "-o", fname]
        if (srcrecCard.recMode === "region") cmd.push("-R")

        recProcess.command = cmd
        recProcess.running = true

        let recs = srcrecCard.recordings.slice()
        recs.unshift({ file: fname, duration: "00:00:00", active: true })
        srcrecCard.recordings = recs

        if (srcrecCard.recMode === "fullscreen") {
            srcrecCard.elapsedSecs = 0
            srcrecCard.elapsedTime = "00:00:00"
            srcrecCard.recState    = "recording"
        } else {
            srcrecCard.recState = "selecting"
        }
    }

    function stopRecording() {
        let pid = recProcess.pid
        if (pid != null) {
            // FIX #1: removed the leading "-" — negating the PID sends
            // SIGINT to the process GROUP whose PGID == pid, which is
            // Quickshell's own group (bash inherits it). That either
            // does nothing (ESRCH) or kills Quickshell itself.
            // Signal bash directly; pkill -P catches the ffmpeg child too.
            Quickshell.execDetached(["pkill", "ffmpeg"])
        }
        // FIX #2: removed recProcess.running = false here.
        // QProcess::kill() fires before ffmpeg can flush and write the
        // moov atom, producing a corrupted, unplayable MP4.
        // onExited handles all state cleanup when the process exits cleanly.
    }

    function playFile(path) {
        // FIX #3: stop any currently running mpv before starting a new one.
        // Setting running = true on an already-running Process is undefined
        // behaviour (no-op or restart depending on Quickshell version).
        mpvProcess.running = false
        mpvProcess.command = ["mpv", "--really-quiet", path]
        mpvProcess.running = true
    }

    function removeEntry(idx) {
        let recs = srcrecCard.recordings.slice()
        recs.splice(idx, 1)
        srcrecCard.recordings = recs
    }

    // ── Row 1 ────────────────────────────────────────────────
    Row {
        id: row1
        anchors.top:         parent.top
        anchors.left:        parent.left
        anchors.right:       parent.right
        anchors.topMargin:   14
        anchors.leftMargin:  16
        anchors.rightMargin: 16
        height:              Properties.pillHeight
        spacing:             8

        // Power glyph
        Rectangle {
            width:  30
            height: 30
            radius: 20
            anchors.verticalCenter: parent.verticalCenter
            color: srcrecCard.recState !== "idle"
                   ? Theme.secondaryP30
                   : Theme.secondaryP20
            Behavior on color { ColorAnimation { duration: 200 } }

            Text {
                anchors.centerIn: parent
                text:           "\uf192"
                font.family:    Theme.fontAwesome6
                font.pixelSize: 15
                color: srcrecCard.recState !== "idle" ? Theme.error : Theme.secondaryP90
                Behavior on color { ColorAnimation { duration: 200 } }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape:  Qt.PointingHandCursor
                onClicked: {
                    if (srcrecCard.recState === "idle")
                        srcrecCard.startRecording()
                    else
                        srcrecCard.stopRecording()
                }
            }
        }

        // Label + state
        Column {
            id: labelCol
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3

            Text {
                text:           "Screen Recorder"
                color:          Theme.primaryP90
                font.pixelSize: 12
                font.family: Theme.fontPoppins
            }

            Row {
                spacing: 5

                Rectangle {
                    width:  7
                    height: 7
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: srcrecCard.recState === "recording" ? "#ff5555"
                         : srcrecCard.recState === "selecting"  ? "#ffaa55"
                         : Qt.rgba(1, 1, 1, 0.25)
                    Behavior on color { ColorAnimation { duration: 300 } }

                    SequentialAnimation on opacity {
                        running:  srcrecCard.recState === "recording"
                        loops:    Animation.Infinite
                        NumberAnimation { to: 0.2; duration: 700; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 1.0; duration: 700; easing.type: Easing.InOutSine }
                        onStopped: parent.opacity = 1
                    }
                }

                Text {
                    text: srcrecCard.recState === "recording" ? "Recording On"
                        : srcrecCard.recState === "selecting"  ? "Selecting Region"
                        : "Recording Off"
                    color:          Theme.secondaryP60
                    font.pointSize: 8
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // Spacer
        Item {
            width: row1.width
                   - 38
                   - labelCol.width
                   - modeDisplay.width
                   - dropTrigger.width
                   - row1.spacing * 4
            height: 1
        }

        Row {
          spacing: 2
        // Mode display pill
        Rectangle {
            id: modeDisplay
            anchors.verticalCenter: parent.verticalCenter
            width:  94
            height: 26
            topLeftRadius: 15 
            bottomLeftRadius: 15
            topRightRadius: 5
            bottomRightRadius: 5
            color:  Theme.primaryP40

            Row {
                anchors.centerIn: parent
                spacing: 6

                Text {
                    text:           srcrecCard.recMode === "fullscreen" ? "\uf065" : "\uf248"
                    font.family:    Theme.fontAwesome6
                    font.pointSize: 8
                    color:          Theme.neutralP5
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text:           srcrecCard.recMode === "fullscreen" ? "Fullscreen" : "Region"
                    font.pointSize: 8
                    color:          Theme.neutralP5
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // Dropdown trigger
        Rectangle {
            id: dropTrigger
            anchors.verticalCenter: parent.verticalCenter
            width:   26
            height:  26
            topLeftRadius: 5 
            bottomLeftRadius: 5
            topRightRadius: 15 
            bottomRightRadius: 15 
            color:   dropMenu.visible
                     ? Qt.lighter(Theme.neutralP5, 2.50)
                     : Theme.primaryP40
            enabled: srcrecCard.recState === "idle"
            opacity: enabled ? 1.0 : 0.4
            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent
                text:           "\uf078"
                font.family:    Theme.fontAwesome6
                font.pointSize: 7
                color:          Theme.neutralP5
                rotation:       dropMenu.visible ? 180 : 0
                Behavior on rotation {
                    NumberAnimation { duration: 180; easing.type: Easing.InOutQuad }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape:  Qt.PointingHandCursor
                onClicked:    dropMenu.visible = !dropMenu.visible
            }
        }
        }
    }

    // ── Dropdown (child of card to avoid clip) ───────────────
    Rectangle {
        id: dropMenu
        visible:      false
        x:            row1.x + row1.width - width
        y:            row1.y + row1.height + 5
        width:        136
        height:       70
        radius:       9
        z:            99
        color:        Qt.lighter(Theme.neutralP5, 1.80)
        border.color: Qt.lighter(Theme.neutralP5, 2.0)
        border.width: 1

        Column {
            anchors.fill:         parent

            Repeater {
                model: [
                    { mode: "fullscreen", icon: "\uf065", label: "Fullscreen" },
                    { mode: "region",     icon: "\uf248", label: "Region"     }
                ]

                delegate: Rectangle {
                    width:  dropMenu.width
                    height: 35
                    color:  itemMouse.containsMouse
                            ? Qt.rgba(1, 1, 1, 0.09)
                            : "transparent"
                    radius: 6
                    Behavior on color { ColorAnimation { duration: 100 } }

                    Rectangle {
                        visible:          srcrecCard.recMode === modelData.mode
                        width:            3
                        height:           16
                        radius:           2
                        color:            Theme.textPrimary
                        anchors.left:     parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 4
                    }

                    Row {
                        anchors.left:           parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin:     14
                        spacing:                9

                        Text {
                            text:           modelData.icon
                            font.family:    Theme.fontAwesome6
                            font.pointSize: 9
                            color: srcrecCard.recMode === modelData.mode
                                   ? Theme.secondaryP70 : Theme.secondaryP80
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text:           modelData.label
                            font.pointSize: 8
                            color: srcrecCard.recMode === modelData.mode
                                   ? Theme.secondaryP70 : Theme.secondaryP80
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id:           itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape:  Qt.PointingHandCursor
                        onClicked: {
                            srcrecCard.recMode = modelData.mode
                            dropMenu.visible   = false
                        }
                    }
                }
            }
        }
    }

    // ── Divider ──────────────────────────────────────────────
    Rectangle {
        id: divider
        anchors.top:         row1.bottom
        anchors.left:        parent.left
        anchors.right:       parent.right
        anchors.topMargin:   10
        anchors.leftMargin:  16
        anchors.rightMargin: 16
        height: 0
        color:  Qt.rgba(1, 1, 1, 0.07)
    }

    // ── Row 2 header ─────────────────────────────────────────
    Row {
        id: row2Header
        anchors.top:         divider.bottom
        anchors.left:        parent.left
        anchors.right:       parent.right
        anchors.topMargin:   10
        anchors.leftMargin:  16
        anchors.rightMargin: 16
        height:              18

        Text {
            text:           "\uf03a   Recordings"
            font.family:    Theme.fontPoppins
            font.pixelSize: 12
            font.bold: false
            color:          Theme.secondaryP70
            anchors.verticalCenter: parent.verticalCenter
        } 

        Item {
          width: 170
          height: 1
        }
        Column {
            id: scrollCol
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            Text {
                text:           "\uf077"
                font.pixelSize: 7
                color:          Theme.secondaryP70
                MouseArea {
                    anchors.fill: parent
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    recListView.decrementCurrentIndex()
                }
            }
            Text {
                text:           "\uf078"
                font.pixelSize: 7
                color:          Theme.secondaryP70
                MouseArea {
                    anchors.fill: parent
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    recListView.incrementCurrentIndex()
                }
            }
        }
    }

    // ── Recordings list ──────────────────────────────────────
    Item {
        id: listSection
        anchors.top:         row2Header.bottom
        anchors.left:        parent.left
        anchors.right:       parent.right
        anchors.topMargin:   6
        anchors.leftMargin:  16
        anchors.rightMargin: 16
        height: recListView.count === 0
                ? emptyText.height + 16
                : Math.min(recListView.contentHeight, 3 * (44 + 4))

        ListView {
            id: recListView
            anchors.fill:            parent
            clip:                    true
            spacing:                 4
            model:                   srcrecCard.recordings
            snapMode:                ListView.SnapToItem
            highlightRangeMode:      ListView.StrictlyEnforceRange
            preferredHighlightBegin: 0
            preferredHighlightEnd:   44

            delegate: Rectangle {
                id: recEntry

                property var entry: modelData
                property int idx:   index

                width:  recListView.width
                height: 44
                radius: 8
                color:  entryMouse.containsMouse
                        ? Qt.rgba(1, 1, 1, 0.10)
                        : Qt.rgba(1, 1, 1, 0.05)
                Behavior on color { ColorAnimation { duration: 120 } }

                MouseArea {
                    id:           entryMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    onClicked: {
                        if (!recEntry.entry.active)
                            srcrecCard.playFile(recEntry.entry.file)
                    }
                }

                Column {
                    anchors.left:           parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin:     10
                    width:                  parent.width - ctrlRow.width - 20
                    spacing:                2

                    Text {
                        width:          parent.width
                        text: {
                            let parts = recEntry.entry.file.split("/")
                            return parts[parts.length - 1]
                        }
                        color:          Theme.textPrimary
                        font.pointSize: 9
                        elide:          Text.ElideMiddle
                    }

                    Text {
                        text:           recEntry.entry.active
                                        ? srcrecCard.elapsedTime
                                        : recEntry.entry.duration
                        color:          recEntry.entry.active ? "#ff5555" : Theme.textSubtle
                        font.pointSize: 8
                    }
                }

                Row {
                    id: ctrlRow
                    anchors.right:          parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin:    10
                    spacing:                12

                    Text {
                        visible:        recEntry.entry.active
                        text:           "\uf04d"
                        font.family:    "Font Awesome 6 Free Solid"
                        font.pointSize: 11
                        color:          "#ff5555"
                        anchors.verticalCenter: parent.verticalCenter
                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            onClicked:    srcrecCard.stopRecording()
                        }
                    }

                    Text {
                        visible:        !recEntry.entry.active
                        text:           "\uf00d"
                        font.family:    "Font Awesome 6 Free Solid"
                        font.pointSize: 11
                        color:          Theme.textSubtle
                        anchors.verticalCenter: parent.verticalCenter
                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            onClicked:    srcrecCard.removeEntry(recEntry.idx)
                        }
                    }
                }
            }
        } 

        Item {
          id: emptyText
          anchors.centerIn: parent
          visible: recListView.count === 0 
        Row {
            spacing: 2
            anchors.fill: parent.fill
        Text {
            text:             "\ue494"
            color:            Theme.secondaryP80
            font.family: Theme.fontAwesome6
            font.pixelSize:   10
        }
        Text {
          text: "No recordings found"
          color: Theme.secondaryP80 
          font.family: Theme.fontPoppins 
          font.pixelSize: 10
        }
        }
        }

    }
}

