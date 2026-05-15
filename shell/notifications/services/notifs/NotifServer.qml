pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    property var groupMap: ({})

    readonly property var notifModel: ScriptModel {
        objectProp: "key"
        values: Object.values(root.groupMap)
    }

    // ALL THREE must match — AND, not OR.
    // Null-byte separator prevents cross-field collisions.
    function groupKey(notif) {
        return (notif.appName || "") + "\x00"
             + (notif.summary || "") + "\x00"
             + (notif.body    || "")
    }

    function resolveTimeout(notif) {
        if (notif.expireTimeout > 0) return notif.expireTimeout
        if (notif.urgency === NotificationUrgency.Critical) return 0
        if (notif.urgency === NotificationUrgency.Low)      return 4000
        return 6000
    }

    function dismiss(notif) {
        if (notif && notif.tracked) notif.dismiss()
    }

    function expire(notif) {
        if (notif && notif.tracked) notif.expire()
    }

    // Only removes the entry if THIS notif is still the active one.
    // If it was already replaced, the close of the old notif is ignored.
    function _onNotifClosed(key, closedNotif) {
        const entry = root.groupMap[key]
        if (!entry || entry.notif !== closedNotif) return
        const updated = Object.assign({}, root.groupMap)
        delete updated[key]
        root.groupMap = updated
    }

    NotificationServer {
        id: server
        actionsSupported: true
        imageSupported:   true
        keepOnReload:     false

        onNotification: function(notif) {
            const key      = root.groupKey(notif)
            const existing = root.groupMap[key]

            notif.tracked = true
            notif.onClosed.connect(function() { root._onNotifClosed(key, notif) })

            if (existing) {
                // Mutate wrapper in-place → ScriptModel sees same reference,
                // keeps the delegate alive, only count badge updates.
                const oldNotif  = existing.notif
                existing.notif  = notif
                existing.count  = existing.count + 1
                // Reassign map to poke the ScriptModel values binding.
                root.groupMap   = Object.assign({}, root.groupMap)
                // Expire old AFTER wiring new close handler — safe ordering.
                // _onNotifClosed will no-op for oldNotif since entry.notif
                // is already the new one.
                if (oldNotif && oldNotif.tracked) oldNotif.expire()
            } else {
                const updated  = Object.assign({}, root.groupMap)
                updated[key]   = { key: key, notif: notif, count: 1 }
                root.groupMap  = updated
            }
        }
    }
}

