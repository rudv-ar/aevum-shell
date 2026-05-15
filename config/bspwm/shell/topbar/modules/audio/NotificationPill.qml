import QtQuick
import qs.settings
import qs.components

Item {
    id: root

    implicitWidth:  _pill.implicitWidth
    implicitHeight: _pill.implicitHeight

    BasePill {
        id: _pill

        glyph:      Properties.rightbarNotificationGlyph
        fontFamily: Properties.nerdFontFamily
        label:      "notify-center"

        onClicked:  function(mouse) {}
        onScrolled: function(delta) {}
    }
}

