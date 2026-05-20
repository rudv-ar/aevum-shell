pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import QtQuick.Effects
import qs.settings
import qs.components 
import qs.modules.quicktiles


Rectangle {
    anchors.top:          parent.top
    anchors.right:        parent.right
    anchors.bottom:       parent.bottom
    anchors.topMargin:    Properties.marginCover + Properties.topOffset
    anchors.bottomMargin: Properties.borderThickness
    anchors.rightMargin:  Properties.borderThickness

    width:   win.animatedRight - Properties.borderThickness - 10
    color:   "transparent"
    radius:  Properties.cornerRadius
    clip:    true
    enabled: win.paneOpen
    opacity: Math.max(0, (win.animatedRight - Properties.borderThickness - 20) / (Properties.paneWidth - Properties.borderThickness - 20))
    visible: opacity > 0

    // ── Card ──────────────────────────────────────────
    Rectangle {
        id: card
        anchors.top:         parent.top
        anchors.left:        parent.left
        anchors.right:       parent.right
        anchors.topMargin:   10
        anchors.leftMargin:  10
        anchors.rightMargin: 10
        height:              220
        radius:              15

        color:        Theme.neutralP5
        border.color: Qt.lighter(card.color, 1.45)
        border.width: 1

        Column {
            anchors.centerIn: parent
            spacing:          10

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text:                    "\uf303"
                color:                   Theme.foreground
                font.pixelSize:          64
                font.family:             Theme.fontAwesome6
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text:                    "This feature is being built, will be released soon!"
                color:                   Theme.foreground
                font.pixelSize:          11
                opacity:                 0.5
                horizontalAlignment:     Text.AlignHCenter
                wrapMode:                Text.WordWrap
                width:                   card.width - 24
            }
        }
    }
    QuickTileRow {}
}
