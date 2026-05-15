import QtQuick
import qs.settings
import qs.components
import qs.services.clock

PillHover {
    Component.onCompleted: {
        ClockService.use24h      = Properties.clockUse24h
        ClockService.showSeconds = Properties.clockShowSeconds
    }

    alwaysExpanded: Properties.clockPillIsExpanded

    primaryText:   ClockService.timeString
    secondaryText: ClockService.dateString

    primaryFontSize:   Properties.clockPillTimeFontSize
    secondaryFontSize: Properties.clockPillDateFontSize
    fontFamily:        Properties.clockPillFontFamily

    primaryColor:   Theme.clockPillTimeColor
    secondaryColor: Theme.clockPillDateColor
    separatorColor: Theme.clockPillSeparatorColor

    pillBackground:        Theme.pillHoverBackground
    pillBackgroundHovered: Theme.pillHoverBackground

    pillRadius:   Properties.pillHoverRadius
    paddingX:     Properties.pillHoverPaddingX
    paddingY:     Properties.pillHoverPaddingY
    animDuration: Properties.pillHoverAnimDuration
}
