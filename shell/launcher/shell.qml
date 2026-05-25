import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell

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

    // Shoulders morph organically as targetHeight animates each frame
    property real effectiveShoulder: shoulderRadius
        + Math.max(0, (160.0 - targetHeight) / 160.0) * 18

    // ── State host — Item is required; PanelWindow/Window doesn't have states ─
    Item {
        id: shell
        anchors.fill: parent

        state: ""   // "" = hidden, "revealed" = shown

        states: [
            State {
                name: "revealed"
                PropertyChanges { target: root; targetHeight: 400 }
            }
        ]

        transitions: [
            // ENTRY: springy organic pop-up
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
            // EXIT: brief windup flinch then sharp collapse
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

        // ── Invisible trigger strip (always at bottom, 10 px tall) ───────────
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

        // ── Dock body — grows upward from triggerStrip ────────────────────────
        Item {
            id: dockBody
            anchors.bottom:           triggerStrip.top
            anchors.horizontalCenter: parent.horizontalCenter

            width:  root.shapeWidth
            height: root.targetHeight + root.effectiveShoulder

            // Disable entire subtree when hidden so the volume is click-through
            enabled: root.targetHeight > 0.5

            // Opacity is a binding — front-loads fade-in, back-loads fade-out
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

                    // 1 ── LEFT SHOULDER (concave)
                    PathArc {
                        relativeX: root.effectiveShoulder
                        relativeY: -root.effectiveShoulder
                        radiusX:   root.effectiveShoulder
                        radiusY:   root.effectiveShoulder
                        direction: PathArc.Counterclockwise
                    }

                    // 2 ── LEFT WALL
                    PathLine {
                        relativeX: 0
                        relativeY: -Math.max(0, root.targetHeight
                                                - root.effectiveShoulder
                                                - root.cornerRadius)
                    }

                    // 3 ── TOP-LEFT CORNER (convex)
                    PathArc {
                        relativeX: root.cornerRadius
                        relativeY: -root.cornerRadius
                        radiusX:   root.cornerRadius
                        radiusY:   root.cornerRadius
                        direction: PathArc.Clockwise
                    }

                    // 4 ── TOP EDGE
                    PathLine {
                        relativeX: Math.max(0, liquidShape.width
                                              - root.effectiveShoulder * 2
                                              - root.cornerRadius * 2)
                        relativeY: 0
                    }

                    // 5 ── TOP-RIGHT CORNER (convex)
                    PathArc {
                        relativeX: root.cornerRadius
                        relativeY: root.cornerRadius
                        radiusX:   root.cornerRadius
                        radiusY:   root.cornerRadius
                        direction: PathArc.Clockwise
                    }

                    // 6 ── RIGHT WALL
                    PathLine {
                        relativeX: 0
                        relativeY: Math.max(0, root.targetHeight
                                               - root.effectiveShoulder
                                               - root.cornerRadius)
                    }

                    // 7 ── RIGHT SHOULDER (concave)
                    PathArc {
                        relativeX: root.effectiveShoulder
                        relativeY: root.effectiveShoulder
                        radiusX:   root.effectiveShoulder
                        radiusY:   root.effectiveShoulder
                        direction: PathArc.Counterclockwise
                    }

                    PathLine { x: 0; y: liquidShape.height }
                }

                // ── Clipped content ───────────────────────────────────────────
                Item {
                    anchors.bottom:           parent.bottom
                    anchors.bottomMargin:     root.effectiveShoulder
                    anchors.horizontalCenter: parent.horizontalCenter
                    width:  parent.width - root.effectiveShoulder * 2
                    height: Math.max(0, root.targetHeight - root.effectiveShoulder)
                    clip:   true

                    // Appears late in reveal, vanishes early on exit
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

            // Dismiss — only active while fully revealed
            MouseArea {
                anchors.fill: liquidShape
                enabled:      shell.state === "revealed"
                cursorShape:  Qt.PointingHandCursor
                onClicked:    shell.state = ""
            }
        }
    }
}
