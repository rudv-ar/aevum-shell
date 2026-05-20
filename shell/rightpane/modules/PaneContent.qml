import Quickshell 
import QtQuick
import qs.settings

// ── Pane content ──────────────────────────────────────
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

    Column {
        anchors.centerIn: parent
        spacing: 12

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:           "\uf303"
            color:          Theme.foreground
            font.pixelSize: 64
            font.family:    "Font Awesome 6 Free"  // or whichever nerd/icon font you use
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:           "This feature is being built, please wait."
            color:          Theme.foreground
            font.pixelSize: 11
            opacity:        0.5
            horizontalAlignment: Text.AlignHCenter
            wrapMode:       Text.WordWrap
            width:          parent.parent.width - 20
        }
    }
} 
