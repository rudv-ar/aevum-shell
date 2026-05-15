import qs.settings
import qs.modules
import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Io

PanelWindow {
    id: root

    margins { right: 10 }

    property real  notchWidth:     Properties.powerMenuWidthInitial
    property real  notchHeight:    Properties.powerMenuHeight
    property real  cornerRadius:   Properties.powerMenuCornerRadius
    property real  shoulderRadius: Properties.powerMenuShoulderRadius
    property color fillColor:      Theme.background
    property color borderColor:    Qt.lighter(fillColor, 1.25)
    property real  borderWidth:    Properties.powerMenuBorderWidth

    readonly property real sr: Math.min(shoulderRadius, notchWidth * 0.4)
    readonly property real cr: Math.min(cornerRadius,   Math.max(0, notchWidth - sr))

    implicitWidth: Properties.powerMenuImplicitWidth
    color: "transparent"

    anchors { right: true; top: true; bottom: true }
    exclusionMode: ExclusionMode.Ignore

    mask: Region {
        item: Item {
            x:      root.implicitWidth - root.notchWidth - root.sr
            y:      (root.height - root.notchHeight) / 2 - root.sr
            width:  root.notchWidth + root.sr
            height: root.notchHeight + root.sr * 2
        }
    }

    Behavior on notchWidth { NumberAnimation { duration: 200; easing.type: Easing.InOutCubic } }

    IpcHandler {
        target: "powermenu"
        function expand(): void   { root.notchWidth = Properties.powerMenuWidthExpanded }
        function contract(): void { root.notchWidth = Properties.powerMenuWidthInitial }
        function toggle(): void {
            root.notchWidth = (root.notchWidth === Properties.powerMenuWidthInitial)
                ? Properties.powerMenuWidthExpanded
                : Properties.powerMenuWidthInitial
        }
    }

    // ── Shape (background notch) — rendered first (below) ────────
    Shape {
        anchors.right:  parent.right
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        width: root.implicitWidth

        layer.enabled: true
        layer.samples: 4

        ShapePath {
            fillColor:   root.fillColor
            strokeColor: root.borderColor
            strokeWidth: root.borderWidth

            startX: width
            startY: (height - root.notchHeight) / 2 - root.sr

            PathArc {
                relativeX: -root.sr; relativeY: root.sr
                radiusX: root.sr;    radiusY: root.sr
                direction: PathArc.Clockwise
            }
            PathLine { relativeX: -(root.notchWidth - root.sr - root.cr); relativeY: 0 }
            PathArc {
                relativeX: -root.cr; relativeY: root.cr
                radiusX: root.cr;    radiusY: root.cr
                direction: PathArc.Counterclockwise
            }
            PathLine { relativeX: 0; relativeY: root.notchHeight - root.cr * 2 }
            PathArc {
                relativeX: root.cr; relativeY: root.cr
                radiusX: root.cr;   radiusY: root.cr
                direction: PathArc.Counterclockwise
            }
            PathLine { relativeX: root.notchWidth - root.sr - root.cr; relativeY: 0 }
            PathArc {
                relativeX: root.sr; relativeY: root.sr
                radiusX: root.sr;   radiusY: root.sr
                direction: PathArc.Clockwise
            }
        }
    }

    // ── PowerBoard — rendered after Shape (sits on top) ───────────
    PowerBoard {
        x:      root.implicitWidth - root.notchWidth
        y:      (root.height - root.notchHeight) / 2
        width:  root.notchWidth
        height: root.notchHeight
        clip:   true

        visible: opacity > 0
        opacity: Math.max(0,
            (root.notchWidth - Properties.powerMenuWidthInitial) /
            (Properties.powerMenuWidthExpanded - Properties.powerMenuWidthInitial)
        )

        Behavior on opacity { NumberAnimation { duration: 180 } }
    }
}
