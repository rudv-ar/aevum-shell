pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import QtQuick.Effects
import qs.settings
import qs.components 
import qs.modules.quicktiles
import qs.modules.calendar


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

    //Calendar {}
    QuickTileRow {}
}
