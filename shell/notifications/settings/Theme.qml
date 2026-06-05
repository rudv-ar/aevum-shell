// Usage from other QML files:
//   Colors.primary                  → active mode Material color string
//   Colors.palette.primary[30]      → tone 30 of primary, always
//   Colors.pc("primary", 10, 90)    → isDark ? palette.primary[10] : palette.primary[90]

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ════════════════════════════════════════════════════════════════
    // FLAGS
    // ════════════════════════════════════════════════════════════════
    property bool isDark:       true
    property bool printEnabled: false

    // ════════════════════════════════════════════════════════════════
    // INTERNAL STATE — only updated on a valid parse
    // ════════════════════════════════════════════════════════════════
    property var  _raw:     null
    property var  _palette: ({})
    readonly property string mode: isDark ? "dark" : "light"

    // Public palette — always the last good build, never null
    readonly property var palette: _palette

    // ════════════════════════════════════════════════════════════════
    // FILE WATCHER
    // ════════════════════════════════════════════════════════════════
    FileView {
        id: jsonFile
        path:         Quickshell.env("HOME") + "/.config/aevum/shared/colors.json"
        blockLoading: true
        watchChanges: true
        onFileChanged: {
            jsonFile.path = jsonFile.path
            jsonFile.reload()
            const t = jsonFile.text()
            if (t && t.trim().length > 0)
                root._parse()
            else
                console.warn("[Colors] file empty on change, waiting for debounce...")
            debounce.restart()
        }
    }

    // Debounce — second attempt after matugen finishes writing
    Timer {
        id: debounce
        interval: 150
        repeat:   false
        onTriggered: {
            jsonFile.path = jsonFile.path
            jsonFile.reload()
            const t = jsonFile.text()
            if (t && t.trim().length > 0)
                root._parse()
            else
                console.warn("[Colors] file still empty after debounce, keeping last good state")
        }
    }

    // Initial load — slight delay so FileView is ready
    Timer {
        id: initialLoad
        interval: 100
        repeat:   false
        running:  true
        onTriggered: root._parse()
    }

    // ════════════════════════════════════════════════════════════════
    // PARSE — only commits state if JSON is valid and palettes exist
    // ════════════════════════════════════════════════════════════════
    function _parse() {
        try {
            const text = jsonFile.text()
            if (!text || text.trim().length === 0) return
            const parsed = JSON.parse(text)
            if (!parsed?.palettes) return
            _raw     = parsed
            _palette = _buildPalette()

            // ── Sync dark mode from JSON ──────────────────────────
            if (parsed.is_dark_mode !== undefined)
                isDark = parsed.is_dark_mode   // true/false boolean from matugen            
                
            refresh()
        } catch (e) {
            console.warn("[Colors] parse failed, keeping last good state:", e)
        }
    }

    // ════════════════════════════════════════════════════════════════
    // MATERIAL COLORS — active mode
    // ════════════════════════════════════════════════════════════════

    // ── Background & Surface ─────────────────────────────────────────
    readonly property string background:              _c("background")
    readonly property string onBackground:            _c("on_background")

    readonly property string surface:                 _c("surface")
    readonly property string surfaceVariant:          _c("surface_variant")
    readonly property string surfaceContainer:        _c("surface_container")
    readonly property string surfaceContainerHigh:    _c("surface_container_high")
    readonly property string surfaceContainerHighest: _c("surface_container_highest")
    readonly property string surfaceContainerLow:     _c("surface_container_low")
    readonly property string surfaceContainerLowest:  _c("surface_container_lowest")
    readonly property string surfaceBright:           _c("surface_bright")
    readonly property string surfaceDim:              _c("surface_dim")
    readonly property string surfaceTint:             _c("surface_tint")
    readonly property string onSurface:               _c("on_surface")
    readonly property string onSurfaceVariant:        _c("on_surface_variant")
    readonly property string inverseSurface:          _c("inverse_surface")
    readonly property string inverseOnSurface:        _c("inverse_on_surface")

    // ── Primary ──────────────────────────────────────────────────────
    readonly property string primary:                 _c("primary")
    readonly property string onPrimary:               _c("on_primary")
    readonly property string primaryContainer:        _c("primary_container")
    readonly property string onPrimaryContainer:      _c("on_primary_container")
    readonly property string primaryFixed:            _c("primary_fixed")
    readonly property string primaryFixedDim:         _c("primary_fixed_dim")
    readonly property string inversePrimary:          _c("inverse_primary")

    // ── Secondary ────────────────────────────────────────────────────
    readonly property string secondary:               _c("secondary")
    readonly property string onSecondary:             _c("on_secondary")
    readonly property string secondaryContainer:      _c("secondary_container")
    readonly property string onSecondaryContainer:    _c("on_secondary_container")
    readonly property string secondaryFixed:          _c("secondary_fixed")
    readonly property string secondaryFixedDim:       _c("secondary_fixed_dim")

    // ── Tertiary ─────────────────────────────────────────────────────
    readonly property string tertiary:                _c("tertiary")
    readonly property string onTertiary:              _c("on_tertiary")
    readonly property string tertiaryContainer:       _c("tertiary_container")
    readonly property string onTertiaryContainer:     _c("on_tertiary_container")
    readonly property string tertiaryFixed:           _c("tertiary_fixed")
    readonly property string tertiaryFixedDim:        _c("tertiary_fixed_dim")

    // ── Error ────────────────────────────────────────────────────────
    readonly property string error:                   _c("error")
    readonly property string onError:                 _c("on_error")
    readonly property string errorContainer:          _c("error_container")
    readonly property string onErrorContainer:        _c("on_error_container")

    // ── Outline / Scrim / Shadow ──────────────────────────────────────
    readonly property string outline:                 _c("outline")
    readonly property string outlineVariant:          _c("outline_variant")
    readonly property string scrim:                   _c("scrim")
    readonly property string shadow:                  _c("shadow")
    readonly property string sourceColor:             _c("source_color")

    // ════════════════════════════════════════════════════════════════
    // PALETTE SHORTCUTS — bound to palette, safe because palette
    // is only ever updated with a fully valid build
    // ════════════════════════════════════════════════════════════════

    // ── Primary ──────────────────────────────────────────────────────
    readonly property color p0:   palette.primary?.[0]   ?? "transparent"
    readonly property color p5:   palette.primary?.[5]   ?? "transparent"
    readonly property color p10:  palette.primary?.[10]  ?? "transparent"
    readonly property color p15:  palette.primary?.[15]  ?? "transparent"
    readonly property color p20:  palette.primary?.[20]  ?? "transparent"
    readonly property color p25:  palette.primary?.[25]  ?? "transparent"
    readonly property color p30:  palette.primary?.[30]  ?? "transparent"
    readonly property color p35:  palette.primary?.[35]  ?? "transparent"
    readonly property color p40:  palette.primary?.[40]  ?? "transparent"
    readonly property color p50:  palette.primary?.[50]  ?? "transparent"
    readonly property color p60:  palette.primary?.[60]  ?? "transparent"
    readonly property color p70:  palette.primary?.[70]  ?? "transparent"
    readonly property color p80:  palette.primary?.[80]  ?? "transparent"
    readonly property color p90:  palette.primary?.[90]  ?? "transparent"
    readonly property color p95:  palette.primary?.[95]  ?? "transparent"
    readonly property color p98:  palette.primary?.[98]  ?? "transparent"
    readonly property color p99:  palette.primary?.[99]  ?? "transparent"
    readonly property color p100: palette.primary?.[100] ?? "transparent"

    // ── Secondary ────────────────────────────────────────────────────
    readonly property color s0:   palette.secondary?.[0]   ?? "transparent"
    readonly property color s5:   palette.secondary?.[5]   ?? "transparent"
    readonly property color s10:  palette.secondary?.[10]  ?? "transparent"
    readonly property color s15:  palette.secondary?.[15]  ?? "transparent"
    readonly property color s20:  palette.secondary?.[20]  ?? "transparent"
    readonly property color s25:  palette.secondary?.[25]  ?? "transparent"
    readonly property color s30:  palette.secondary?.[30]  ?? "transparent"
    readonly property color s35:  palette.secondary?.[35]  ?? "transparent"
    readonly property color s40:  palette.secondary?.[40]  ?? "transparent"
    readonly property color s50:  palette.secondary?.[50]  ?? "transparent"
    readonly property color s60:  palette.secondary?.[60]  ?? "transparent"
    readonly property color s70:  palette.secondary?.[70]  ?? "transparent"
    readonly property color s80:  palette.secondary?.[80]  ?? "transparent"
    readonly property color s90:  palette.secondary?.[90]  ?? "transparent"
    readonly property color s95:  palette.secondary?.[95]  ?? "transparent"
    readonly property color s98:  palette.secondary?.[98]  ?? "transparent"
    readonly property color s99:  palette.secondary?.[99]  ?? "transparent"
    readonly property color s100: palette.secondary?.[100] ?? "transparent"

    // ── Tertiary ─────────────────────────────────────────────────────
    readonly property color t0:   palette.tertiary?.[0]   ?? "transparent"
    readonly property color t5:   palette.tertiary?.[5]   ?? "transparent"
    readonly property color t10:  palette.tertiary?.[10]  ?? "transparent"
    readonly property color t15:  palette.tertiary?.[15]  ?? "transparent"
    readonly property color t20:  palette.tertiary?.[20]  ?? "transparent"
    readonly property color t25:  palette.tertiary?.[25]  ?? "transparent"
    readonly property color t30:  palette.tertiary?.[30]  ?? "transparent"
    readonly property color t35:  palette.tertiary?.[35]  ?? "transparent"
    readonly property color t40:  palette.tertiary?.[40]  ?? "transparent"
    readonly property color t50:  palette.tertiary?.[50]  ?? "transparent"
    readonly property color t60:  palette.tertiary?.[60]  ?? "transparent"
    readonly property color t70:  palette.tertiary?.[70]  ?? "transparent"
    readonly property color t80:  palette.tertiary?.[80]  ?? "transparent"
    readonly property color t90:  palette.tertiary?.[90]  ?? "transparent"
    readonly property color t95:  palette.tertiary?.[95]  ?? "transparent"
    readonly property color t98:  palette.tertiary?.[98]  ?? "transparent"
    readonly property color t99:  palette.tertiary?.[99]  ?? "transparent"
    readonly property color t100: palette.tertiary?.[100] ?? "transparent"

    // ── Neutral ──────────────────────────────────────────────────────
    readonly property color n0:   palette.neutral?.[0]   ?? "transparent"
    readonly property color n5:   palette.neutral?.[5]   ?? "transparent"
    readonly property color n10:  palette.neutral?.[10]  ?? "transparent"
    readonly property color n15:  palette.neutral?.[15]  ?? "transparent"
    readonly property color n20:  palette.neutral?.[20]  ?? "transparent"
    readonly property color n25:  palette.neutral?.[25]  ?? "transparent"
    readonly property color n30:  palette.neutral?.[30]  ?? "transparent"
    readonly property color n35:  palette.neutral?.[35]  ?? "transparent"
    readonly property color n40:  palette.neutral?.[40]  ?? "transparent"
    readonly property color n50:  palette.neutral?.[50]  ?? "transparent"
    readonly property color n60:  palette.neutral?.[60]  ?? "transparent"
    readonly property color n70:  palette.neutral?.[70]  ?? "transparent"
    readonly property color n80:  palette.neutral?.[80]  ?? "transparent"
    readonly property color n90:  palette.neutral?.[90]  ?? "transparent"
    readonly property color n95:  palette.neutral?.[95]  ?? "transparent"
    readonly property color n98:  palette.neutral?.[98]  ?? "transparent"
    readonly property color n99:  palette.neutral?.[99]  ?? "transparent"
    readonly property color n100: palette.neutral?.[100] ?? "transparent"

    // ── Neutral Variant ───────────────────────────────────────────────
    readonly property color nv0:   palette.neutral_variant?.[0]   ?? "transparent"
    readonly property color nv5:   palette.neutral_variant?.[5]   ?? "transparent"
    readonly property color nv10:  palette.neutral_variant?.[10]  ?? "transparent"
    readonly property color nv15:  palette.neutral_variant?.[15]  ?? "transparent"
    readonly property color nv20:  palette.neutral_variant?.[20]  ?? "transparent"
    readonly property color nv25:  palette.neutral_variant?.[25]  ?? "transparent"
    readonly property color nv30:  palette.neutral_variant?.[30]  ?? "transparent"
    readonly property color nv35:  palette.neutral_variant?.[35]  ?? "transparent"
    readonly property color nv40:  palette.neutral_variant?.[40]  ?? "transparent"
    readonly property color nv50:  palette.neutral_variant?.[50]  ?? "transparent"
    readonly property color nv60:  palette.neutral_variant?.[60]  ?? "transparent"
    readonly property color nv70:  palette.neutral_variant?.[70]  ?? "transparent"
    readonly property color nv80:  palette.neutral_variant?.[80]  ?? "transparent"
    readonly property color nv90:  palette.neutral_variant?.[90]  ?? "transparent"
    readonly property color nv95:  palette.neutral_variant?.[95]  ?? "transparent"
    readonly property color nv98:  palette.neutral_variant?.[98]  ?? "transparent"
    readonly property color nv99:  palette.neutral_variant?.[99]  ?? "transparent"
    readonly property color nv100: palette.neutral_variant?.[100] ?? "transparent"

    // ── Error ────────────────────────────────────────────────────────
    readonly property color e0:   palette.error?.[0]   ?? "transparent"
    readonly property color e5:   palette.error?.[5]   ?? "transparent"
    readonly property color e10:  palette.error?.[10]  ?? "transparent"
    readonly property color e15:  palette.error?.[15]  ?? "transparent"
    readonly property color e20:  palette.error?.[20]  ?? "transparent"
    readonly property color e25:  palette.error?.[25]  ?? "transparent"
    readonly property color e30:  palette.error?.[30]  ?? "transparent"
    readonly property color e35:  palette.error?.[35]  ?? "transparent"
    readonly property color e40:  palette.error?.[40]  ?? "transparent"
    readonly property color e50:  palette.error?.[50]  ?? "transparent"
    readonly property color e60:  palette.error?.[60]  ?? "transparent"
    readonly property color e70:  palette.error?.[70]  ?? "transparent"
    readonly property color e80:  palette.error?.[80]  ?? "transparent"
    readonly property color e90:  palette.error?.[90]  ?? "transparent"
    readonly property color e95:  palette.error?.[95]  ?? "transparent"
    readonly property color e98:  palette.error?.[98]  ?? "transparent"
    readonly property color e99:  palette.error?.[99]  ?? "transparent"
    readonly property color e100: palette.error?.[100] ?? "transparent"

    // ════════════════════════════════════════════════════════════════
    // SEMANTIC / COMPONENT COLORS
    // ════════════════════════════════════════════════════════════════
    readonly property color base:            background
    readonly property color surface0:        "#181b1f"
    readonly property color surface1:        "#45475a"
    readonly property color accent:          pc("primary",    70, 30)
    readonly property color wsActiveBg:      pc("primary",    60, 40)
    readonly property color xtitleColor:     pc("primary",   100,  0)
    readonly property color wsOccupiedBg:    pc("secondary",  25, 70)
    readonly property color text:            pc("primary",    90, 10)
    readonly property color textColor:       pc("primary",    90, 10)
    readonly property color launcherBg:      pc("neutral",    10, 95)
    readonly property color statusIconColor: pc("primary",    90, 10)
    readonly property color workspaceBg:     isDark
                                                 ? Qt.lighter(pc("primary", 80, 90), 0.20)
                                                 : Qt.lighter(pc("primary", 80, 90), 0.80)


