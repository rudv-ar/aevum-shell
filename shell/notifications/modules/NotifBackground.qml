import QtQuick
import QtQuick.Shapes
import qs.services.notifs
import qs.settings

Item {
    id: root

    readonly property real panelWidth: Properties.notifBackgroundWidth
    readonly property real rounding:   Properties.notifBackgroundRounding
    readonly property real pad:        Properties.notifBackgroundPadding

    implicitWidth:  panelWidth
    implicitHeight: Properties.notifBackgroundHeight

    property real drawnH: 0

    // ── Gate: Background Resize ──────────────────────────────────────
    Behavior on drawnH {
        enabled: Anim.globalEnabled && Anim.notifBackgroundAnimEnabled
        NumberAnimation {
            duration:    Anim.notifBaseDuration
            easing.type: Easing.OutExpo
        }
    }

    function updateDrawnH() {
        if (!notifList) return;
        // Ensure background calculates immediately if items exist
        root.drawnH = notifList.count > 0 
            ? Math.max(0, notifList.contentHeight + root.pad * 2) 
            : 0
    }

    Component.onCompleted: updateDrawnH()

    Connections {
        target: notifList
        function onCountChanged()         { root.updateDrawnH() }
        function onContentHeightChanged() { root.updateDrawnH() }
    }

    // ── Shape ────────────────────────────────────────────────────────
    Item {
        id: sc
        width:   root.panelWidth
        height:  root.implicitHeight
        anchors.right:  parent.right
        anchors.bottom: parent.bottom
        visible: root.drawnH > 0.1 // Safety: Show if there's any height

        Shape {
            anchors.fill: parent
            asynchronous: true
            layer.enabled: true
            layer.samples: 4

            ShapePath {
                fillColor:   Theme.notifBackgroundBg
                strokeColor: Qt.lighter(Theme.notifBackgroundBg, 1.15)
                strokeWidth: 1

                startX: sc.width
                startY: sc.height

                PathLine { x: sc.width - root.panelWidth; y: sc.height }
                PathArc {
                    relativeX: root.rounding; relativeY: -root.rounding
                    radiusX:   root.rounding; radiusY:    root.rounding
                    direction: PathArc.Counterclockwise
                }
                PathLine {
                    x: sc.width - root.panelWidth + root.rounding
                    y: sc.height - root.drawnH + root.rounding
                }
                PathArc {
                    relativeX: root.rounding; relativeY: -root.rounding
                    radiusX:   root.rounding; radiusY:    root.rounding
                    direction: PathArc.Clockwise
                }
                PathLine {
                    x: sc.width - root.rounding
                    y: sc.height - root.drawnH
                }
                PathArc {
                    relativeX: root.rounding; relativeY: -root.rounding
                    radiusX:   root.rounding; radiusY:    root.rounding
                    direction: PathArc.Counterclockwise
                }
                PathLine { x: sc.width; y: sc.height }
            }
        }
    }

    // ── Toast ListView ───────────────────────────────────────────────
    ListView {
        id: notifList
        model: NotifServer.notifModel
        width:  root.panelWidth - root.rounding - 16

        y:      root.implicitHeight - root.drawnH + root.pad
        // Use Math.max to prevent negative height crashes
        height: Math.max(0, root.drawnH - root.pad * 2)

        anchors.right:       parent.right
        anchors.left:        parent.left
        anchors.bottom:      parent.bottom
        anchors.rightMargin: Properties.notifBackgroundToastRightMargin
        anchors.leftMargin:  Properties.notifBackgroundToastLeftMargin
        anchors.bottomMargin: Properties.notifBackgroundToastBottomMargin

        clip:        false
        spacing:     Properties.notifBackgroundToastSpacing
        interactive: false

        delegate: NotifToast { width: notifList.width }

        // ── STRICT GATING ────────────────────────────────────────────
        // We gate via 'duration' because ListView often ignores 'null' 
        // assignments to transitions after the first render.
        readonly property bool allowAnim: Anim.globalEnabled && Anim.notifListTransitionsEnabled

        add: Transition {
            ParallelAnimation {
                NumberAnimation { 
                    property: "opacity"; from: 0.0; to: 1.0
                    duration: notifList.allowAnim ? 260 : 0 
                }
                NumberAnimation { 
                    property: "x"; from: 48; to: 0
                    duration: notifList.allowAnim ? 300 : 0
                    easing.type: Easing.OutExpo 
                }
                // First Notification Entrance Gate
                NumberAnimation {
                    property: "y"
                    from: (notifList.allowAnim && Anim.notifFirstEntryEnabled && notifList.count === 1) ? 60 : 0
                    duration: (notifList.allowAnim && Anim.notifFirstEntryEnabled && notifList.count === 1) ? 320 : 0
                    easing.type: Easing.OutExpo
                }
            }
        }

        remove: Transition {
            ParallelAnimation {
                NumberAnimation { 
                    property: "opacity"; to: 0.0
                    duration: notifList.allowAnim ? 180 : 0 
                }
                NumberAnimation { 
                    property: "x"; to: 48
                    duration: notifList.allowAnim ? 180 : 0 
                }
            }
        }

        displaced: Transition {
            NumberAnimation { 
                properties: "y,x,opacity"
                duration: notifList.allowAnim ? 240 : 0
                easing.type: Easing.OutCubic 
            }
        }
    }
}

