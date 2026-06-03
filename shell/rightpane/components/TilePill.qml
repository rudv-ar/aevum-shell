import QtQuick
import Quickshell.Io
import qs.settings

Rectangle {
    id: pill

    enum State {
        Disabled,
        Off,
        On
    }

    property string glyphOn:      ""
    property string glyphOff:     ""
    property string glyphDisabled: ""
    property var    commandOn:    []
    property var    commandOff:   []
    property int    pillState:    TilePill.State.Off

    property bool hovered: false
    property bool pressed:  false

    readonly property bool isOn:       pillState === TilePill.State.On
    readonly property bool isOff:      pillState === TilePill.State.Off
    readonly property bool isDisabled: pillState === TilePill.State.Disabled

    width:  Properties.pillWidth
    height: Properties.pillHeight
    radius: Properties.pillRadius

    color: pill.isDisabled ? Theme.neutralP80
         : pill.pressed    ? Theme.secondaryP50
         : pill.hovered    ? Theme.secondaryP60
         : pill.isOn       ? Theme.primaryP40
         :                   Theme.neutralP20

    Behavior on color { ColorAnimation { duration: 130 } }
    Behavior on scale { NumberAnimation  { duration: 90; easing.type: Easing.OutCubic } }

    scale: pill.pressed ? 0.84 : 1.0

    opacity: pill.isDisabled ? 0.35 : 1.0
    Behavior on opacity { NumberAnimation { duration: 130 } }

    Text {
        anchors.centerIn: parent
        text:  pill.isDisabled ? pill.glyphDisabled
             : pill.isOn       ? pill.glyphOn
             :                   pill.glyphOff
        font.pixelSize: Properties.pillIconSize
        font.family:    Theme.fontAwesome6
        color: pill.isOn     ? Theme.neutralP0
             : pill.hovered  ? Theme.neutralP0
             :                 Theme.primaryP90
        Behavior on color { ColorAnimation { duration: 130 } }
    }

    Process {
        id: proc
        command: pill.isOn ? pill.commandOff : pill.commandOn
    }

    MouseArea {
        anchors.fill: parent
        enabled:      !pill.isDisabled
        hoverEnabled: true
        onEntered:  { pill.hovered = true }
        onExited:   { pill.hovered = false; pill.pressed = false }
        onPressed:  { pill.pressed = true }
        onReleased: { pill.pressed = false }
        onClicked:  {
            if (!proc.running) {
                proc.running = true
                pill.pillState = pill.isOn ? TilePill.State.Off
                                           : TilePill.State.On
            }
        }
    }
}  
