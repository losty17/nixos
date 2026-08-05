pragma ComponentBehavior: Bound

//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.I3
import Quickshell.Networking
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import Quickshell.Wayland

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel

            property var modelData
            property bool wifiOpen: false
            property bool bluetoothOpen: false
            property var audioSink: Pipewire.defaultAudioSink
            property var battery: UPower.displayDevice

            property var wifiDevice: {
                const devices = Networking.devices.values;
                for (let i = 0; i < devices.length; ++i) {
                    if (devices[i].type === DeviceType.Wifi)
                        return devices[i];
                }
                return null;
            }
            property var bluetoothAdapter: Bluetooth.defaultAdapter

            screen: modelData
            anchors {
                top: true
                left: true
                right: true
            }
            implicitHeight: 28
            color: "transparent"
            aboveWindows: true
            exclusionMode: ExclusionMode.Auto

            PwObjectTracker {
                objects: panel.audioSink ? [panel.audioSink] : []
            }

            SystemClock {
                id: clock

                precision: SystemClock.Minutes
            }

            Rectangle {
                anchors.fill: parent
                color: "#0a0a0a"
            }

            Row {
                id: workspaceContent

                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                height: parent.height

                Repeater {
                    model: I3.workspaces

                    delegate: WorkspaceButton {
                        required property var modelData

                        workspace: modelData
                        screenName: panel.modelData ? panel.modelData.name : ""
                    }
                }
            }

            Item {
                id: centerContent

                anchors.left: workspaceContent.right
                anchors.right: statusContent.left
                anchors.verticalCenter: parent.verticalCenter
                height: parent.height

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: ToplevelManager.activeToplevel ? ToplevelManager.activeToplevel.title : ""
                    color: "#e6e8ee"
                    elide: Text.ElideRight
                    font.family: "Inter"
                    font.pixelSize: 14
                    font.weight: 600
                }
            }

            Row {
                id: statusContent

                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: parent.height
                spacing: 0

                Repeater {
                    model: SystemTray.items && SystemTray.items.values ? SystemTray.items.values : []

                    delegate: TrayItem {
                        required property var modelData

                        trayItem: modelData
                        panelWindow: panel
                    }
                }

                ConnectivityButton {
                    id: volumeButton

                    icon: {
                        if (!panel.audioSink || !panel.audioSink.audio || panel.audioSink.audio.muted)
                            return "\uf026";
                        if (panel.audioSink.audio.volume < 0.34)
                            return "\uf026";
                        if (panel.audioSink.audio.volume < 0.67)
                            return "\uf027";
                        return "\uf028";
                    }
                    active: panel.audioSink && panel.audioSink.audio && !panel.audioSink.audio.muted
                    disabled: !panel.audioSink || !panel.audioSink.audio
                    onClicked: if (panel.audioSink && panel.audioSink.audio) panel.audioSink.audio.muted = !panel.audioSink.audio.muted
                    onScrolled: function(value) {
                        if (panel.audioSink && panel.audioSink.audio)
                            panel.audioSink.audio.volume = Math.max(0, Math.min(1, panel.audioSink.audio.volume + (value > 0 ? 0.05 : -0.05)));
                    }
                }

                Item {
                    id: batteryItem

                    visible: panel.battery && panel.battery.ready && panel.battery.isPresent
                    width: visible ? 28 : 0
                    height: parent.height

                    Text {
                        anchors.centerIn: parent
                        text: {
                            if (!panel.battery)
                                return "";
                            if (panel.battery.state === UPowerDeviceState.Charging)
                                return "\uf0e7";
                            const level = Math.max(0, Math.min(4, Math.floor(panel.battery.percentage / 20)));
                            return ["\uf244", "\uf243", "\uf242", "\uf241", "\uf240"][level];
                        }
                        color: {
                            if (!panel.battery)
                                return "#e6e8ee";
                            if (panel.battery.state === UPowerDeviceState.Charging)
                                return "#ffffff";
                            if (panel.battery.percentage <= 15)
                                return "#e06c75";
                            if (panel.battery.percentage <= 30)
                                return "#e5c07b";
                            return "#e6e8ee";
                        }
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 16
                    }
                }

                Text {
                    width: 52
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: Qt.formatTime(clock.date, "HH:mm")
                    color: "#e6e8ee"
                    font.family: "Inter"
                    font.pixelSize: 14
                    font.weight: 600
                }

                ConnectivityButton {
                    id: wifiButton

                    icon: "\uf1eb"
                    active: Networking.wifiEnabled && panel.wifiDevice && panel.wifiDevice.connected
                    onClicked: {
                        panel.bluetoothOpen = false;
                        panel.wifiOpen = !panel.wifiOpen;
                    }
                }

                ConnectivityButton {
                    id: bluetoothButton

                    icon: "\uf294"
                    active: panel.bluetoothAdapter && panel.bluetoothAdapter.enabled
                    onClicked: {
                        panel.wifiOpen = false;
                        panel.bluetoothOpen = !panel.bluetoothOpen;
                    }
                }

                ConnectivityButton {
                    id: controlCenterButton

                    icon: "\uf1de"
                    onClicked: Quickshell.execDetached(["noctalia-shell", "ipc", "call", "controlCenter", "toggle"])
                }
            }

            WifiPopup {
                panelWindow: panel
                wifiDevice: panel.wifiDevice
                open: panel.wifiOpen
                onCloseRequested: panel.wifiOpen = false
            }

            BluetoothPopup {
                panelWindow: panel
                adapter: panel.bluetoothAdapter
                open: panel.bluetoothOpen
                onCloseRequested: panel.bluetoothOpen = false
            }
        }
    }
}
