pragma Singleton
import QtQuick

QtObject {
    readonly property int  borderThickness: 10
    readonly property int  topOffset:       4    // offset
    readonly property real cornerRadius:    18.0
    readonly property int marginCover: 32 // the thing behind the topbar
        readonly property int   panelWidth:        380
        readonly property int   panelRadius:       20
        readonly property int   panelTopMargin:    10
        readonly property int   panelBottomMargin: 10
        readonly property int   panelRightMargin:  10
        readonly property int   animDuration:      340
        property bool isOpen: false
    
}

