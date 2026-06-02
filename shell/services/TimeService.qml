pragma Singleton

import QtQuick
import Quickshell
import qs.config

Singleton {
    id: root

    // ── Config ────────────────────────────────────────
    readonly property bool twelveHour: Theme.clockTwelveHour

    // ── Clock ─────────────────────────────────────────
    property alias enabled: clock.enabled
    readonly property date   date:    clock.date
    readonly property int    hours:   clock.hours
    readonly property int    minutes: clock.minutes
    readonly property int    seconds: clock.seconds

    // ── Pre-split strings ─────────────────────────────
    readonly property string timeStr: format(twelveHour ? "hh:mm:A" : "hh:mm")
    readonly property list<string> timeComponents: timeStr.split(":")
    readonly property string hourStr:   timeComponents[0] ?? ""
    readonly property string minuteStr: timeComponents[1] ?? ""
    readonly property string amPmStr:   timeComponents[2] ?? ""

    function format(fmt: string): string {
        return Qt.formatDateTime(clock.date, fmt)
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
