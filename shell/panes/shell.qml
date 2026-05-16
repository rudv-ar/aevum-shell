pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import Quickshell
import qs.settings
import qs.services
import qs.components

ShellRoot {

    // ── Pane windows (one per direction) ───────────────────────────
    RightPane  {}
    LeftPane   {}
    TopPane    {}
    BottomPane {}

    // ── Border / frame window ───────────────────────────────────────
    PanelWindow {
        id: win

        implicitWidth:  Screen.width
        implicitHeight: Screen.height
        color:          "transparent"
        mask:           Region {}       // entire window is click-through

        // ── Animated hole margins ───────────────────────────────────
        //    Each direction independently drives its own margin.
        //    Only one can be non-base at a time because PaneState.activePane
        //    is a single string.

        property real _rightMargin: PaneState.activePane === "right"
            ? Properties.borderThickness + Properties.panelWidth + Properties.panelRightMargin
            : Properties.borderThickness

        property real _leftMargin: PaneState.activePane === "left"
            ? Properties.borderThickness + Properties.panelWidth + Properties.panelLeftMargin
            : Properties.borderThickness

        property real _topMargin: PaneState.activePane === "top"
            ? Properties.topOffset + Properties.panelHeight + Properties.panelTopMargin
            : Properties.topOffset

        property real _bottomMargin: PaneState.activePane === "bottom"
            ? Properties.borderThickness + Properties.panelHeight + Properties.panelBottomMargin
            : Properties.borderThickness

        Behavior on _rightMargin  { NumberAnimation { duration: Properties.animDuration; easing.type: Easing.OutCubic } }
        Behavior on _leftMargin   { NumberAnimation { duration: Properties.animDuration; easing.type: Easing.OutCubic } }
        Behavior on _topMargin    { NumberAnimation { duration: Properties.animDuration; easing.type: Easing.OutCubic } }
        Behavior on _bottomMargin { NumberAnimation { duration: Properties.animDuration; easing.type: Easing.OutCubic } }

        // ── Visible border rectangle ────────────────────────────────
        Rectangle {
            anchors.fill:      parent
            anchors.topMargin: Properties.marginCover
            color:             Theme.borderColor

            layer.enabled: true
            layer.effect: MultiEffect {
                maskSource:       innerMask
                maskEnabled:      true
                maskInverted:     true
                maskThresholdMin: 0.5
                maskSpreadAtMin:  1.0
            }
        }

        // ── Mask: punches the hole ──────────────────────────────────
        Item {
            id: innerMask
            anchors.fill: parent
            layer.enabled: true
            opacity: 0

            Rectangle {
                anchors.fill:         parent
                anchors.topMargin:    win._topMargin
                anchors.leftMargin:   win._leftMargin
                anchors.rightMargin:  win._rightMargin
                anchors.bottomMargin: win._bottomMargin
                radius:               Properties.cornerRadius
            }
        }
    }
}
