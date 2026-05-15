import QtQuick
import qs.settings

Item {
    id: root

    property string text:               ""
    property int    fontSize:           13
    property string fontFamily:         Properties.clockPillFontFamily
    property color  textColor:          Theme.pillStaticText
    property color  pillBackground:     Theme.pillStaticBackground
    property color  pillHoverBackground: Theme.pillStaticHoverBackground  // add to Theme
    property real   pillRadius:         Properties.pillStaticRadius
    property real   paddingX:           Properties.pillStaticPaddingX
    property int textFormat: Text.AutoText
    property real   paddingY:           Properties.pillStaticPaddingY

    implicitWidth:  label.implicitWidth + paddingX * 2
    implicitHeight: Properties.barHeight

    Rectangle {
        id: pill
        anchors.verticalCenter:   parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        width:  root.implicitWidth
        height: root.implicitHeight - root.paddingY * 2
        radius: root.pillRadius
        color:  hoverHandler.hovered ? root.pillHoverBackground : root.pillBackground

        Behavior on color {
            ColorAnimation { duration: 120 }
        }
    }

    Text {
        id: label
        anchors.centerIn:  parent
        text:              root.text
        textFormat:        root.textFormat
        color:             root.textColor
        font.pixelSize:    root.fontSize
        font.family:       root.fontFamily
        verticalAlignment: Text.AlignVCenter
    }

    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
    }
}
