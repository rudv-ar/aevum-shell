import QtQuick
import Quickshell.Io
import qs.settings

Rectangle {
    id: pill

    signal actionTriggered()


    property string glyph:      ""
    property var    command:     []
    property color  accentColor: Theme.accent

    property bool hovered: false
    property bool pressed:  false

    width:  Properties.pillWidth
    height: Properties.pillHeight
    radius: Properties.pillRadius

    color: pill.pressed ? Qt.darker(pill.accentColor, 1.5)
         : pill.hovered ? Qt.lighter(Theme.neutralP15, 1.2)
         :                Theme.neutralP10

    Behavior on color { ColorAnimation { duration: 130 } }
    Behavior on scale { NumberAnimation  { duration: 90; easing.type: Easing.OutCubic } }

    scale: pill.pressed ? 0.84 : 1.0

    Text {
        anchors.centerIn: parent
        text:             pill.glyph
        font.pixelSize:   Properties.pillIconSize
        font.family:      Properties.iconFont
        color:            pill.hovered ? pill.accentColor : Theme.primaryP100
        Behavior on color { ColorAnimation { duration: 130 } }
    }

    Process {
        id: proc
        command: pill.command
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered:  { pill.hovered = true }
        onExited:   { pill.hovered = false; pill.pressed = false }
        onPressed:  { pill.pressed = true }
        onReleased: { pill.pressed = false }
        onClicked:  { 
          if (!proc.running) proc.running = true 
          actionTriggered()
        }
    }
}
