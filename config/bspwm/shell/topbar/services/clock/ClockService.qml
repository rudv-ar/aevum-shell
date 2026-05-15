pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    property bool use24h:      true
    property bool showSeconds: false

    SystemClock {
        id: _clock
        precision: SystemClock.Seconds
    }

    // ── Raw values — all derived from .date to avoid undefined on init ────────
    readonly property int second:     _clock.date.getSeconds()
    readonly property int minute:     _clock.date.getMinutes()
    readonly property int hour:       _clock.date.getHours()
    readonly property int dayOfMonth: _clock.date.getDate()
    readonly property int month:      _clock.date.getMonth() + 1
    readonly property int year:       _clock.date.getFullYear()

    // ── Named ─────────────────────────────────────────────────────────────────
    readonly property string dayName:       Qt.formatDateTime(_clock.date, "ddd")
    readonly property string dayNameFull:   Qt.formatDateTime(_clock.date, "dddd")
    readonly property string monthName:     Qt.formatDateTime(_clock.date, "MMM")
    readonly property string monthNameFull: Qt.formatDateTime(_clock.date, "MMMM")
    readonly property string timezone:      Qt.formatDateTime(_clock.date, "t")
    readonly property string ampm:          Qt.formatDateTime(_clock.date, "AP")

    // ── Formatted strings ─────────────────────────────────────────────────────
    readonly property string timeString: {
        if (showSeconds)
            return use24h
                ? Qt.formatDateTime(_clock.date, "HH:mm:ss")
                : Qt.formatDateTime(_clock.date, "h:mm:ss AP")
        return use24h
            ? Qt.formatDateTime(_clock.date, "HH:mm")
            : Qt.formatDateTime(_clock.date, "h:mm AP")
    }

    readonly property string dateString:     Qt.formatDateTime(_clock.date, "ddd, d MMM")
    readonly property string dateStringFull: Qt.formatDateTime(_clock.date, "dddd, d MMMM yyyy")

    readonly property string hourString:   use24h
        ? Qt.formatDateTime(_clock.date, "HH")
        : Qt.formatDateTime(_clock.date, "hh")
    readonly property string minuteString: Qt.formatDateTime(_clock.date, "mm")
    readonly property string secondString: Qt.formatDateTime(_clock.date, "ss")
}

