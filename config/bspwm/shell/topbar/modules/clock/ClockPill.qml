import QtQuick
import qs.settings
import qs.components
import qs.services.clock

PillStatic {
    Component.onCompleted: {
        ClockService.use24h      = Properties.clockUse24h
        ClockService.showSeconds = Properties.clockShowSeconds
    }

    text: ClockService.timeString
          + "<font color='" + Theme.clockPillSeparatorColor + "'>  |  </font>"
          + "<font color='" + Theme.clockPillDateColor + "'>" + ClockService.dateString + "</font>"

    textFormat: Text.RichText

    fontSize:   Properties.clockPillTimeFontSize
    fontFamily: Properties.clockPillFontFamily
    textColor:  Theme.clockPillTimeColor
}  
