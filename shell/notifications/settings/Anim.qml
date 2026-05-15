pragma Singleton
import QtQuick

QtObject {
    readonly property bool globalEnabled:               true
    readonly property bool notifBackgroundAnimEnabled:  true
    readonly property bool notifListTransitionsEnabled: true
    readonly property bool notifFirstEntryEnabled:      true
    readonly property int  notifBaseDuration:           320
}
