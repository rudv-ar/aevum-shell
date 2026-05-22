pragma Singleton
import QtQuick
import Quickshell.Io
import Quickshell

Singleton {
    id: root

    // ── Bar ──────────────────────────────────────────────────────────────────
    property bool   barFloating:    false
    property int    barHeight:      32
    readonly property real barMarginTop:   barFloating ? 5 : 0
    readonly property real barMarginLeft:  barFloating ? 5 : 0
    readonly property real barMarginRight: barFloating ? 5 : 0
    property real   barPaddingX:    12

    readonly property real barRadius: barFloating ? 12 : 0

    // ── PillHover ─────────────────────────────────────────────────────────────
    property real pillHoverRadius:       15
    property real pillHoverPaddingX:     10
    property real pillHoverPaddingY:     4
    property real pillHoverSpacing:      6
    property int  pillHoverAnimDuration: 180

    // ── PillStatic ────────────────────────────────────────────────────────────
    property real pillStaticRadius:   15
    property real pillStaticPaddingX: 10
    property real pillStaticPaddingY: 4

    // ── Clock ─────────────────────────────────────────────────────────────────
    property bool   clockUse24h:            true
    property bool   clockShowSeconds:       false
    property bool   clockPillShowTimeFirst: true
    property bool   clockPillIsExpanded:    true
    property int    clockPillTimeFontSize:  13
    property int    clockPillDateFontSize:  12
    property string clockPillFontFamily:    "Sans"

    // ── Workspace ─────────────────────────────────────────────────────────────
    property var    workspaceNames:                   ["1","2","3","4","5","6","7","8"]
    property real   workspaceDotSize:                 14
    property real   workspaceDotFocusedWidth:         28
    property real   workspaceDotRadius:               10
    property real   workspaceDotSpacing:              5
    property int    workspaceDotAnimDuration:         150
    property string workspaceDotLabelMode:            "always"
    property int    workspaceDotLabelFontSize:        8
    property real   workspaceIndicatorPaddingX:       10
    property real   workspaceIndicatorPaddingY:       4
    property real   workspaceIndicatorRadius:         15
    property bool   workspaceIndicatorAlwaysExpanded: true
    property bool   workspaceHasGlyphIndicator:       true
    property int    workspaceIconFontSize:            14
    property real   workspaceIconGap:                 6
    property var    workspaceIconGlyphs: ({
        "1": "\uf303",
        "2": "\uf303",
        "3": "\uf303",
        "4": "\uf303",
        "5": "\uf303",
        "6": "\uf303",
        "7": "\uf303",
        "8": "\uf303"
    })

    // ── BasePill ──────────────────────────────────────────────────────────────
    property real basePillHeight:             24
    property real basePillRadius:             15
    property real basePillPadding:            4
    property real basePillIconBgSize:         18
    property real basePillIconBgRadius:       15
    property real basePillIconSize:           12
    property real basePillSpacing:            6
    property int  basePillFontSize:           12
    property int  basePillExpandDuration:     180
    property int  basePillIconRotateDuration: 400
    property bool basePillHoverEnabled:       true
    property bool basePillIconRotateEnabled:  true

    // ── RightSection ──────────────────────────────────────────────────────────
    property real   rightSectionChipSpacing:       6
    property string rightSectionNetworkGlyph:      "\uf1eb"
    property string rightSectionNotificationGlyph: "\uf0f3"
    property string rightSectionPaneGlyph:         "\uf03b"
    property string rightSectionPowerGlyph:        "\uf011"
    property string rightSectionSettingsGlyph:     "\uf013"

    // ── RightSection aliases (backward compat) ────────────────────────────────
    readonly property real   rightbarChipSpacing:       rightSectionChipSpacing
    readonly property string rightbarNetworkGlyph:      rightSectionNetworkGlyph
    readonly property string rightbarNotificationGlyph: rightSectionNotificationGlyph
    readonly property string rightbarPaneGlyph:         rightSectionPaneGlyph
    readonly property string rightbarPowerGlyph:        rightSectionPowerGlyph
    readonly property string rightbarSettingsGlyph:     rightSectionSettingsGlyph

    // ── Network ───────────────────────────────────────────────────────────────
    property int    networkPollInterval: 10000
    property string networkHoverMode:   "ssid"

    // ── Misc ──────────────────────────────────────────────────────────────────
    property string nerdFontFamily: "JetBrainsMono Nerd Font"

    // ── FileView ──────────────────────────────────────────────────────────────
    FileView {
        id: configFile
        path: Quickshell.env("HOME") + "/.config/aevum/settings/config.json"
        watchChanges: true
        onFileChanged: retryTimer.restart()

        JsonAdapter {
            property var shell: ({})

            onShellChanged: {
                var tb = shell["topbar"] ?? {}

                var bar = tb["bar"] ?? {}
                root.barFloating    = bar["floating"]    ?? false
                root.barHeight      = bar["height"]      ?? 32
                root.barPaddingX    = bar["paddingX"]    ?? 12

                var ph = tb["pillHover"] ?? {}
                root.pillHoverRadius       = ph["radius"]      ?? 15
                root.pillHoverPaddingX     = ph["paddingX"]    ?? 10
                root.pillHoverPaddingY     = ph["paddingY"]    ?? 4
                root.pillHoverSpacing      = ph["spacing"]     ?? 6
                root.pillHoverAnimDuration = ph["animDuration"] ?? 180

                var ps = tb["pillStatic"] ?? {}
                root.pillStaticRadius   = ps["radius"]   ?? 15
                root.pillStaticPaddingX = ps["paddingX"] ?? 10
                root.pillStaticPaddingY = ps["paddingY"] ?? 4

                var cl = tb["clock"] ?? {}
                root.clockUse24h            = cl["use24h"]            ?? true
                root.clockShowSeconds       = cl["showSeconds"]       ?? false
                root.clockPillShowTimeFirst = cl["pillShowTimeFirst"] ?? true
                root.clockPillIsExpanded    = cl["pillIsExpanded"]    ?? true
                root.clockPillTimeFontSize  = cl["pillTimeFontSize"]  ?? 13
                root.clockPillDateFontSize  = cl["pillDateFontSize"]  ?? 12
                root.clockPillFontFamily    = cl["pillFontFamily"]    ?? "Sans"

                var ws = tb["workspace"] ?? {}
                root.workspaceNames                   = ws["names"]                   ?? ["1","2","3","4","5","6","7","8"]
                root.workspaceDotSize                 = ws["dotSize"]                 ?? 14
                root.workspaceDotFocusedWidth         = ws["dotFocusedWidth"]         ?? 28
                root.workspaceDotRadius               = ws["dotRadius"]               ?? 10
                root.workspaceDotSpacing              = ws["dotSpacing"]              ?? 5
                root.workspaceDotAnimDuration         = ws["dotAnimDuration"]         ?? 150
                root.workspaceDotLabelMode            = ws["dotLabelMode"]            ?? "always"
                root.workspaceDotLabelFontSize        = ws["dotLabelFontSize"]        ?? 8
                root.workspaceIndicatorPaddingX       = ws["indicatorPaddingX"]       ?? 10
                root.workspaceIndicatorPaddingY       = ws["indicatorPaddingY"]       ?? 4
                root.workspaceIndicatorRadius         = ws["indicatorRadius"]         ?? 15
                root.workspaceIndicatorAlwaysExpanded = ws["indicatorAlwaysExpanded"] ?? true
                root.workspaceHasGlyphIndicator       = ws["hasGlyphIndicator"]       ?? true
                root.workspaceIconFontSize            = ws["iconFontSize"]            ?? 14
                root.workspaceIconGap                 = ws["iconGap"]                 ?? 6
                root.workspaceIconGlyphs              = ws["iconGlyphs"]              ?? root.workspaceIconGlyphs

                var bp = tb["basePill"] ?? {}
                root.basePillHeight             = bp["height"]             ?? 24
                root.basePillRadius             = bp["radius"]             ?? 15
                root.basePillPadding            = bp["padding"]            ?? 4
                root.basePillIconBgSize         = bp["iconBgSize"]         ?? 18
                root.basePillIconBgRadius       = bp["iconBgRadius"]       ?? 15
                root.basePillIconSize           = bp["iconSize"]           ?? 12
                root.basePillSpacing            = bp["spacing"]            ?? 6
                root.basePillFontSize           = bp["fontSize"]           ?? 12
                root.basePillExpandDuration     = bp["expandDuration"]     ?? 180
                root.basePillIconRotateDuration = bp["iconRotateDuration"] ?? 400
                root.basePillHoverEnabled       = bp["hoverEnabled"]       ?? true
                root.basePillIconRotateEnabled  = bp["iconRotateEnabled"]  ?? true

                var rs = tb["rightSection"] ?? {}
                root.rightSectionChipSpacing       = rs["chipSpacing"]       ?? 6
                root.rightSectionNetworkGlyph      = rs["networkGlyph"]      ?? "\uf1eb"
                root.rightSectionNotificationGlyph = rs["notificationGlyph"] ?? "\uf0f3"
                root.rightSectionPaneGlyph         = rs["paneGlyph"]         ?? "\uf03b"
                root.rightSectionPowerGlyph        = rs["powerGlyph"]        ?? "\uf011"
                root.rightSectionSettingsGlyph     = rs["settingsGlyph"]     ?? "\uf013"

                var nw = tb["network"] ?? {}
                root.networkPollInterval = nw["pollInterval"] ?? 10000
                root.networkHoverMode    = nw["hoverMode"]    ?? "ssid"

                root.nerdFontFamily = tb["nerdFontFamily"] ?? "JetBrainsMono Nerd Font"
            }
        }
    }

    Timer {
        id: retryTimer
        interval: 200
        repeat: false
        onTriggered: configFile.reload()
    }
}
