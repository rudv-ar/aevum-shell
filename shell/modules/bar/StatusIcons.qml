pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import Quickshell.Services.UPower
import qs.config
import qs.services
import qs.utils

Item {
    id: root

    // ── Dimension tokens ──────────────────────────────
    readonly property int   pillW:    Theme.pillWidth
    readonly property int   iconSize: Theme.pillIconSize
    readonly property color iconCol:  Theme.statusIconColor
    readonly property color errorCol: Theme.powerIcon
    readonly property string fontMat: Theme.fontMaterial

    // ── Derived ───────────────────────────────────────
    readonly property bool batteryPresent: UPower.displayDevice.isLaptopBattery
    readonly property bool btConnected:    Bluetooth.devices.values.some(d => d.connected)
    readonly property bool btEnabled:      Bluetooth.defaultAdapter?.powered ?? false

    implicitWidth:  pillW
    implicitHeight: pill.implicitHeight

    // ── Pill ──────────────────────────────────────────
    Rectangle {
        id: pill

        anchors.left:  parent.left
        anchors.right: parent.right
        radius:        width / 2
        color:         Theme.workspaceBg
        clip:          true

        implicitHeight: iconCol.implicitHeight + 16

        Behavior on implicitHeight {
            NumberAnimation {
                duration:    Theme.animNormal
                easing.type: Easing.OutCubic
            }
        }

        ColumnLayout {
            id: iconCol

            anchors {
                left:         parent.left
                right:        parent.right
                bottom:       parent.bottom
                bottomMargin: 8
            }
            spacing: 4

            // ── Audio ──────────────────────────────────
            Loader {
                id: audioLoader
                asynchronous:        true
                Layout.alignment:    Qt.AlignHCenter
                visible:             true
                active:              true
                sourceComponent: Text {
                    text:           Icons.getVolumeIcon(AudioService.volume, AudioService.muted)
                    font.family:    root.fontMat
                    font.pixelSize: root.iconSize
                    color:          root.iconCol
                    renderType:     Text.NativeRendering
                }
            }

            // ── Microphone ────────────────────────────
            Loader {
                asynchronous:     true
                Layout.alignment: Qt.AlignHCenter
                visible:          true
                active:           true
                sourceComponent: Text {
                    text:           Icons.getMicVolumeIcon(AudioService.sourceVolume, AudioService.sourceMuted)
                    font.family:    root.fontMat
                    font.pixelSize: root.iconSize
                    color:          root.iconCol
                    renderType:     Text.NativeRendering
                }
            }

            // ── WiFi ──────────────────────────────────
            Loader {
                asynchronous:     true
                Layout.alignment: Qt.AlignHCenter
                active:           NetworkService.wifiEnabled
                visible:          active
                sourceComponent: Text {
                    text: NetworkService.active
                        ? Icons.getNetworkIcon(NetworkService.active.strength, NetworkService.active.isSecure)
                        : "wifi_off"
                    font.family:    root.fontMat
                    font.pixelSize: root.iconSize
                    color:          root.iconCol
                    renderType:     Text.NativeRendering
                }
            }

            // ── Ethernet ──────────────────────────────
            Loader {
                asynchronous:     true
                Layout.alignment: Qt.AlignHCenter
                active:           NetworkService.activeEthernet !== null
                visible:          active
                sourceComponent: Text {
                    text:           "cable"
                    font.family:    root.fontMat
                    font.pixelSize: root.iconSize
                    color:          root.iconCol
                    renderType:     Text.NativeRendering
                }
            }

            // ── Bluetooth ─────────────────────────────
            Loader {
                id: btLoader
                asynchronous:     true
                Layout.alignment: Qt.AlignHCenter
                active:           true
                visible:          true
                sourceComponent: Text {
                    text: {
                        if (!root.btEnabled)    return "bluetooth_disabled"
                        if (root.btConnected)   return "bluetooth_connected"
                        return "bluetooth"
                    }
                    font.family:    root.fontMat
                    font.pixelSize: root.iconSize
                    color:          root.iconCol
                    renderType:     Text.NativeRendering
                }
            }

            // ── Bluetooth connecting devices ───────────
            Repeater {
                model: Bluetooth.devices.values.filter(d => d.connected) // qmllint disable unresolved-type

                delegate: Loader {
                    id: btDevLoader
                    required property var modelData
                    asynchronous:     true
                    Layout.alignment: Qt.AlignHCenter
                    active:           true
                    sourceComponent: Text {
                        id: btDevIcon
                        text:           Icons.getBluetoothIcon(btDevLoader.modelData?.icon ?? "")
                        font.family:    root.fontMat
                        font.pixelSize: root.iconSize
                        color:          root.iconCol
                        renderType:     Text.NativeRendering

                        SequentialAnimation on opacity {
                            running:          btDevLoader.modelData?.state !== 2  // 2 = Connected
                            alwaysRunToEnd:   true
                            loops:            Animation.Infinite
                            NumberAnimation { from: 1; to: 0; duration: Theme.animNormal }
                            NumberAnimation { from: 0; to: 1; duration: Theme.animNormal }
                        }
                    }
                }
            }

            // ── Battery ───────────────────────────────
            Loader {
                asynchronous:     true
                Layout.alignment: Qt.AlignHCenter
                active:           root.batteryPresent
                visible:          active
                sourceComponent: Text {
                    readonly property bool charging: [
                        UPowerDeviceState.Charging,
                        UPowerDeviceState.FullyCharged,
                        UPowerDeviceState.PendingCharge
                    ].includes(UPower.displayDevice.state)

                    text:           Icons.getBatteryIcon(UPower.displayDevice.percentage, charging)
                    font.family:    root.fontMat
                    font.pixelSize: root.iconSize
                    color:          (!UPower.onBattery || UPower.displayDevice.percentage > 0.2)
                                        ? root.iconCol : root.errorCol
                    renderType:     Text.NativeRendering
                }
            }
        }
    }
}
