pragma ComponentBehavior: Bound

import QtQuick
import qs.config
import qs.services

Item {
    id: root

    // ── Tokens ────────────────────────────────────────
    readonly property int    pillW:      Theme.pillWidth
    readonly property int    iconSize:   Theme.pillIconSize
    readonly property int    timeSize:   Theme.clockTimeSize
    readonly property int    dateSize:   Theme.clockDateSize
    readonly property int    padV:       Theme.clockPadV
    readonly property int    spacing:    Theme.clockSpacing
    readonly property bool   showIcon:   Theme.clockShowIcon
    readonly property bool   showDate:   Theme.clockShowDate
    readonly property color  col:        Theme.statusIconColor
    readonly property string fontMat:    Theme.fontMaterial
    readonly property string fontMono:   Theme.fontMono

    implicitWidth:  pillW
    implicitHeight: pill.implicitHeight

    // ── Pill ──────────────────────────────────────────
    Rectangle {
        id: pill

        anchors.left:  parent.left
        anchors.right: parent.right
        radius:        width / 2
        color:         Theme.colorClockPill ? Theme.workspaceBg : "transparent"
        clip:          true

        implicitHeight: col.implicitHeight + root.padV * 2

        Column {
            id: col

            anchors.centerIn: parent
            spacing:          root.spacing

            // ── Calendar icon ─────────────────────────
            Loader {
                asynchronous:             true
                anchors.horizontalCenter: parent.horizontalCenter
                active:                   root.showIcon
                visible:                  active

                sourceComponent: Text {
                    text:           "calendar_month"
                    font.family:    root.fontMat
                    font.pixelSize: root.iconSize
                    color:          root.col
                    renderType:     Text.NativeRendering
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            // ── Date ──────────────────────────────────
            Loader {
                asynchronous:             true
                anchors.horizontalCenter: parent.horizontalCenter
                active:                   root.showDate
                visible:                  active

                sourceComponent: Text {
                    text:           TimeService.format("ddd\nd")
                    font.family:    root.fontMono
                    font.pixelSize: root.dateSize
                    color:          root.col
                    renderType:     Text.NativeRendering
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            // ── Separator ─────────────────────────────
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                visible:                  root.showDate
                height:                   visible ? 1 : 0
                width:                    root.pillW * 0.8
                color:                    root.col
                opacity:                  0.2
            }

            // ── Time ──────────────────────────────────
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Theme.clockTwelveHour
                    ? TimeService.hourStr + "\n" + TimeService.minuteStr + "\n" + TimeService.amPmStr
                    : TimeService.hourStr + "\n" + TimeService.minuteStr
                font.family:         root.fontMono
                font.pixelSize:      root.timeSize
                color:               root.col
                renderType:          Text.NativeRendering
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
