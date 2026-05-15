import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.services.notifs
import qs.settings

Item {
    id: toastRoot

    required property var modelData

    property var notif:               modelData ? modelData.notif  : null
    readonly property int notifCount: modelData ? (modelData.count || 1) : 1

    // ── App icon glyph lookup ─────────────────────────────────────────────
    function appIconGlyph(appName) {
        const n = (appName || "").toLowerCase()
        if (n.includes("firefox")   || n.includes("librewolf"))           return "\uf269"
        if (n.includes("chrome")    || n.includes("chromium") ||
            n.includes("brave"))                                            return "\uf268"
        if (n.includes("discord"))                                          return "\uf392"
        if (n.includes("telegram"))                                         return "\uf2c6"
        if (n.includes("slack"))                                            return "\uf198"
        if (n.includes("signal"))                                           return "\uf27a"
        if (n.includes("whatsapp"))                                         return "\uf232"
        if (n.includes("element")   || n.includes("matrix"))               return "\uf27a"
        if (n.includes("mail")      || n.includes("thunderbird") ||
            n.includes("evolution") || n.includes("geary"))                return "\uf0e0"
        if (n.includes("spotify"))                                          return "\uf1bc"
        if (n.includes("rhythmbox") || n.includes("clementine") ||
            n.includes("deadbeef")  || n.includes("lollypop") ||
            n.includes("audacious") || n.includes("mpd"))                  return "\uf025"
        if (n.includes("vlc")       || n.includes("mpv"))                  return "\uf144"
        if (n.includes("steam"))                                            return "\uf1b6"
        if (n.includes("lutris")    || n.includes("heroic"))               return "\uf11b"
        if (n.includes("vscode")    || n.includes("vscodium") ||
            n.includes("codium")    || n === "code")                       return "\uf121"
        if (n.includes("github-desktop"))                                   return "\uf09b"
        if (n.includes("git"))                                              return "\ue702"
        if (n.includes("update")    || n.includes("packagekit") ||
            n.includes("pamac")     || n.includes("pacman"))               return "\uf0ad"
        if (n.includes("network")   || n.includes("nm-") ||
            n.includes("networkmanager"))                                   return "\uf1eb"
        if (n.includes("bluetooth"))                                        return "\uf294"
        if (n.includes("battery"))                                          return "\uf240"
        if (n.includes("volume")    || n.includes("audio") ||
            n.includes("pipewire")  || n.includes("pulse"))                return "\uf028"
        if (n.includes("screenshot")|| n.includes("flameshot") ||
            n.includes("grim"))                                             return "\uf030"
        if (n.includes("calendar"))                                         return "\uf073"
        if (n.includes("clock")     || n.includes("alarm"))                return "\uf017"
        if (n.includes("download")  || n.includes("transmission") ||
            n.includes("qbittorrent"))                                      return "\uf019"
        if (n.includes("terminal")  || n.includes("kitty") ||
            n.includes("alacritty") || n.includes("foot"))                 return "\uf120"
        if (n.includes("file")      || n.includes("thunar") ||
            n.includes("nautilus")  || n.includes("yazi"))                 return "\uf07b"
        return ""
    }

    // ── Urgency ───────────────────────────────────────────────────────────
    readonly property color urgencyColor: {
        if (!notif) return Theme.notifNormalBg
        if (notif.urgency === NotificationUrgency.Critical) return Properties.notifCriticalBg
        if (notif.urgency === NotificationUrgency.Low)      return Properties.notifLowBg
        return Theme.notifNormalBg
    }
    readonly property bool isCritical: !!notif && notif.urgency === NotificationUrgency.Critical

    // ── Timer ─────────────────────────────────────────────────────────────
    readonly property int  timeoutMs:     notif ? NotifServer.resolveTimeout(notif) : 0
    property      int      elapsedMs:     0
    readonly property real timerFraction: timeoutMs > 0
        ? Math.max(0.0, 1.0 - elapsedMs / timeoutMs)
        : -1.0

    // ── Hover ─────────────────────────────────────────────────────────────
    HoverHandler {
        id: hoverHandler
        acceptedButtons: Qt.NoButton
    }
    readonly property bool hovered: hoverHandler.hovered

    // ── Body expand state ─────────────────────────────────────────────────
    property bool bodyFullExpanded:  false
    property bool bodyUserCollapsed: false

    readonly property int bodyMaxLines: {
        if (bodyFullExpanded)  return 999999
        if (bodyUserCollapsed) return 1
        if (toastRoot.hovered) return 2
        return 1
    }

    onNotifChanged: {
        bodyFullExpanded  = false
        bodyUserCollapsed = false
    }

    Text {
        id: _truncDetect
        visible:          false
        x:                -10000
        width:            contentCol.width
        text:             notif ? notif.body : ""
        textFormat:       Text.PlainText
        font.pixelSize:   12
        wrapMode:         Text.WordWrap
        lineHeight:       1.25
        maximumLineCount: toastRoot.bodyMaxLines
    }

    readonly property bool bodyWouldTruncate: _truncDetect.truncated
    readonly property real bodyClipHeight:    _truncDetect.implicitHeight

    // ── Height ────────────────────────────────────────────────────────────
    implicitHeight: contentCol.implicitHeight + 20 + (timerFraction >= 0.0 ? 10 : 0)
    Behavior on implicitHeight {
        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
    }

    // ── Swipe-to-dismiss ──────────────────────────────────────────────────
    property real swipeX: 0

    Behavior on swipeX {
        enabled: !dragHandler.active
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }

    transform: Translate { x: toastRoot.swipeX }

    opacity: {
        const ratio = Math.abs(toastRoot.swipeX) / (toastRoot.width * 0.55)
        return Math.max(0.15, 1.0 - ratio)
    }
    Behavior on opacity {
        enabled: !dragHandler.active
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }

    DragHandler {
        id: dragHandler
        target:        null
        xAxis.enabled: true
        yAxis.enabled: false
        onActiveTranslationChanged: {
            if (active) toastRoot.swipeX = activeTranslation.x
        }
        onActiveChanged: {
            if (!active) {
                if (Math.abs(toastRoot.swipeX) > 80)
                    NotifServer.dismiss(toastRoot.notif)
                else
                    toastRoot.swipeX = 0
            }
        }
    }

    // ── Background ────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        radius: 12
        color:  Theme.notifToastBg
        border {
            color: isCritical ? urgencyColor : Qt.rgba(1, 1, 1, 0.05)
            width: isCritical ? 1.5 : 1
        }
    }

    Rectangle {
        visible: isCritical
        x: 0; y: 4
        width: 3; height: parent.height - 8
        radius: 1.5
        color: urgencyColor
    }

    // ── App icon ──────────────────────────────────────────────────────────
    Item {
        id: iconArea
        x: isCritical ? 10 : 12; y: 12
        width: 36; height: 36

        Image {
            id: appIcon
            anchors.fill: parent
            source: {
                if (!notif) return ""
                if (notif.image !== "")
                    return notif.image.indexOf("://") >= 0 ? notif.image : ("file://" + notif.image)
                return notif.appIcon !== "" ? ("image://icon/" + notif.appIcon) : ""
            }
            fillMode: Image.PreserveAspectFit
            smooth:   true
            visible:  status === Image.Ready
        }

        Rectangle {
            anchors.fill: parent
            visible:      !appIcon.visible
            radius:       18
            color:        urgencyColor
            opacity:      0.75

            readonly property string glyph:
                toastRoot.appIconGlyph(notif ? notif.appName : "")

            Text {
                anchors.centerIn: parent
                text: {
                    if (parent.glyph !== "") return parent.glyph
                    if (notif && notif.appName.length > 0) return notif.appName[0].toUpperCase()
                    return "●"
                }
                color: "#ffffff"
                font {
                    family:    "JetBrainsMono Nerd Font"
                    pixelSize: parent.glyph !== "" ? 18 : 15
                    bold:      parent.glyph === ""
                }
            }
        }
    }

    // ── Count badge ───────────────────────────────────────────────────────
    Rectangle {
        visible: toastRoot.notifCount > 1
        anchors {
            left:         iconArea.right
            bottom:       iconArea.bottom
            leftMargin:   -8
            bottomMargin: -4
        }
        width:  Math.max(18, countLabel.implicitWidth + 8)
        height: 18
        radius: 9
        color:  toastRoot.urgencyColor

        Text {
            id: countLabel
            anchors.centerIn: parent
            text:  toastRoot.notifCount > 99 ? "99+" : toastRoot.notifCount.toString()
            color: "#ffffff"
            font { pixelSize: 10; bold: true }
        }
    }

    // ── Close button ──────────────────────────────────────────────────────
    Rectangle {
        id: closeBtn
        anchors { right: parent.right; top: parent.top; rightMargin: 10; topMargin: 10 }
        width: 22; height: 22; radius: 11
        color: closeBtnHover.hovered ? Qt.rgba(1, 1, 1, 0.13) : "transparent"
        Behavior on color { ColorAnimation { duration: 100 } }

        Text {
            anchors.centerIn: parent
            text: "✕"; color: "#888a9a"; font.pixelSize: 10
        }
        HoverHandler { id: closeBtnHover }
        TapHandler {
            cursorShape: Qt.PointingHandCursor
            onTapped: NotifServer.dismiss(toastRoot.notif)
        }
    }

    // ── Content column ────────────────────────────────────────────────────
    Column {
        id: contentCol
        anchors {
            left: iconArea.right; right: closeBtn.left; top: parent.top
            leftMargin: 10; rightMargin: 8; topMargin: 10
        }
        spacing: 3

        Text {
            width: parent.width
            text:  notif ? notif.appName : ""
            color: "#72748a"
            font { pixelSize: 10; letterSpacing: 0.5 }
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            text:  notif ? notif.summary : ""
            color: "#e2e4ee"
            font { pixelSize: 13; bold: true }
            elide: Text.ElideRight
        }

        Text {
            id: bodyText
            width:   parent.width
            visible: !!notif && notif.body !== ""

            text:       notif ? notif.body : ""
            color:      "#a8abb8"
            font.pixelSize: 12
            wrapMode:   Text.WordWrap
            textFormat: Text.MarkdownText
            lineHeight: 1.25
            linkColor:  toastRoot.urgencyColor
            onLinkActivated: function(url) { Qt.openUrlExternally(url) }

            height: Math.min(implicitHeight, toastRoot.bodyClipHeight)
            clip:   true

            Behavior on height {
                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
            }
        }

        Rectangle {
            visible: !!notif && notif.body !== "" && (
                toastRoot.bodyFullExpanded ||
                (toastRoot.hovered && toastRoot.bodyWouldTruncate)
            )
            width:  moreLabel.implicitWidth + 16
            height: 20
            radius: 5
            color:  moreBtnHover.hovered ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(1, 1, 1, 0.05)
            Behavior on color { ColorAnimation { duration: 100 } }

            Text {
                id: moreLabel
                anchors.centerIn: parent
                text:  toastRoot.bodyFullExpanded ? "Show less ▴" : "Show more ▾"
                color: "#7a7d8e"
                font.pixelSize: 10
            }

            HoverHandler { id: moreBtnHover }
            TapHandler {
                cursorShape: Qt.PointingHandCursor
                onTapped: {
                    if (toastRoot.bodyFullExpanded) {
                        toastRoot.bodyFullExpanded  = false
                        toastRoot.bodyUserCollapsed = true
                    } else {
                        toastRoot.bodyFullExpanded  = true
                        toastRoot.bodyUserCollapsed = false
                    }
                }
            }
        }

        Row {
            spacing: 6
            visible: !!notif && notif.actions.length > 0
            Repeater {
                model: notif ? notif.actions : []
                Rectangle {
                    required property var modelData
                    width:  actionLabel.implicitWidth + 16; height: 22; radius: 5
                    color:  actionBtnHover.hovered ? Qt.rgba(1,1,1,0.12) : Qt.rgba(1,1,1,0.06)
                    Behavior on color { ColorAnimation { duration: 100 } }
                    Text {
                        id: actionLabel
                        anchors.centerIn: parent
                        text: modelData.text; color: "#c8cad8"; font.pixelSize: 11
                    }
                    HoverHandler { id: actionBtnHover }
                    TapHandler {
                        cursorShape: Qt.PointingHandCursor
                        onTapped: { modelData.invoke(); NotifServer.dismiss(toastRoot.notif) }
                    }
                }
            }
        }
    }

    // ── Timer bar ─────────────────────────────────────────────────────────
    Item {
        visible: toastRoot.timerFraction >= 0.0
        height:  3
        anchors {
            left: parent.left; right: parent.right; bottom: parent.bottom
            leftMargin: 14; rightMargin: 14; bottomMargin: 6
        }
        Rectangle {
            anchors.fill: parent; radius: 1.5
            color: Qt.rgba(1, 1, 1, 0.06)
        }
        Rectangle {
            width:   Math.max(0, toastRoot.timerFraction * parent.width)
            height:  parent.height; radius: 1.5
            color:   toastRoot.urgencyColor; opacity: 0.85
            Behavior on width { NumberAnimation { duration: 60; easing.type: Easing.Linear } }
        }
    }

    // ── Countdown ─────────────────────────────────────────────────────────
    Timer {
        id: countdown
        interval: 50; repeat: true
        running: toastRoot.timeoutMs > 0 && !toastRoot.hovered && toastRoot.timerFraction > 0
        onTriggered: {
            toastRoot.elapsedMs += 50
            if (toastRoot.elapsedMs >= toastRoot.timeoutMs) {
                stop()
                NotifServer.expire(toastRoot.notif)
            }
        }
    }
}
