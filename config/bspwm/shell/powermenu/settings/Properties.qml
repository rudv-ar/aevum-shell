pragma Singleton
import QtQuick

QtObject {
    // powermenu 
    property int powerMenuWidthInitial: 0 
    property int powerMenuWidthExpanded: 75
    property int powerMenuHeight: 280 
    property int powerMenuCornerRadius: 18
    property int powerMenuShoulderRadius: 18
    property int powerMenuBorderWidth: 1.0 
    property int powerMenuImplicitWidth: 80
// ── PowerBoard layout ──────────────────────────────────────────
readonly property real   boardPadding:          10
readonly property real   boardUptimeStripWidth: 38
readonly property real   boardUptimeFontSize:   13
readonly property string iconFont:              "Material Symbols Rounded"
readonly property string uiFont:                "Inter"

// ── PowerMenuPill ──────────────────────────────────────────────
readonly property real pillWidth:    46
readonly property real pillHeight:   46
readonly property real pillRadius:   14
readonly property real pillIconSize: 20
readonly property real pillSpacing:  8    
}

