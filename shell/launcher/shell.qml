import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Io          // ← needed for IpcHandler

PanelWindow {
    id: root
    implicitWidth: 600
    implicitHeight: 450

    color: "transparent"

    anchors { bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore

    // ── Tuneable ──────────────────────────────────────────────────────────────
    property real targetHeight:   0
    property real cornerRadius:   32
    property real shoulderRadius: 20
    property real shapeWidth:     600
    property real rectHeight:     10
    property color surfaceColor:  "#161619"

    property real effectiveShoulder: shoulderRadius
        + Math.max(0, (160.0 - targetHeight) / 160.0) * 18

    // ── Click mask: only the trigger strip is live when dock is closed ────────
    mask: Region {
        item: maskHelper
    }

    Item {
        id: maskHelper
        anchors.bottom:           parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width:  root.shapeWidth
        // When closed: only the 10 px trigger strip intercepts clicks.
        // When open:   grows with targetHeight so the whole dock body is covered.
        height: root.targetHeight < 1
                    ? root.rectHeight
                    : root.targetHeight + root.effectiveShoulder + root.rectHeight
    }

    // ── IPC handler ───────────────────────────────────────────────────────────
    // Usage:
    //   qs ipc call dock toggle
    //   qs ipc call dock open
    //   qs ipc call dock close
    IpcHandler {
        target: "dock"

        function toggle(): void {
            shell.state = (shell.state === "revealed") ? "" : "revealed"
        }

        function open(): void {
            shell.state = "revealed"
        }

        function close(): void {
            shell.state = ""
        }
    }

    // ── State host ────────────────────────────────────────────────────────────
    Item {
        id: shell
        anchors.fill: parent

        state: ""

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
                    target:           root
                    property:         "targetHeight"
                    duration:         200
                    easing.type:      Easing.OutBack
                    easing.overshoot: 1.55
                }
            },
            Transition {
                from: "revealed"; to: ""
                NumberAnimation {
                    target:           root
                    property:         "targetHeight"
                    duration:         150
                    easing.type:      Easing.InBack
                    easing.overshoot: 1.25
                }
            }
        ]

        // ── Invisible trigger strip ───────────────────────────────────────────
        Item {
            id: triggerStrip
            anchors.bottom:           parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width:  root.shapeWidth
            height: root.rectHeight

            Rectangle {
                anchors.fill: parent
                color:   root.surfaceColor
                opacity: 0
            }

            MouseArea {
                anchors.fill: parent
                cursorShape:  Qt.PointingHandCursor
                onClicked:    if (shell.state === "") shell.state = "revealed"
            }
        }

        // ── Dock body ─────────────────────────────────────────────────────────
        Item {
            id: dockBody
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
                        relativeX: root.effectiveShoulder
                        relativeY: -root.effectiveShoulder
                        radiusX:   root.effectiveShoulder
                        radiusY:   root.effectiveShoulder
                        direction: PathArc.Counterclockwise
                    }
                    PathLine {
                        relativeX: 0
                        relativeY: -Math.max(0, root.targetHeight
                                                - root.effectiveShoulder
                                                - root.cornerRadius)
                    }
                    PathArc {
                        relativeX: root.cornerRadius
                        relativeY: -root.cornerRadius
                        radiusX:   root.cornerRadius
                        radiusY:   root.cornerRadius
                        direction: PathArc.Clockwise
                    }
                    PathLine {
                        relativeX: Math.max(0, liquidShape.width
                                              - root.effectiveShoulder * 2
                                              - root.cornerRadius * 2)
                        relativeY: 0
                    }
                    PathArc {
                        relativeX: root.cornerRadius
                        relativeY: root.cornerRadius
                        radiusX:   root.cornerRadius
                        radiusY:   root.cornerRadius
                        direction: PathArc.Clockwise
                    }
                    PathLine {
                        relativeX: 0
                        relativeY: Math.max(0, root.targetHeight
                                               - root.effectiveShoulder
                                               - root.cornerRadius)
                    }
                    PathArc {
                        relativeX: root.effectiveShoulder
                        relativeY: root.effectiveShoulder
                        radiusX:   root.effectiveShoulder
                        radiusY:   root.effectiveShoulder
                        direction: PathArc.Counterclockwise
                    }

                    PathLine { x: 0; y: liquidShape.height }
                }

                Item {
                    anchors.bottom:           parent.bottom
                    anchors.bottomMargin:     root.effectiveShoulder
                    anchors.horizontalCenter: parent.horizontalCenter
                    width:  parent.width - root.effectiveShoulder * 2
                    height: Math.max(0, root.targetHeight - root.effectiveShoulder)
                    clip:   true

                    opacity: Math.min(1.0, Math.max(0.0,
                                 (root.targetHeight - 110.0) / 70.0))

                    ColumnLayout {
                        anchors.fill:    parent
                        anchors.margins: 15

                        Text {
                            text:  "LIQUID DOCK"
                            color: "#00ffff"
                            font.bold: true
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text:                "Click to dismiss"
                            color:               "white"
                            horizontalAlignment: Text.AlignHCenter
                            Layout.fillWidth:    true
                        }

                        Item { Layout.fillHeight: true }
                    }
                }
            }

            MouseArea {
                anchors.fill: liquidShape
                enabled:      shell.state === "revealed"
                cursorShape:  Qt.PointingHandCursor
                onClicked:    shell.state = ""
            }
        }
    }
}
