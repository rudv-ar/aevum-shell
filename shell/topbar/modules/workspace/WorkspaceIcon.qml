import QtQuick
import Quickshell.Io
import qs.settings
import qs.services.workspace

Item {
    id: root

    implicitWidth:  _pill.width
    implicitHeight: Properties.barHeight

    readonly property string currentGlyph:
        Properties.workspaceIconGlyphs[WorkspaceService.focusedName] ?? "\uf128"

    property string _displayedGlyph: currentGlyph

    onCurrentGlyphChanged: _fadeAnim.restart()

    // ── Launcher process ──────────────────────────────────────────────────────
    Process {
        id: _launchProc
        running: false
    }

    HoverHandler {
        id: _hover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: {
            _launchProc.command = Commands.rofiLauncher()
            _launchProc.running = true
        }
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        // no-op for now — left click reserved
    }

    Rectangle {
        id: _pill
        anchors.verticalCenter: parent.verticalCenter
        height: root.implicitHeight - Properties.workspaceIndicatorPaddingY * 2
        width:  height
        radius: height / 2

        color: _hover.hovered
               ? Theme.workspaceIconBackgroundHovered
               : Theme.workspaceIconBackground

        Behavior on color {
            ColorAnimation { duration: Properties.workspaceDotAnimDuration }
        }

        Text {
            id: _icon
            anchors.centerIn: parent
            font.family:      Properties.nerdFontFamily
            font.pixelSize:   Properties.workspaceIconFontSize
            color:            Theme.workspaceIconColor
            text:             root._displayedGlyph
        }
    }

    SequentialAnimation {
        id: _fadeAnim
        NumberAnimation {
            target: _icon; property: "opacity"
            to: 0.0; duration: Properties.workspaceDotAnimDuration / 2
            easing.type: Easing.InQuad
        }
        ScriptAction {
            script: root._displayedGlyph = root.currentGlyph
        }
        NumberAnimation {
            target: _icon; property: "opacity"
            to: 1.0; duration: Properties.workspaceDotAnimDuration / 2
            easing.type: Easing.OutQuad
        }
    }
}

