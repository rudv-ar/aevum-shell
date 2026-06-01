pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import Quickshell.Io
import qs.config

Item {
    id: root

    // ── Signals ───────────────────────────────────────
    signal leftClicked()
    signal rightClicked()

    // ── Dimension tokens ──────────────────────────────
    readonly property int   pillW:     Theme.powerPillW
    readonly property int   pillH:     Theme.powerPillH
    readonly property int   pillR:     Theme.powerPillR
    readonly property int   iconSize:  Theme.powerIconSize

    // ── Color tokens ──────────────────────────────────
    readonly property color bg:        Theme.powerBg
    readonly property color iconCol:   Theme.powerIcon
    readonly property color rippleCol: Theme.powerRipple

    // ── Font token ────────────────────────────────────
    readonly property string fontMat:  Theme.fontMaterial

    // ── Animation tokens ──────────────────────────────
    readonly property int animFast:    Theme.animFast
    readonly property int animNormal:  Theme.animNormal
    readonly property int animSlow:    Theme.animSlow

    // ── Ripple state ──────────────────────────────────
    property real circleRadius:      0
    property real endRadiusAtPress:  0

    readonly property real endRadius: {
        const dx = Math.max(mouse.pressX, pillW - mouse.pressX)
        const dy = Math.max(mouse.pressY, pillH - mouse.pressY)
        return Math.sqrt(dx * dx + dy * dy)
    }

    // ── Size ──────────────────────────────────────────
    implicitWidth:  pillW
    implicitHeight: pillH

    // ── Scale spring on press ─────────────────────────
    scale: mouse.pressed ? 0.88 : 1.0

    Behavior on scale {
        SmoothedAnimation {
            duration: root.animFast
            easing.type: Easing.OutBack
        }
    }

    // ── Pill background ───────────────────────────────
    Rectangle {
        id: pill

        anchors.fill: parent
        radius:       root.pillR
        color:        root.bg
        clip:         true

        // ── Hover overlay ─────────────────────────────
        Rectangle {
            id: hoverOverlay

            anchors.fill: parent
            radius:       pill.radius
            color:        root.rippleCol
            opacity:      mouse.containsMouse
                              ? (mouse.pressed ? 0.15 : 0.08)
                              : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration:   root.animNormal
                    easing.type: Easing.OutCubic
                }
            }
        }

        // ── Ripple ────────────────────────────────────
        Shape {
            id: rippleShape

            anchors.fill: parent
            opacity:      0
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeWidth:  0
                strokeColor:  "transparent"
                fillColor:    "transparent"

                fillGradient: RadialGradient {
                    centerX:      mouse.pressX
                    centerY:      mouse.pressY
                    centerRadius: root.circleRadius
                    focalX:       centerX
                    focalY:       centerY

                    GradientStop { position: 0;    color: Qt.alpha(root.rippleCol, 1) }
                    GradientStop { position: 0.99; color: Qt.alpha(root.rippleCol, 1) }
                    GradientStop { position: 1;    color: Qt.alpha(root.rippleCol, 0) }
                }

                startX: 0;           startY: 0
                PathLine { x: root.pillW; y: 0 }
                PathLine { x: root.pillW; y: root.pillH }
                PathLine { x: 0;          y: root.pillH }
                PathLine { x: 0;          y: 0 }
            }
        }
    }

    // ── Icon ──────────────────────────────────────────
    Text {
        anchors.centerIn: parent
        text:             "\ue8ac"
        font.family:      root.fontMat
        font.pixelSize:   root.iconSize
        color:            root.iconCol
        renderType:       Text.NativeRendering
    }

    // ── Processes ─────────────────────────────────────
    Process {
        id: leftProc
        command: ["sh", "-c", Theme.powerLeftCmd]
    }

    Process {
        id: rightProc
        command: ["sh", "-c", Theme.powerRightCmd]
    }

    // ── Mouse area ────────────────────────────────────
    MouseArea {
        id: mouse

        property real pressX: root.pillW / 2
        property real pressY: root.pillH / 2

        anchors.fill:    parent
        hoverEnabled:    true
        cursorShape:     Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onPressed: e => {
            pressX = e.x
            pressY = e.y

            fadeAnim.stop()
            root.circleRadius   = 0
            rippleShape.opacity = 0.18
            root.endRadiusAtPress = root.endRadius
            rippleAnim.restart()
        }

        onReleased: {
            if (!rippleAnim.running)
                fadeAnim.start()
        }

        onClicked: e => {
            if (e.button === Qt.LeftButton) {
                root.leftClicked()
                leftProc.running = true
            } else if (e.button === Qt.RightButton) {
                root.rightClicked()
                rightProc.running = true
            }
        }
    }

    // ── Ripple expand ─────────────────────────────────
    NumberAnimation {
        id: rippleAnim

        alwaysRunToEnd: true
        target:         root
        property:       "circleRadius"
        to:             root.endRadius
        duration:       root.animSlow * 2
        easing.type:    Easing.OutCubic

        onFinished: {
            if (!mouse.pressed)
                fadeAnim.start()
        }
    }

    // ── Ripple fade out ───────────────────────────────
    NumberAnimation {
        id: fadeAnim

        target:      rippleShape
        property:    "opacity"
        to:          0
        duration:    root.animNormal
        easing.type: Easing.OutCubic

        onFinished: root.circleRadius = 0
    }

    // ── Auto-fade when ripple reaches edge mid-hold ───
    onCircleRadiusChanged: {
        if (!mouse.pressed
                && circleRadius >= endRadiusAtPress * 0.99
                && !fadeAnim.running)
            fadeAnim.start()
    }
}