// ── Audio / BasePill ──────────────────────────────────────────────────────
    readonly property color audioError: error   // #ffb4ab — tracks theme now   


    readonly property color notifBackgroundBg: background
    readonly property color notifNormalBg:     workspaceBg
    readonly property color notifCriticalBg:   wsOccupiedBg
    readonly property color notifLowBg:        workspaceBg
    readonly property color notifToastBg:      background
                                                 
    // ── Semantic aliases ──────────────────────────────────────────────
    readonly property color frameColor: background

    // ════════════════════════════════════════════════════════════════
    // COMPONENT THEME — Power pill
    // ════════════════════════════════════════════════════════════════
    readonly property color  powerBg:       pc("tertiary", 30, 70)
    readonly property color  powerIcon:     pc("tertiary", 70, 30)
    readonly property color  powerRipple:   Qt.lighter(pc("tertiary", 30, 70), 2.0)
    readonly property string powerLeftCmd:  "systemctl poweroff"
    readonly property string powerRightCmd: "systemctl reboot"

    // ════════════════════════════════════════════════════════════════
    // COMPONENT THEME — Workspace indicator
    // ════════════════════════════════════════════════════════════════
    readonly property bool showDesktopNumbers:      false // deprecated — keep false
    readonly property bool colorWorkspaceIndicator: true

    // Time Pill - for the clock : 
    // ── Clock ─────────────────────────────────────────
    readonly property bool   clockTwelveHour: false
    readonly property bool   clockShowIcon:   true
    readonly property bool   clockShowDate:   false
    readonly property int    clockTimeSize:   13
    readonly property int    clockDateSize:   12
    readonly property int    clockPadV:       5
    readonly property int    clockSpacing:    1
    readonly property bool colorClockPill: false
    readonly property string fontMono:        "JetBrainsMono Nerd Font"

    // ════════════════════════════════════════════════════════════════
    // FONTS
    // ════════════════════════════════════════════════════════════════
    FontLoader { id: fontLoaderFA6;               source: "file://" + Quickshell.shellDir + "/../../shared/fonts/Font Awesome 6 Free-Solid-900.otf" }
    FontLoader { id: fontLoaderAnurati;           source: "file://" + Quickshell.shellDir + "/../../shared/fonts/Anurati.otf" }
    FontLoader { id: fontLoaderPoppins;           source: "file://" + Quickshell.shellDir + "/../../shared/fonts/Poppins.ttf" }
    FontLoader { id: fontLoaderGolgix;            source: "file://" + Quickshell.shellDir + "/../../shared/fonts/Golgix-Regular.ttf" }
    FontLoader { id: fontLoaderAvaporeRound;      source: "file://" + Quickshell.shellDir + "/../../shared/fonts/Avapore-Round.otf" }
    FontLoader { id: fontLoaderBiologicalSystems; source: "file://" + Quickshell.shellDir + "/../../shared/fonts/Biological-Systems-Demo.otf" }
    FontLoader { id: fontLoaderHardcoreImperial;  source: "file://" + Quickshell.shellDir + "/../../shared/fonts/Hardcore Imperial.ttf" }
    FontLoader { id: fontLoaderAssistedSensors;   source: "file://" + Quickshell.shellDir + "/../../shared/fonts/Assisted-Sensors-Demo.otf" }

    readonly property string fontAwesome6:          fontLoaderFA6.name
    readonly property string fontAnurati:           fontLoaderAnurati.name
    readonly property string fontPoppins:           fontLoaderPoppins.name
    readonly property string fontGolgixRegular:     fontLoaderGolgix.name
    readonly property string fontAvaporeRound:      fontLoaderAvaporeRound.name
    readonly property string fontBiologicalSystems: fontLoaderBiologicalSystems.name
    readonly property string fontHardcoreImperial:  fontLoaderHardcoreImperial.name
    readonly property string fontAssistedSensors:   fontLoaderAssistedSensors.name
    readonly property string fontMaterial:          "Material Symbols Rounded"
    readonly property string nerdFontFamily:        "Material Design Icons"

    // ════════════════════════════════════════════════════════════════
    // SIZES & LAYOUT
    // ════════════════════════════════════════════════════════════════

    // ── Notch / hole margins ──────────────────────────────────────────
    readonly property int holeLeft:   35
    readonly property int holeTop:    10
    readonly property int holeRight:  10
    readonly property int holeBottom: 10
    readonly property int holeRadius: 12

    // ── Bar ───────────────────────────────────────────────────────────
    readonly property int barBottomPad: 16

    // ── Launcher pill ─────────────────────────────────────────────────
    readonly property int pillWidth:    28
    readonly property int pillHeight:   28
    readonly property int pillRadius:   16
    readonly property int pillIconSize: 16
    readonly property int pillTopPad:   0

    // ── Power pill ────────────────────────────────────────────────────
    readonly property int powerPillW:    28
    readonly property int powerPillH:    28
    readonly property int powerPillR:    16
    readonly property int powerIconSize: 16

    // ── Animation durations (ms) ──────────────────────────────────────
    readonly property int animFast:   120
    readonly property int animNormal: 220
    readonly property int animSlow:   400


    
    // ════════════════════════════════════════════════════════════════
    // HELPERS
    // ════════════════════════════════════════════════════════════════

    // Returns the active-mode color for a named Material color token
    function _c(name) {
        return _raw?.colors?.[name]?.[mode]?.color ?? "transparent"
    }

    readonly property var _palNames: [
        "primary", "secondary", "tertiary",
        "neutral", "neutral_variant", "error"
    ]

    // Builds the full tone map — every tone, no mode filtering, from last good _raw
    function _buildPalette() {
        if (!_raw?.palettes) return {}
        const allTones = [0, 5, 10, 15, 20, 25, 30, 35, 40, 50, 60, 70, 80, 90, 95, 98, 99, 100]
        const out = {}
        for (const pal of _palNames) {
            out[pal] = {}
            for (const t of allTones)
                out[pal][t] = _raw.palettes[pal]?.[String(t)]?.color ?? "transparent"
        }
        return out
    }

    // pc("primary", 10, 90) → isDark ? palette.primary[10] : palette.primary[90]
    function pc(palName, darkTone, lightTone) {
        return isDark
            ? (_palette[palName]?.[darkTone]  ?? "transparent")
            : (_palette[palName]?.[lightTone] ?? "transparent")
    }

    // ════════════════════════════════════════════════════════════════
    // DEBUG PRINT
    // ════════════════════════════════════════════════════════════════
    function _printColorGroup(label, m) {
        console.log("\n── MATERIAL " + label + " ───────────────────────────────")
        const c = _raw.colors
        for (const k in c)
            console.log("  " + k.padEnd(32) + (c[k]?.[m]?.color ?? "n/a"))
    }

    function _printPaletteGroup() {
        const allTones = [0, 5, 10, 15, 20, 25, 30, 35, 40, 50, 60, 70, 80, 90, 95, 98, 99, 100]
        console.log("\n── PALETTE (all tones) ──")
        for (const pal of _palNames) {
            const row = allTones
                .map(t => t + ":" + (_raw.palettes[pal]?.[String(t)]?.color ?? "n/a"))
                .join("  ")
            console.log("  " + pal.padEnd(16) + row)
        }
    }

    function refresh() {
        if (!printEnabled || !_raw) return
        console.log("\n[Colors] reloaded  active=" + mode)
        _printColorGroup("DARK",  "dark")
        _printColorGroup("LIGHT", "light")
        _printPaletteGroup()
    }

    onIsDarkChanged: refresh()
}
