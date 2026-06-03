import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import QtQuick.Controls
import Quickshell
import Quickshell.Io

PanelWindow {
    id: root
    implicitWidth: screen.width
    implicitHeight: screen.height

    color: "transparent"

    anchors { bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    focusable: true

    property real targetHeight:   0
    property real cornerRadius:   32
    property real shoulderRadius: 20
    property real shapeWidth:     600
    property real rectHeight:     10
    property color surfaceColor:  "#161619"

    property real effectiveShoulder: shoulderRadius
        + Math.max(0, (160.0 - targetHeight) / 160.0) * 18

    // ── X11 focus state ────────────────────────────────────────────────────
    // Holds the window ID that was active before the launcher opened.
    property string prevWindowId: ""

    // ── Convenience: open / close logic used everywhere ───────────────────
    function doOpen(): void {
        if (shell.state !== "revealed")
            captureWindowProc.running = true   // chains into reveal after stdout
    }

    function doClose(): void {
        if (shell.state === "revealed") {
            restoreFocusProc.running   = true
            writeStateClosed.running   = true
            shell.state                = ""
        }
    }

    // ── State-file writers ─────────────────────────────────────────────────
    Process {
        id: writeStateOpen
        command: [
            "bash", "-c",
            "mkdir -p \"${HOME}/.config/aevum/settings/states\" && " +
            "printf 'open\\n' > \"${HOME}/.config/aevum/settings/states/.launcher.state\""
        ]
    }

    Process {
        id: writeStateClosed
        command: [
            "bash", "-c",
            "mkdir -p \"${HOME}/.config/aevum/settings/states\" && " +
            "printf 'closed\\n' > \"${HOME}/.config/aevum/settings/states/.launcher.state\""
        ]
    }

    // ── X11 focus: capture active window, then open ────────────────────────
    // Running this process is the single entry-point for opening the launcher.
    // After stdout is collected the prevWindowId is stored and reveal happens.
    Process {
        id: captureWindowProc
        command: ["xdotool", "getactivewindow"]
        stdout: StdioCollector {
            onStreamFinished: {
                var wid = this.text.trim()
                if (wid !== "") root.prevWindowId = wid
                shell.state = "revealed"    // triggers onStateChanged below
            }
        }
    }

    // Short delay so the qs-launcher window has time to map before we focus it.
    Timer {
        id: focusDelayTimer
        interval: 120
        repeat:   false
        onTriggered: focusLauncherProc.running = true
    }

    // Focus the Quickshell launcher window via its WM_CLASS.
    Process {
        id: focusLauncherProc
        command: [
            "bash", "-c",
            "xdotool windowfocus $(xdotool search --class 'qs-launcher' | head -1)"
        ]
    }

    // Restore focus to whatever window was active before the launcher opened.
    Process {
        id: restoreFocusProc
        // Binding re-evaluates whenever prevWindowId changes, so the right ID
        // is always used when running is set to true.
        command: root.prevWindowId !== ""
            ? ["xdotool", "windowfocus", "--sync", root.prevWindowId]
            : ["bash", "-c", ":"]
    }

    // ─────────────────────────────────────────────────────────────────────
    mask: Region { item: maskHelper }

    Item {
        id: maskHelper
        anchors.bottom:           parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width:  root.shapeWidth
        height: root.targetHeight < 1
                    ? root.rectHeight
                    : root.targetHeight + root.effectiveShoulder + root.rectHeight
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void {
            if (shell.state === "revealed") root.doClose()
            else                            root.doOpen()
        }
        function open(): void  { root.doOpen()  }
        function close(): void { root.doClose() }
    }

    Item {
        id: shell
        anchors.fill: parent
        state: ""

        onStateChanged: {
            if (state === "revealed") {
                // Qt-level focus for keyboard input
                shell.Window.window.requestActivate()
                searchInput.forceActiveFocus()
                // X11-level focus (slight delay for window to map)
                focusDelayTimer.restart()
                // Persist state
                writeStateOpen.running = true
            }
        }

        states: [
            State {
                name: "revealed"
                PropertyChanges { target: root; targetHeight: 400 }
            }
        ]

        transitions: [
            Transition {
                from: ""; to: "revealed"
                NumberAnimation {
                    target: root; property: "targetHeight"
                    duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1.55
                }
            },
            Transition {
                from: "revealed"; to: ""
                NumberAnimation {
                    target: root; property: "targetHeight"
                    duration: 150; easing.type: Easing.InBack; easing.overshoot: 1.25
                }
            }
        ]

        // ── Trigger strip ──────────────────────────────────────────────────
        Item {
            id: triggerStrip
            anchors.bottom:           parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width:  root.shapeWidth
            height: root.rectHeight

            Rectangle { anchors.fill: parent; color: root.surfaceColor; opacity: 0 }

            MouseArea {
                anchors.fill: parent
                cursorShape:  Qt.PointingHandCursor
                onClicked:    root.doOpen()
            }
        }

        // ── launcher body ──────────────────────────────────────────────────────
        Item {
            id: launcherBody
            anchors.bottom:           triggerStrip.top
            anchors.horizontalCenter: parent.horizontalCenter
            width:  root.shapeWidth
            height: root.targetHeight + root.effectiveShoulder

            enabled: root.targetHeight > 0.5
            opacity: Math.min(1.0, root.targetHeight / 35.0)

            Shape {
                id: liquidShape
                anchors.fill: parent
                layer.enabled: true
                layer.samples: 4

                ShapePath {
                    fillColor:   root.surfaceColor
                    strokeWidth: 0

                    startX: 0
                    startY: liquidShape.height

                    PathArc {
                        relativeX: root.effectiveShoulder; relativeY: -root.effectiveShoulder
                        radiusX:   root.effectiveShoulder; radiusY:   root.effectiveShoulder
                        direction: PathArc.Counterclockwise
                    }
                    PathLine {
                        relativeX: 0
                        relativeY: -Math.max(0, root.targetHeight - root.effectiveShoulder - root.cornerRadius)
                    }
                    PathArc {
                        relativeX: root.cornerRadius;  relativeY: -root.cornerRadius
                        radiusX:   root.cornerRadius;  radiusY:   root.cornerRadius
                        direction: PathArc.Clockwise
                    }
                    PathLine {
                        relativeX: Math.max(0, liquidShape.width - root.effectiveShoulder * 2 - root.cornerRadius * 2)
                        relativeY: 0
                    }
                    PathArc {
                        relativeX: root.cornerRadius;  relativeY: root.cornerRadius
                        radiusX:   root.cornerRadius;  radiusY:   root.cornerRadius
                        direction: PathArc.Clockwise
                    }
                    PathLine {
                        relativeX: 0
                        relativeY: Math.max(0, root.targetHeight - root.effectiveShoulder - root.cornerRadius)
                    }
                    PathArc {
                        relativeX: root.effectiveShoulder; relativeY: root.effectiveShoulder
                        radiusX:   root.effectiveShoulder; radiusY:   root.effectiveShoulder
                        direction: PathArc.Counterclockwise
                    }
                    PathLine { x: 0; y: liquidShape.height }
                }

                // ── Content inside launcher ───────────────────────────────────
                Item {
                    anchors.bottom:           parent.bottom
                    anchors.bottomMargin:     root.effectiveShoulder
                    anchors.horizontalCenter: parent.horizontalCenter
                    width:  parent.width - root.effectiveShoulder * 2
                    height: Math.max(0, root.targetHeight - root.effectiveShoulder)
                    clip:   true

                    opacity: Math.min(1.0, Math.max(0.0, (root.targetHeight - 110.0) / 70.0))

                    ColumnLayout {
                        anchors.fill:    parent
                        anchors.margins: 15
                        spacing: 10

                        Text {
                            text:  "LIQUID launcher"
                            color: "#00ffff"
                            font.bold: true
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Item { Layout.fillHeight: true }

                        // ── Input bar ─────────────────────────────────────
                        Rectangle {
                            Layout.fillWidth: true
                            height: 36
                            radius: 8
                            color:  "#1e1e22"
                            border.color: searchInput.activeFocus ? "#00ffff" : "#333340"
                            border.width: 1

                            TextInput {
                                id: searchInput
                                anchors {
                                    left:           parent.left
                                    right:          parent.right
                                    verticalCenter: parent.verticalCenter
                                    leftMargin:     12
                                    rightMargin:    12
                                }
                                color:          "white"
                                font.pixelSize: 14
                                selectionColor: "#00ffff44"
                                clip:           true

                                Text {
                                    anchors.fill: parent
                                    text:    "Search…"
                                    color:   "#555566"
                                    font:    searchInput.font
                                    visible: searchInput.text.length === 0
                                             && !searchInput.activeFocus
                                }

                                Keys.onReturnPressed: {
                                    console.log("Input submitted:", text)
                                    text = ""
                                    root.doClose()
                                }

                                Keys.onEscapePressed: {
                                    text = ""
                                    root.doClose()
                                }
                            }
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill:            liquidShape
                enabled:                 shell.state === "revealed"
                propagateComposedEvents: true
                cursorShape:             Qt.PointingHandCursor
                onClicked: (mouse) => {
                    if (!searchInput.contains(mapToItem(searchInput, mouse.x, mouse.y)))
                        root.doClose()
                    else
                        mouse.accepted = false
                }
            }
        }
    }
}
