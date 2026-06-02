import QtQuick
import qs.config
import qs.services
import qs.utils

Item {
    id: root

    implicitWidth:  Theme.pillWidth
    implicitHeight: iconText.height + 6 + titleContainer.height

    // ── App icon ──────────────────────────────────────
    Text {
        id: iconText
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top:              parent.top
        text:                     Icons.getIcon(XTitleService.className)
        font.family:              Icons.fontFamily
        font.pixelSize:           15
        color:                    Theme.xtitleColor
    }

    // ── Rotated title container ───────────────────────
    // The trick: container's w/h are swapped from the text's w/h.
    // Text sits at 0,0 inside a same-size container, rotated -90°
    // around its own center, then the container is centered in root.
    Item {
        id: titleContainer

        width:  titleText.implicitHeight   // visual width  = text line-height
        height: titleText.implicitWidth    // visual height = text length

        anchors.top:              iconText.bottom
        anchors.topMargin:        6
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
            id: titleText
            x:      -(implicitWidth  - titleContainer.width)  / 2
            y:      -(implicitHeight - titleContainer.height) / 2

            text:               XTitleService.displayTitle
            color:              Theme.xtitleColor
            font.pixelSize:     12
            font.family:        Theme.fontPoppins
            font.letterSpacing: 2
            rotation:           90
        }
    }
}
