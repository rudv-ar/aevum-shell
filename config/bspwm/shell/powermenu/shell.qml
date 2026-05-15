import qs.settings
import qs.modules
import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Io

PanelWindow {
    id: root

    property real  notchWidth:        Properties.powerMenuWidthInitial
    property real  notchHeight:       Properties.powerMenuHeight
    property real  cornerRadius:      Properties.powerMenuCornerRadius
    property real  shoulderRadius:    Properties.powerMenuShoulderRadius
    property color fillColor:         Theme.background
    property color borderColor:       Qt.lighter(fillColor, 1.25)
    property real  borderWidth:       Properties.powerMenuBorderWidth
    property real  menuRightMargin:   10
    property real  menuImplicitWidth: Properties.powerMenuImplicitWidth

    readonly property real sr: Math.min(shoulderRadius, notchWidth * 0.4)
    readonly property real cr: Math.min(cornerRadius, Math.max(0, notchWidth - sr))

    readonly property real notchX: root.width - root.menuRightMargin - root.notchWidth
    readonly property real notchY: (root.height - root.notchHeight) / 2

    readonly property real expandProgress: Math.max(0, Math.min(1,
        (root.notchWidth - Properties.powerMenuWidthInitial) /
        (Properties.powerMenuWidthExpanded - Properties.powerMenuWidthInitial)
    ))

    readonly property bool fullyContracted: notchWidth <= Properties.powerMenuWidthInitial

    // Guards the Behavior — set true to snap notchWidth without animation
    property bool _instant: false

    color: "transparent"
    anchors { left: true; right: true; top: true; bottom: true }
    exclusionMode: ExclusionMode.Ignore

    Behavior on notchWidth {
        enabled: !root._instant
        NumberAnimation { duration: 150; easing.type: Easing.InOutCubic }
    }

    // Snap shut immediately — for button actions
    function contractInstant(): void {
        root._instant = true
        PowerMenuState.expanded = false
        root.notchWidth = Properties.powerMenuWidthInitial
        root._instant = false
    }

    // ── Input mask ────────────────────────────────────────────────
    mask: Region {
        item: Item {
            x:      root.fullyContracted ? (root.width - root.menuRightMargin - root.notchWidth - root.sr) : 0
            y:      root.fullyContracted ? (root.notchY - root.sr) : 0
            width:  root.fullyContracted ? (root.notchWidth + root.sr) : root.width
            height: root.fullyContracted ? (root.notchHeight + root.sr * 2) : root.height
        }
    }

    // ── IPC ───────────────────────────────────────────────────────
    IpcHandler {
        target: "powermenu"
        function expand(): void {
            PowerMenuState.expanded = true
            root.notchWidth = Properties.powerMenuWidthExpanded
        }
        function contract(): void {
            PowerMenuState.expanded = false
            root.notchWidth = Properties.powerMenuWidthInitial
        }
        function toggle(): void {
            PowerMenuState.expanded = !PowerMenuState.expanded
            root.notchWidth = PowerMenuState.expanded
                ? Properties.powerMenuWidthExpanded
                : Properties.powerMenuWidthInitial
        }
    }

    // ── Backdrop dim ──────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.45)
        opacity: root.expandProgress
    }

    // ── Backdrop dismiss ──────────────────────────────────────────
    MouseArea {
        anchors.fill: parent
        enabled: PowerMenuState.expanded
        onClicked: mouse => {
            const inNotch = mouse.x >= root.notchX
                         && mouse.x <= root.width - root.menuRightMargin
                         && mouse.y >= root.notchY
                         && mouse.y <= root.notchY + root.notchHeight
            if (inNotch) return
            PowerMenuState.expanded = false
            root.notchWidth = Properties.powerMenuWidthInitial
        }
    }

    // ── Notch shape ───────────────────────────────────────────────
    Shape {
        id: menuShape
        anchors.right:       parent.right
        anchors.rightMargin: root.menuRightMargin
        anchors.top:         parent.top
        anchors.bottom:      parent.bottom
        width: root.menuImplicitWidth

        layer.enabled: true
        layer.samples: 4

        ShapePath {
            fillColor:   root.fillColor
            strokeColor: root.borderColor
            strokeWidth: root.borderWidth

            startX: menuShape.width
            startY: root.notchY - root.sr

            PathArc {
                relativeX: -root.sr; relativeY:  root.sr
                radiusX:    root.sr; radiusY:    root.sr
                direction:  PathArc.Clockwise
            }
            PathLine { relativeX: -(root.notchWidth - root.sr - root.cr); relativeY: 0 }
            PathArc {
                relativeX: -root.cr; relativeY:  root.cr
                radiusX:    root.cr; radiusY:    root.cr
                direction:  PathArc.Counterclockwise
            }
            PathLine { relativeX: 0; relativeY: root.notchHeight - root.cr * 2 }
            PathArc {
                relativeX:  root.cr; relativeY:  root.cr
                radiusX:    root.cr; radiusY:    root.cr
                direction:  PathArc.Counterclockwise
            }
            PathLine { relativeX: root.notchWidth - root.sr - root.cr; relativeY: 0 }
            PathArc {
                relativeX:  root.sr; relativeY:  root.sr
                radiusX:    root.sr; radiusY:    root.sr
                direction:  PathArc.Clockwise
            }
        }
    }

    // ── Power board ───────────────────────────────────────────────
    PowerBoard {
        x:      root.notchX
        y:      root.notchY
        width:  root.notchWidth
        height: root.notchHeight
        clip:   true

        visible: opacity > 0
        opacity: root.expandProgress

        Behavior on opacity { NumberAnimation { duration: 0 } }

        // Fired by PowerBoard buttons — snap shut with no animation
        Connections {
            function onActionTriggered() { root.contractInstant() }
        }
    }
}
