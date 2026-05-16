pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

// ── Fonts ─────────────────────────────────────────────────────────────────
    FontLoader { id: fontLoaderFA6; source: "file://" + Quickshell.shellDir + "/../assets/fonts/Font Awesome 6 Free-Solid-900.otf" }
    FontLoader { id: fontLoaderAnurati;           source: "file://" + Quickshell.shellDir + "/../assets/fonts/Anurati.otf" }
    FontLoader { id: fontLoaderPoppins;           source: "file://" + Quickshell.shellDir + "/../assets/fonts/Poppins.ttf" }
    FontLoader { id: fontLoaderGolgix;            source: "file://" + Quickshell.shellDir + "/../assets/fonts/Golgix-Regular.ttf" }
    FontLoader { id: fontLoaderAvaporeRound;      source: "file://" + Quickshell.shellDir + "/../assets/fonts/Avapore-Round.otf" }
    FontLoader { id: fontLoaderBiologicalSystems; source: "file://" + Quickshell.shellDir + "/../assets/fonts/Biological-Systems-Demo.otf" }
    FontLoader { id: fontLoaderHardcoreImperial;  source: "file://" + Quickshell.shellDir + "/../assets/fonts/Hardcore Imperial.ttf" }
    FontLoader { id: fontLoaderAssistedSensors;   source: "file://" + Quickshell.shellDir + "/../assets/fonts/Assisted-Sensors-Demo.otf" }

    readonly property string fontAnurati:           fontLoaderAnurati.name
    readonly property string fontPoppins:           fontLoaderPoppins.name
    readonly property string fontGolgixRegular:     fontLoaderGolgix.name
    readonly property string fontAvaporeRound:      fontLoaderAvaporeRound.name
    readonly property string fontBiologicalSystems: fontLoaderBiologicalSystems.name
    readonly property string fontHardcoreImperial:  fontLoaderHardcoreImperial.name
    readonly property string fontAssistedSensors:   fontLoaderAssistedSensors.name
    readonly property string fontAwesome6: fontLoaderFA6.name

    // ── Layer A: File watcher ─────────────────────────────────────────────────
    FileView {
        id: colorFile
        path: Quickshell.env("HOME") + "/.config/bspwm/shell/shared/colors.json"
        blockLoading: true
        watchChanges: true
        onFileChanged: {
            colorFile.path = colorFile.path
            colorFile.reload()
            const t = colorFile.text()
            if (t && t.trim().length > 0)
                root._parse()
            else
                console.warn("Theme: file empty on first attempt, waiting for debounce...")
            debounce.restart()
        }
    }

    Timer {
        id: debounce
        interval: 150
        repeat: false
        onTriggered: {
            colorFile.path = colorFile.path
            colorFile.reload()
            const t = colorFile.text()
            if (t && t.trim().length > 0)
                root._parse()
            else
                console.warn("Theme: file still empty after debounce, keeping last good state")
        }
    }

    Timer {
        id: initialLoad
        interval: 100
        repeat: false
        running: true
        onTriggered: root._parse()
    }

    // ── Layer B: Parser ───────────────────────────────────────────────────────
    property var _data: ({})

    function _parse() {
        const raw = colorFile.text()
        if (!raw || raw.trim().length === 0) {
            console.warn("Theme: _parse called but file is empty, skipping")
            return
        }
        try {
            root._data = JSON.parse(raw)
            console.log("Theme: parsed OK — mode:", root._data?.mode, "| wallpaper:", root._data?.image)
        } catch (e) {
            console.warn("Theme: parse FAILED —", e)
            console.warn("Theme: raw text (first 80):", raw.substring(0, 80))
        }
    }

    // ── Layer C: Accessors ────────────────────────────────────────────────────
    readonly property bool   isDarkMode: root._data?.is_dark_mode ?? true
    readonly property string mode:       root._data?.mode         ?? "dark"
    readonly property string wallpaper:  root._data?.image        ?? ""

    property bool darkMode: true

    function _c(key) {
        const m = root.darkMode ? "dark" : "light"
        return root._data?.colors?.[key]?.[m]?.color ?? "transparent"
    }

    function _b(key) {
        const m = root.darkMode ? "dark" : "light"
        return root._data?.base16?.[key]?.[m]?.color ?? "transparent"
    }

    function _p(palette, tone) {
        return root._data?.palettes?.[palette]?.[String(tone)]?.color ?? "transparent"
    }

    // ── Material Colors ───────────────────────────────────────────────────────
    readonly property color primary:                 (root._data, root.darkMode, root._c("primary"))
    readonly property color onPrimary:               (root._data, root.darkMode, root._c("on_primary"))
    readonly property color primaryContainer:        (root._data, root.darkMode, root._c("primary_container"))
    readonly property color onPrimaryContainer:      (root._data, root.darkMode, root._c("on_primary_container"))
    readonly property color primaryFixed:            (root._data, root.darkMode, root._c("primary_fixed"))
    readonly property color primaryFixedDim:         (root._data, root.darkMode, root._c("primary_fixed_dim"))
    readonly property color onPrimaryFixed:          (root._data, root.darkMode, root._c("on_primary_fixed"))
    readonly property color onPrimaryFixedVariant:   (root._data, root.darkMode, root._c("on_primary_fixed_variant"))

    readonly property color secondary:               (root._data, root.darkMode, root._c("secondary"))
    readonly property color onSecondary:             (root._data, root.darkMode, root._c("on_secondary"))
    readonly property color secondaryContainer:      (root._data, root.darkMode, root._c("secondary_container"))
    readonly property color onSecondaryContainer:    (root._data, root.darkMode, root._c("on_secondary_container"))
    readonly property color secondaryFixed:          (root._data, root.darkMode, root._c("secondary_fixed"))
    readonly property color secondaryFixedDim:       (root._data, root.darkMode, root._c("secondary_fixed_dim"))
    readonly property color onSecondaryFixed:        (root._data, root.darkMode, root._c("on_secondary_fixed"))
    readonly property color onSecondaryFixedVariant: (root._data, root.darkMode, root._c("on_secondary_fixed_variant"))

    readonly property color tertiary:                (root._data, root.darkMode, root._c("tertiary"))
    readonly property color onTertiary:              (root._data, root.darkMode, root._c("on_tertiary"))
    readonly property color tertiaryContainer:       (root._data, root.darkMode, root._c("tertiary_container"))
    readonly property color onTertiaryContainer:     (root._data, root.darkMode, root._c("on_tertiary_container"))
    readonly property color tertiaryFixed:           (root._data, root.darkMode, root._c("tertiary_fixed"))
    readonly property color tertiaryFixedDim:        (root._data, root.darkMode, root._c("tertiary_fixed_dim"))
    readonly property color onTertiaryFixed:         (root._data, root.darkMode, root._c("on_tertiary_fixed"))
    readonly property color onTertiaryFixedVariant:  (root._data, root.darkMode, root._c("on_tertiary_fixed_variant"))

    readonly property color error:                   (root._data, root.darkMode, root._c("error"))
    readonly property color onError:                 (root._data, root.darkMode, root._c("on_error"))
    readonly property color errorContainer:          (root._data, root.darkMode, root._c("error_container"))
    readonly property color onErrorContainer:        (root._data, root.darkMode, root._c("on_error_container"))

    readonly property color surface:                 (root._data, root.darkMode, root._c("surface"))
    readonly property color onSurface:               (root._data, root.darkMode, root._c("on_surface"))
    readonly property color surfaceVariant:          (root._data, root.darkMode, root._c("surface_variant"))
    readonly property color onSurfaceVariant:        (root._data, root.darkMode, root._c("on_surface_variant"))
    readonly property color surfaceBright:           (root._data, root.darkMode, root._c("surface_bright"))
    readonly property color surfaceDim:              (root._data, root.darkMode, root._c("surface_dim"))
    readonly property color surfaceTint:             (root._data, root.darkMode, root._c("surface_tint"))
    readonly property color surfaceContainerLowest:  (root._data, root.darkMode, root._c("surface_container_lowest"))
    readonly property color surfaceContainerLow:     (root._data, root.darkMode, root._c("surface_container_low"))
    readonly property color surfaceContainer:        (root._data, root.darkMode, root._c("surface_container"))
    readonly property color surfaceContainerHigh:    (root._data, root.darkMode, root._c("surface_container_high"))
    readonly property color surfaceContainerHighest: (root._data, root.darkMode, root._c("surface_container_highest"))

    readonly property color background:              (root._data, root.darkMode, root._c("background"))
    readonly property color onBackground:            (root._data, root.darkMode, root._c("on_background"))

    readonly property color outline:                 (root._data, root.darkMode, root._c("outline"))
    readonly property color outlineVariant:          (root._data, root.darkMode, root._c("outline_variant"))

    readonly property color shadow:                  (root._data, root.darkMode, root._c("shadow"))
    readonly property color scrim:                   (root._data, root.darkMode, root._c("scrim"))
    readonly property color sourceColor:             (root._data, root.darkMode, root._c("source_color"))
    readonly property color inverseSurface:          (root._data, root.darkMode, root._c("inverse_surface"))
    readonly property color inverseOnSurface:        (root._data, root.darkMode, root._c("inverse_on_surface"))
    readonly property color inversePrimary:          (root._data, root.darkMode, root._c("inverse_primary"))

    // ── Base16 ────────────────────────────────────────────────────────────────
    readonly property color base00: (root._data, root.darkMode, root._b("base00"))
    readonly property color base01: (root._data, root.darkMode, root._b("base01"))
    readonly property color base02: (root._data, root.darkMode, root._b("base02"))
    readonly property color base03: (root._data, root.darkMode, root._b("base03"))
    readonly property color base04: (root._data, root.darkMode, root._b("base04"))
    readonly property color base05: (root._data, root.darkMode, root._b("base05"))
    readonly property color base06: (root._data, root.darkMode, root._b("base06"))
    readonly property color base07: (root._data, root.darkMode, root._b("base07"))
    readonly property color base08: (root._data, root.darkMode, root._b("base08"))
    readonly property color base09: (root._data, root.darkMode, root._b("base09"))
    readonly property color base0A: (root._data, root.darkMode, root._b("base0a"))
    readonly property color base0B: (root._data, root.darkMode, root._b("base0b"))
    readonly property color base0C: (root._data, root.darkMode, root._b("base0c"))
    readonly property color base0D: (root._data, root.darkMode, root._b("base0d"))
    readonly property color base0E: (root._data, root.darkMode, root._b("base0e"))
    readonly property color base0F: (root._data, root.darkMode, root._b("base0f"))

    // ── Palettes ──────────────────────────────────────────────────────────────
    readonly property color primaryP0:   (root._data, root._p("primary",  0))
    readonly property color primaryP5:   (root._data, root._p("primary",  5))
    readonly property color primaryP10:  (root._data, root._p("primary", 10))
    readonly property color primaryP15:  (root._data, root._p("primary", 15))
    readonly property color primaryP20:  (root._data, root._p("primary", 20))
    readonly property color primaryP25:  (root._data, root._p("primary", 25))
    readonly property color primaryP30:  (root._data, root._p("primary", 30))
    readonly property color primaryP35:  (root._data, root._p("primary", 35))
    readonly property color primaryP40:  (root._data, root._p("primary", 40))
    readonly property color primaryP50:  (root._data, root._p("primary", 50))
    readonly property color primaryP60:  (root._data, root._p("primary", 60))
    readonly property color primaryP70:  (root._data, root._p("primary", 70))
    readonly property color primaryP80:  (root._data, root._p("primary", 80))
    readonly property color primaryP90:  (root._data, root._p("primary", 90))
    readonly property color primaryP95:  (root._data, root._p("primary", 95))
    readonly property color primaryP98:  (root._data, root._p("primary", 98))
    readonly property color primaryP99:  (root._data, root._p("primary", 99))
    readonly property color primaryP100: (root._data, root._p("primary", 100))

    readonly property color secondaryP0:   (root._data, root._p("secondary",  0))
    readonly property color secondaryP5:   (root._data, root._p("secondary",  5))
    readonly property color secondaryP10:  (root._data, root._p("secondary", 10))
    readonly property color secondaryP15:  (root._data, root._p("secondary", 15))
    readonly property color secondaryP20:  (root._data, root._p("secondary", 20))
    readonly property color secondaryP25:  (root._data, root._p("secondary", 25))
    readonly property color secondaryP30:  (root._data, root._p("secondary", 30))
    readonly property color secondaryP35:  (root._data, root._p("secondary", 35))
    readonly property color secondaryP40:  (root._data, root._p("secondary", 40))
    readonly property color secondaryP50:  (root._data, root._p("secondary", 50))
    readonly property color secondaryP60:  (root._data, root._p("secondary", 60))
    readonly property color secondaryP70:  (root._data, root._p("secondary", 70))
    readonly property color secondaryP80:  (root._data, root._p("secondary", 80))
    readonly property color secondaryP90:  (root._data, root._p("secondary", 90))
    readonly property color secondaryP95:  (root._data, root._p("secondary", 95))
    readonly property color secondaryP98:  (root._data, root._p("secondary", 98))
    readonly property color secondaryP99:  (root._data, root._p("secondary", 99))
    readonly property color secondaryP100: (root._data, root._p("secondary", 100))

    readonly property color tertiaryP0:   (root._data, root._p("tertiary",  0))
    readonly property color tertiaryP5:   (root._data, root._p("tertiary",  5))
    readonly property color tertiaryP10:  (root._data, root._p("tertiary", 10))
    readonly property color tertiaryP15:  (root._data, root._p("tertiary", 15))
    readonly property color tertiaryP20:  (root._data, root._p("tertiary", 20))
    readonly property color tertiaryP25:  (root._data, root._p("tertiary", 25))
    readonly property color tertiaryP30:  (root._data, root._p("tertiary", 30))
    readonly property color tertiaryP35:  (root._data, root._p("tertiary", 35))
    readonly property color tertiaryP40:  (root._data, root._p("tertiary", 40))
    readonly property color tertiaryP50:  (root._data, root._p("tertiary", 50))
    readonly property color tertiaryP60:  (root._data, root._p("tertiary", 60))
    readonly property color tertiaryP70:  (root._data, root._p("tertiary", 70))
    readonly property color tertiaryP80:  (root._data, root._p("tertiary", 80))
    readonly property color tertiaryP90:  (root._data, root._p("tertiary", 90))
    readonly property color tertiaryP95:  (root._data, root._p("tertiary", 95))
    readonly property color tertiaryP98:  (root._data, root._p("tertiary", 98))
    readonly property color tertiaryP99:  (root._data, root._p("tertiary", 99))
    readonly property color tertiaryP100: (root._data, root._p("tertiary", 100))

    readonly property color neutralP0:   (root._data, root._p("neutral",  0))
    readonly property color neutralP5:   (root._data, root._p("neutral",  5))
    readonly property color neutralP10:  (root._data, root._p("neutral", 10))
    readonly property color neutralP15:  (root._data, root._p("neutral", 15))
    readonly property color neutralP20:  (root._data, root._p("neutral", 20))
    readonly property color neutralP25:  (root._data, root._p("neutral", 25))
    readonly property color neutralP30:  (root._data, root._p("neutral", 30))
    readonly property color neutralP35:  (root._data, root._p("neutral", 35))
    readonly property color neutralP40:  (root._data, root._p("neutral", 40))
    readonly property color neutralP50:  (root._data, root._p("neutral", 50))
    readonly property color neutralP60:  (root._data, root._p("neutral", 60))
    readonly property color neutralP70:  (root._data, root._p("neutral", 70))
    readonly property color neutralP80:  (root._data, root._p("neutral", 80))
    readonly property color neutralP90:  (root._data, root._p("neutral", 90))
    readonly property color neutralP95:  (root._data, root._p("neutral", 95))
    readonly property color neutralP98:  (root._data, root._p("neutral", 98))
    readonly property color neutralP99:  (root._data, root._p("neutral", 99))
    readonly property color neutralP100: (root._data, root._p("neutral", 100))

    readonly property color neutralVariantP0:   (root._data, root._p("neutral_variant",  0))
    readonly property color neutralVariantP5:   (root._data, root._p("neutral_variant",  5))
    readonly property color neutralVariantP10:  (root._data, root._p("neutral_variant", 10))
    readonly property color neutralVariantP15:  (root._data, root._p("neutral_variant", 15))
    readonly property color neutralVariantP20:  (root._data, root._p("neutral_variant", 20))
    readonly property color neutralVariantP25:  (root._data, root._p("neutral_variant", 25))
    readonly property color neutralVariantP30:  (root._data, root._p("neutral_variant", 30))
    readonly property color neutralVariantP35:  (root._data, root._p("neutral_variant", 35))
    readonly property color neutralVariantP40:  (root._data, root._p("neutral_variant", 40))
    readonly property color neutralVariantP50:  (root._data, root._p("neutral_variant", 50))
    readonly property color neutralVariantP60:  (root._data, root._p("neutral_variant", 60))
    readonly property color neutralVariantP70:  (root._data, root._p("neutral_variant", 70))
    readonly property color neutralVariantP80:  (root._data, root._p("neutral_variant", 80))
    readonly property color neutralVariantP90:  (root._data, root._p("neutral_variant", 90))
    readonly property color neutralVariantP95:  (root._data, root._p("neutral_variant", 95))
    readonly property color neutralVariantP98:  (root._data, root._p("neutral_variant", 98))
    readonly property color neutralVariantP99:  (root._data, root._p("neutral_variant", 99))
    readonly property color neutralVariantP100: (root._data, root._p("neutral_variant", 100))

    readonly property color errorP0:   (root._data, root._p("error",  0))
    readonly property color errorP5:   (root._data, root._p("error",  5))
    readonly property color errorP10:  (root._data, root._p("error", 10))
    readonly property color errorP15:  (root._data, root._p("error", 15))
    readonly property color errorP20:  (root._data, root._p("error", 20))
    readonly property color errorP25:  (root._data, root._p("error", 25))
    readonly property color errorP30:  (root._data, root._p("error", 30))
    readonly property color errorP35:  (root._data, root._p("error", 35))
    readonly property color errorP40:  (root._data, root._p("error", 40))
    readonly property color errorP50:  (root._data, root._p("error", 50))
    readonly property color errorP60:  (root._data, root._p("error", 60))
    readonly property color errorP70:  (root._data, root._p("error", 70))
    readonly property color errorP80:  (root._data, root._p("error", 80))
    readonly property color errorP90:  (root._data, root._p("error", 90))
    readonly property color errorP95:  (root._data, root._p("error", 95))
    readonly property color errorP98:  (root._data, root._p("error", 98))
    readonly property color errorP99:  (root._data, root._p("error", 99))
    readonly property color errorP100: (root._data, root._p("error", 100))

    // ── Constants ─────────────────────────────────────────────────────────────
    readonly property color black:        "#000000"
    readonly property color white:        "#ffffff"
    readonly property color transparent_: "transparent"

    // ── Catppuccin compat aliases ─────────────────────────────────────────────
    readonly property color crust:      background
    readonly property color mantle:     background
    readonly property color base:       surface
    readonly property color surface0:   surfaceContainer
    readonly property color surface1:   surfaceContainerHigh
    readonly property color surface2:   surfaceContainerHighest
    readonly property color overlay0:   outline
    readonly property color overlay1:   outlineVariant
    readonly property color overlay2:   onSurfaceVariant
    readonly property color subtext0:   onSurfaceVariant
    readonly property color subtext1:   onSurface
    readonly property color text:       onSurface
    readonly property color mauve:      tertiary
    readonly property color red:        error
    readonly property color maroon:     errorContainer
    readonly property color blue:       primary
    readonly property color sapphire:   primary
    readonly property color sky:        secondary
    readonly property color teal:       secondary
    readonly property color green:      secondary
    readonly property color peach:      tertiary
    readonly property color yellow:     tertiary
    readonly property color pink:       tertiary
    readonly property color flamingo:   tertiary
    readonly property color rosewater:  tertiary
    readonly property color lavender:   inversePrimary

    // ── Nord compat aliases ───────────────────────────────────────────────────
// ── Nord palette ──────────────────────────────────────────────────────────
    readonly property color nord0:  "#2E3440"
    readonly property color nord1:  "#3B4252"
    readonly property color nord2:  "#434C5E"
    readonly property color nord3:  "#4C566A"
    readonly property color nord4:  "#D8DEE9"
    readonly property color nord5:  "#E5E9F0"
    readonly property color nord6:  "#ECEFF4"
    readonly property color nord7:  "#8FBCBB"
    readonly property color nord8:  "#88C0D0"
    readonly property color nord9:  "#81A1C1"
    readonly property color nord10: "#5E81AC"

    //-- border
    readonly property color borderColor: background 
        readonly property color panelBackground:  "#1e1e2e"
        readonly property color panelBorder:      "#313244"
        readonly property color scrimColor:        "#000000"
        readonly property real  scrimOpacity:      0.52
        readonly property color textColor:         "#cdd6f4"
        readonly property color subtextColor:      "#a6adc8"

    // Pane background — used by all four pane components
    readonly property color panelBg:      background
    readonly property color panelAccent:  primary
    readonly property color panelFg:      secondaryP30
}
