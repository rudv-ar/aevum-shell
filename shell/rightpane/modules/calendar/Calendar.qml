import Quickshell
import QtQuick
import qs.settings

Rectangle {
    id: card
    anchors.top:         parent.top
    anchors.left:        parent.left
    anchors.right:       parent.right
    anchors.topMargin:   6
    anchors.leftMargin:  6
    anchors.rightMargin: 6
    height:              calBody.implicitHeight + 16
    radius:              10
    color:        Qt.lighter(Theme.neutralP5, 1.20)
    border.color: Qt.lighter(Theme.neutralP5, 1.50)
    border.width: 1

    // ── State ─────────────────────────────────────
    property int viewYear:   Qt.formatDate(new Date(), "yyyy") * 1
    property int viewMonth:  Qt.formatDate(new Date(), "M") * 1 - 1
    property int todayDay:   Qt.formatDate(new Date(), "d") * 1
    property int todayMonth: Qt.formatDate(new Date(), "M") * 1 - 1
    property int todayYear:  Qt.formatDate(new Date(), "yyyy") * 1
    property int selectedDay: -1

    property var monthNames: [
        "January","February","March","April","May","June",
        "July","August","September","October","November","December"
    ]
    property var dayLabels: ["Su","Mo","Tu","We","Th","Fr","Sa"]

    function daysInMonth(y, m) { return new Date(y, m + 1, 0).getDate() }
    function firstWeekday(y, m) { return new Date(y, m, 1).getDay() }

    function prevMonth() {
        if (viewMonth === 0) { viewMonth = 11; viewYear-- }
        else viewMonth--
        selectedDay = -1
    }
    function nextMonth() {
        if (viewMonth === 11) { viewMonth = 0; viewYear++ }
        else viewMonth++
        selectedDay = -1
    }

    // ── Body ──────────────────────────────────────
    Column {
        id:              calBody
        anchors.left:    parent.left
        anchors.right:   parent.right
        anchors.top:     parent.top
        anchors.margins: 8
        spacing:         5

        // ── Header ────────────────────────────────
        Item {
            width:  parent.width
            height: 24

            Rectangle {
                id:     prevBtn
                width:  20; height: 20
                anchors.verticalCenter: parent.verticalCenter
                radius: 5
                color:  prevMa.containsMouse ? Theme.primaryP30 : "transparent"
                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text:             "\uf053"
                    font.family:      Theme.fontAwesome6
                    font.pixelSize:   8
                    color:            Theme.primaryP60
                    opacity:          prevMa.containsMouse ? 1.0 : 0.6
                    Behavior on opacity { NumberAnimation { duration: 100 } }
                }
                MouseArea {
                    id: prevMa; anchors.fill: parent
                    hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: card.prevMonth()
                }
            }

            Column {
                anchors.centerIn: parent
                spacing: 0

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:            card.monthNames[card.viewMonth]
                    color:           Theme.primaryP60
                    font.family:     Theme.fontPoppins
                    font.pixelSize:  11
                    font.weight:     Font.Medium
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:            card.viewYear
                    color:           Theme.primaryP50
                    font.family:     Theme.fontPoppins
                    font.pixelSize:  8
                    opacity:         0.6
                }
            }

            Rectangle {
                id:     nextBtn
                width:  20; height: 20
                anchors.right:          parent.right
                anchors.verticalCenter: parent.verticalCenter
                radius: 5
                color:  nextMa.containsMouse ? Theme.primaryP30 : "transparent"
                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text:             "\uf054"
                    font.family:      Theme.fontAwesome6
                    font.pixelSize:   8
                    color:            Theme.primaryP60
                    opacity:          nextMa.containsMouse ? 1.0 : 0.6
                    Behavior on opacity { NumberAnimation { duration: 100 } }
                }
                MouseArea {
                    id: nextMa; anchors.fill: parent
                    hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: card.nextMonth()
                }
            }
        }

        // ── Weekday labels ────────────────────────
        Row {
            width: parent.width; spacing: 0

            Repeater {
                model: card.dayLabels
                Text {
                    width:               parent.width / 7
                    horizontalAlignment: Text.AlignHCenter
                    text:                modelData
                    color:               index === 0 || index === 6
                                         ? Theme.secondaryP50
                                         : Theme.primaryP50
                    opacity:             0.55
                    font.family:         Theme.fontPoppins
                    font.pixelSize:      8
                    font.weight:         Font.Medium
                }
            }
        }

        // ── Divider ───────────────────────────────
        Rectangle {
            width: parent.width; height: 1
            color: Theme.primaryP30; opacity: 0.5
        }

        // ── Day grid ──────────────────────────────
        Grid {
            id:      dayGrid
            width:   parent.width
            columns: 7
            spacing: 2

            property int   offset:   card.firstWeekday(card.viewYear, card.viewMonth)
            property int   total:    card.daysInMonth(card.viewYear, card.viewMonth)
            property real  cellSize: (parent.width - spacing * 6) / 7
            property int   _key:     card.viewYear * 100 + card.viewMonth

            Repeater {
                model: dayGrid.offset + dayGrid.total

                delegate: Item {
                    id:     cell
                    width:  dayGrid.cellSize
                    height: dayGrid.cellSize

                    property int  day:        index - dayGrid.offset + 1
                    property bool empty:      index < dayGrid.offset
                    property bool isToday:    !empty && day === card.todayDay
                                              && card.viewMonth === card.todayMonth
                                              && card.viewYear  === card.todayYear
                    property bool isSelected: !empty && day === card.selectedDay
                    property bool isWeekend:  !empty && (index % 7 === 0 || index % 7 === 6)

                    // Today ring
                    Rectangle {
                        anchors.centerIn: parent
                        width:  parent.width - 1; height: parent.height - 1
                        radius: width / 2
                        visible: cell.isToday
                        color:   "transparent"
                        border.color: Theme.primaryP50
                        border.width: 1
                        opacity: 0.7
                    }

                    // Fill circle
                    Rectangle {
                        anchors.centerIn: parent
                        width:  cell.isToday || cell.isSelected
                                ? parent.width - 2 : parent.width - 6
                        height: width
                        radius: width / 2

                        color: cell.isToday
                               ? Theme.primaryP40
                               : cell.isSelected
                                 ? Theme.primaryP30
                                 : cellMa.containsMouse && !cell.empty
                                   ? Theme.primaryP30
                                   : "transparent"
                        opacity: cell.empty ? 0 : 1

                        Behavior on color { ColorAnimation { duration: 100 } }
                        Behavior on width { NumberAnimation { duration: 90; easing.type: Easing.OutQuad } }
                    }

                    // Day number
                    Text {
                        anchors.centerIn: parent
                        visible:          !cell.empty
                        text:             cell.empty ? "" : cell.day
                        color:            cell.isToday
                                          ? Theme.primaryP80
                                          : cell.isWeekend
                                            ? Theme.secondaryP50
                                            : Theme.primaryP60
                        opacity:          cell.isToday ? 1.0 : cell.isSelected ? 0.95 : 0.75
                        font.family:      Theme.fontPoppins
                        font.pixelSize:   9
                        font.weight:      cell.isToday ? Font.SemiBold : Font.Normal

                        Behavior on opacity { NumberAnimation { duration: 100 } }
                    }

                    MouseArea {
                        id: cellMa; anchors.fill: parent
                        enabled: !cell.empty; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: card.selectedDay = cell.day
                    }
                }
            }
        }

        // ── Footer: selected date ─────────────────
        Rectangle {
            width:   parent.width
            height:  card.selectedDay > 0 ? 20 : 0
            radius:  5
            color:   Theme.primaryP30
            opacity: card.selectedDay > 0 ? 1 : 0
            clip:    true

            Behavior on height  { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
            Behavior on opacity { NumberAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent
                visible: card.selectedDay > 0
                text: {
                    const d = new Date(card.viewYear, card.viewMonth, card.selectedDay)
                    return Qt.formatDate(d, "dddd, MMMM d")
                }
                color:          Theme.primaryP60
                font.family:    Theme.fontPoppins
                font.pixelSize: 9
                opacity:        0.85
            }
        }

        Item { width: 1; height: 1 }
    }
}

