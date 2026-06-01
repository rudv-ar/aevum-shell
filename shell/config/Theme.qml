pragma Singleton

import QtQuick
import Quickshell

Singleton {
  // ── Hole margins ───────────────────────────────────
    FontLoader { id: fontLoaderFA6; source: "file://" + Quickshell.shellDir + "/../shared/fonts/Font Awesome 6 Free-Solid-900.otf" }
    FontLoader { id: fontLoaderAnurati;           source: "file://" + Quickshell.shellDir + "/../shared/fonts/Anurati.otf" }
    FontLoader { id: fontLoaderPoppins;           source: "file://" + Quickshell.shellDir + "/../shared/fonts/Poppins.ttf" }
    FontLoader { id: fontLoaderGolgix;            source: "file://" + Quickshell.shellDir + "/../shared/fonts/Golgix-Regular.ttf" }
    FontLoader { id: fontLoaderAvaporeRound;      source: "file://" + Quickshell.shellDir + "/../shared/fonts/Avapore-Round.otf" }
    FontLoader { id: fontLoaderBiologicalSystems; source: "file://" + Quickshell.shellDir + "/../shared/fonts/Biological-Systems-Demo.otf" }
    FontLoader { id: fontLoaderHardcoreImperial;  source: "file://" + Quickshell.shellDir + "/../shared/fonts/Hardcore Imperial.ttf" }
    FontLoader { id: fontLoaderAssistedSensors;   source: "file://" + Quickshell.shellDir + "/../shared/fonts/Assisted-Sensors-Demo.otf" }

    readonly property string fontAnurati:           fontLoaderAnurati.name
    readonly property string fontPoppins:           fontLoaderPoppins.name
    readonly property string fontGolgixRegular:     fontLoaderGolgix.name
    readonly property string fontAvaporeRound:      fontLoaderAvaporeRound.name
    readonly property string fontBiologicalSystems: fontLoaderBiologicalSystems.name
    readonly property string fontHardcoreImperial:  fontLoaderHardcoreImperial.name
    readonly property string fontAssistedSensors:   fontLoaderAssistedSensors.name
    readonly property string fontAwesome6: fontLoaderFA6.name

    readonly property int holeLeft:   35
    readonly property int holeTop:    10
    readonly property int holeRight:  10
    readonly property int holeBottom: 10
    readonly property int holeRadius: 12

    readonly property int barBottomPad: 16

    // ── Palette (Catppuccin Mocha) ─────────────────────
    readonly property color base:      "#181b1f"
    readonly property color surface0:  "#181b1f"
    readonly property color surface1:  "#45475a"
    readonly property color accent:    "#cba6f7"
    readonly property color text:      "#cdd6f4"
    readonly property color textColor: "#ffffff"
    readonly property color launcherBg: Qt.rgba(1, 1, 1, 0.06)

    // ── Semantic ──────────────────────────────────────
    readonly property color frameColor: surface0

    // ── Launcher pill ─────────────────────────────────
    readonly property int    pillWidth:      28
    readonly property int    pillHeight:     28
    readonly property int    pillRadius:     16
    readonly property int    pillIconSize:   16
    readonly property int    pillTopPad:     0
    readonly property string nerdFontFamily: "Material Design Icons"
    readonly property bool showDesktopNumbers: false // deprecated. don't set to true 
    readonly property bool colorWorkspaceIndicator: true


// ── Power pill ────────────────────────────────────
    readonly property int    powerPillW:    28
    readonly property int    powerPillH:    28
    readonly property int    powerPillR:    16
    readonly property int    powerIconSize: 16
    readonly property color  powerBg:       "#3b1f2b"
    readonly property color  powerIcon:     "#f38ba8"
    readonly property color  powerRipple:   "#f38ba8"
    readonly property string powerLeftCmd:  "systemctl poweroff"
    readonly property string powerRightCmd: "systemctl reboot"

    // ── Fonts ─────────────────────────────────────────
    readonly property string fontMaterial: "Material Symbols Rounded"

    // ── Animation durations (ms) ──────────────────────
    readonly property int animFast:   120
    readonly property int animNormal: 220
    readonly property int animSlow:   400    

}
