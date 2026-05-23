import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Io

PanelWindow {
    id: root

    implicitWidth:  animator.animWidth
    implicitHeight: root.popoutHeight
    color:          "transparent"

    anchors {
        left:   true
        top:    true
        bottom: true
    }

    exclusionMode: ExclusionMode.Ignore

    // ── Configuration ─────────────────────────────────────────────
    property real  popoutWidth:    50
    property real  popoutHeight:   300
    property real  shoulderRadius: 18
    property real  cornerRadius:   18
    property color surfaceColor:   "#131315"
    property real  barWidth:       10

    // ── Autohide ──────────────────────────────────────────────────
    property string mode: "autohide"
    property bool windowOverlapsDock: !(root.mode === "visible") || root.mode === "autohide"
    readonly property real dockLeft:   0
    readonly property real dockRight:  root.barWidth + root.popoutWidth
    readonly property real dockTop:    (root.height - root.popoutHeight) / 2
    readonly property real dockBottom: root.dockTop + root.popoutHeight

    // ── Process ───────────────────────────────────────────────────
    Timer {
        interval: 200
        running:  root.mode === "intellihide"
        repeat:   true
        onTriggered: overlapProc.running = true
    }

    Process {
        id: overlapProc
        command: ["bash", "-c",
            "id=$(xdotool getactivewindow 2>/dev/null) && " +
            "xdotool getwindowgeometry --shell $id 2>/dev/null || echo 'X=0\\nY=0\\nWIDTH=0\\nHEIGHT=0'"
        ]

        property string buffer: ""

        stdout: SplitParser {
            onRead: data => { overlapProc.buffer += data + "\n" }
        }

        onRunningChanged: {
            if (running) { overlapProc.buffer = ""; return }

            const lines = overlapProc.buffer.split("\n")
            let wx = 0, wy = 0, ww = 0, wh = 0
            for (const line of lines) {
                const m = line.match(/^(\w+)=(\d+)/)
                if (!m) continue
                if (m[1] === "X")      wx = parseInt(m[2])
                if (m[1] === "Y")      wy = parseInt(m[2])
                if (m[1] === "WIDTH")  ww = parseInt(m[2])
                if (m[1] === "HEIGHT") wh = parseInt(m[2])
            }

            const winRight  = wx + ww
            const winBottom = wy + wh
            root.windowOverlapsDock =
                ww > 0 &&
                wx  < root.dockRight  &&
                winRight  > root.dockLeft &&
                wy  < root.dockBottom &&
                winBottom > root.dockTop
        }
    }

    // ── Animation host Item ───────────────────────────────────────
    Item {
        id: animator
        anchors.fill: parent

        property real animWidth: root.barWidth + root.popoutWidth + root.shoulderRadius

        states: [
            State {
                name: "visible"
                when: !root.windowOverlapsDock
                PropertyChanges { target: animator; animWidth: root.barWidth + root.popoutWidth + root.shoulderRadius }
                PropertyChanges { target: dockShape; opacity: 1.0; scale: 1.0 }
            },
            State {
                name: "hidden"
                when: root.windowOverlapsDock
                PropertyChanges { target: animator; animWidth: root.barWidth }
                PropertyChanges { target: dockShape; opacity: 0.0; scale: 0.88 }
            }
        ]

        transitions: [
            // Show: width opens first, then shape springs in
            Transition {
                from: "hidden"; to: "visible"
                SequentialAnimation {
                    SmoothedAnimation {
                        target: animator; property: "animWidth"
                        velocity: 600
                    }
                    ParallelAnimation {
                        SpringAnimation {
                            target: dockShape; property: "opacity"
                            to: 1.0; spring: 3.0; damping: 0.55; epsilon: 0.01
                        }
                        SpringAnimation {
                            target: dockShape; property: "scale"
                            to: 1.0; spring: 3.5; damping: 0.5; epsilon: 0.005; mass: 0.8
                        }
                    }
                }
            },
            // Hide: shape snaps out, then width collapses
            Transition {
                from: "visible"; to: "hidden"
                SequentialAnimation {
                    ParallelAnimation {
                        NumberAnimation {
                            target: dockShape; property: "opacity"
                            to: 0.0; duration: 90; easing.type: Easing.InQuart
                        }
                        NumberAnimation {
                            target: dockShape; property: "scale"
                            to: 0.88; duration: 90; easing.type: Easing.InQuart
                        }
                    }
                    NumberAnimation {
                        target: animator; property: "animWidth"
                        to: root.barWidth; duration: 130; easing.type: Easing.InCubic
                    }
                }
            }
        ]

        // ── Bar (invisible layout anchor) ─────────────────────────
        Rectangle {
            id: bar
            opacity:                0.0
            anchors.left:           parent.left
            anchors.verticalCenter: parent.verticalCenter
            width:                  root.barWidth
            height:                 root.popoutHeight + (root.shoulderRadius * 2)
            color:                  root.surfaceColor

            MouseArea {
              anchors.fill : parent 
              hoverEnabled: true
              onEntered: root.windowOverlapsDock = false
            }
        }

        // ── Dock shape ────────────────────────────────────────────
        Shape {
            id: dockShape
            anchors.left:           bar.right
            anchors.verticalCenter: parent.verticalCenter

            opacity:         1.0
            scale:           1.0
            transformOrigin: Item.Left

            width:  root.popoutWidth + root.shoulderRadius
            height: root.popoutHeight + (root.shoulderRadius * 2)

            layer.enabled: true
            layer.samples: 4

            MouseArea {
              anchors.fill: parent 
              hoverEnabled: true 
              onEntered: root.windowOverlapsDock = false
              onExited: root.windowOverlapsDock = root.mode === "autohide"
            }

            ShapePath {
                fillColor:   root.surfaceColor
                strokeColor: Qt.lighter(root.surfaceColor, 1.2)
                strokeWidth: 1

                startX: 0
                startY: 0

                PathArc {
                    relativeX: root.shoulderRadius; relativeY: root.shoulderRadius
                    radiusX:   root.shoulderRadius; radiusY:   root.shoulderRadius
                    direction: PathArc.Counterclockwise
                }
                PathLine {
                    relativeX: root.popoutWidth - (root.cornerRadius * 2)
                    relativeY: 0
                }
                PathArc {
                    relativeX: root.cornerRadius; relativeY: root.cornerRadius
                    radiusX:   root.cornerRadius; radiusY:   root.cornerRadius
                    direction: PathArc.Clockwise
                }
                PathLine {
                    relativeX: 0
                    relativeY: root.popoutHeight - (root.cornerRadius * 2)
                }
                PathArc {
                    relativeX: -root.cornerRadius; relativeY: root.cornerRadius
                    radiusX:    root.cornerRadius; radiusY:   root.cornerRadius
                    direction: PathArc.Clockwise
                }
                PathLine {
                    relativeX: -(root.popoutWidth - (root.cornerRadius * 2))
                    relativeY: 0
                }
                PathArc {
                    relativeX: -root.shoulderRadius; relativeY: root.shoulderRadius
                    radiusX:    root.shoulderRadius; radiusY:   root.shoulderRadius
                    direction: PathArc.Counterclockwise
                }
            }
        }
    }
}
