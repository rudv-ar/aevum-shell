import QtQuick
import qs.settings

Item {
    id: root

    property string primaryText:   ""
    property string secondaryText: ""

    property int    primaryFontSize:   13
    property int    secondaryFontSize: 12
    property string fontFamily:        Properties.clockPillFontFamily

    property color  primaryColor:          Theme.pillHoverPrimaryText
    property color  secondaryColor:        Theme.pillHoverSecondaryText
    property color  pillBackground:        "transparent"
    property color  pillBackgroundHovered: Theme.pillHoverBackground
    property color  separatorColor:        Theme.pillHoverSeparator

    property real   pillRadius:      Properties.pillHoverRadius
    property real   paddingX:        Properties.pillHoverPaddingX
    property real   paddingY:        Properties.pillHoverPaddingY
    property real   itemSpacing:     Properties.pillHoverSpacing
    property int    animDuration:    Properties.pillHoverAnimDuration

    property bool   alwaysExpanded:  false

    readonly property bool _expanded: alwaysExpanded || hoverHandler.hovered

    implicitWidth:  bg.width
    implicitHeight: Properties.barHeight

    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
    }

    Rectangle {
        id: bg
        anchors.verticalCenter:   parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        height: root.implicitHeight - root.paddingY * 2
        radius: root.pillRadius

        color: !root._expanded
               ? root.pillBackground
               : hoverHandler.hovered
                 ? Theme.pillStaticHoverBackground
                 : root.pillBackgroundHovered

        width: root._expanded
               ? (root.paddingX * 2
                  + primaryLabel.implicitWidth
                  + (secondaryText !== ""
                     ? root.itemSpacing * 2 + 1 + root.itemSpacing + secondaryLabel.implicitWidth
                     : 0))
               : (root.paddingX * 2 + primaryLabel.implicitWidth)

        Behavior on width {
            SmoothedAnimation { duration: root.animDuration; velocity: -1 }
        }
        Behavior on color {
            ColorAnimation { duration: root.animDuration }
        }
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 0

        Text {
            id: primaryLabel
            text:              root.primaryText
            color:             root.primaryColor
            font.pixelSize:    root.primaryFontSize
            font.family:       root.fontFamily
            verticalAlignment: Text.AlignVCenter
            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            id: secondaryWrapper
            height: root.implicitHeight
            clip:   true
            width:  root._expanded
                    ? (root.itemSpacing * 2 + separatorRect.width + secondaryLabel.implicitWidth)
                    : 0

            Behavior on width {
                SmoothedAnimation { duration: root.animDuration; velocity: -1 }
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0

                Item { width: root.itemSpacing; height: 1 }

                Rectangle {
                    id: separatorRect
                    width:  1
                    height: primaryLabel.implicitHeight * 0.65
                    anchors.verticalCenter: parent.verticalCenter
                    color:   root.separatorColor
                    opacity: root._expanded ? 1.0 : 0.0
                    Behavior on opacity {
                        NumberAnimation { duration: root.animDuration }
                    }
                }

                Item { width: root.itemSpacing; height: 1 }

                Text {
                    id: secondaryLabel
                    text:              root.secondaryText
                    color:             root.secondaryColor
                    font.pixelSize:    root.secondaryFontSize
                    font.family:       root.fontFamily
                    verticalAlignment: Text.AlignVCenter
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: root._expanded ? 1.0 : 0.0
                    Behavior on opacity {
                        NumberAnimation { duration: root.animDuration }
                    }
                }
            }
        }
    }
}
