import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.settings
import qs.modules.clock
import qs.modules.workspace
import qs.modules.audio
import qs.modules.network
import qs.modules.powermenu

ShellRoot {
    Variants {
        model: Quickshell.screens
        delegate: Component {
            PanelWindow {
                id: win
                required property var modelData

                screen: modelData

                anchors.top:   true
                anchors.left:  true
                anchors.right: true

                color:          "transparent"
                implicitHeight: Properties.barHeight + Properties.barMarginTop

                Rectangle {
                    id: bar

                    anchors.top:         parent.top
                    anchors.topMargin:   Properties.barMarginTop
                    anchors.left:        parent.left
                    anchors.leftMargin:  Properties.barMarginLeft
                    anchors.right:       parent.right
                    anchors.rightMargin: Properties.barMarginRight

                    height: Properties.barHeight
                    radius: Properties.barRadius
                    color:  Theme.barBackground

                    border.color: Theme.barBorder
                    border.width: Properties.barFloating ? 1 : 0

                    RowLayout {
                        anchors.fill:        parent
                        anchors.leftMargin:  Properties.barPaddingX
                        anchors.rightMargin: Properties.barPaddingX
                        spacing: 0

                        // ── Left ──────────────────────────────────────────────
                        Item {
                            Layout.fillWidth:     true
                            Layout.preferredWidth: 0

                            WorkspaceIndicator {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left:           parent.left
                            }
                        }

                        // ── Center ────────────────────────────────────────────
                        ClockPillHover {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                        }

                        // ── Right ─────────────────────────────────────────────
                        Item {
                            Layout.fillWidth:     true
                            Layout.preferredWidth: 0

                            Row {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right:          parent.right
                                spacing: Properties.rightbarChipSpacing

                                NetworkPill      {}
                                NotificationPill {}
                                AudioPill        {}
                                PowerPill        {}
                            }
                        }
                    }
                }
            }
        }
    }
}

