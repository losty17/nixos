pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.I3
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Services.Notifications
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import Quickshell.Wayland
import "bar" as Bar
import "components" as UI
import "features/audio" as Audio
import "features/bluetooth" as BluetoothFeature
import "features/calendar" as Calendar
import "features/network" as Network
import "features/notifications" as Notifications
import "features/session" as Session
import "features/tray" as Tray
import "features/wallpaper" as Wallpaper
import "services" as Services

ShellRoot {
    id: shellRoot

    property bool idleLockEnabled: true
    property int idleLockTimeout: 900

    SystemClock {
        id: systemClock

        precision: SystemClock.Seconds
    }

    NotificationServer {
        id: notificationServer

        keepOnReload: true
        bodySupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: function(notification) {
            notification.tracked = true;
        }
    }

    Session.SessionLock {
        id: sessionLock

        clock: systemClock
    }

    Services.WorkspaceTracker {
        id: workspaceTracker
    }

    Services.WeatherService {
        id: weatherService
    }

    Services.MediaController {
        id: mediaController
    }

    IdleMonitor {
        id: idleMonitor

        enabled: shellRoot.idleLockEnabled
        timeout: shellRoot.idleLockTimeout
        respectInhibitors: true
        onIsIdleChanged: if (isIdle && shellRoot.idleLockEnabled) sessionLock.requestLock()
    }

    IpcHandler {
        target: "session"

        function lock(): void {
            sessionLock.requestLock();
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel

            property var modelData
            property string activePopup: ""
            property var audioSink: Pipewire.defaultAudioSink
            property var audioSource: Pipewire.defaultAudioSource
            property var battery: UPower.displayDevice
            readonly property int notificationCount: notificationServer && notificationServer.trackedNotifications ? notificationServer.trackedNotifications.values.length : 0
            readonly property int trayCount: SystemTray.items && SystemTray.items.values ? SystemTray.items.values.length : 0

            property var wifiDevice: {
                const devices = Networking.devices.values;
                for (let i = 0; i < devices.length; ++i) {
                    if (devices[i].type === DeviceType.Wifi)
                        return devices[i];
                }
                return null;
            }
            property var bluetoothAdapter: Bluetooth.defaultAdapter

            function togglePopup(name) {
                panel.activePopup = panel.activePopup === name ? "" : name;
            }

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
                objects: Pipewire.nodes && Pipewire.nodes.values ? Pipewire.nodes.values : []
            }

            Rectangle {
                anchors.fill: parent
                color: UI.Theme.background
            }

            Row {
                id: workspaceContent

                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                height: parent.height

                Repeater {
                    model: I3.workspaces

                    delegate: Bar.WorkspaceButton {
                        required property var modelData

                        workspace: modelData
                        applications: workspaceTracker.applications && workspaceTracker.applications[modelData.name] ? workspaceTracker.applications[modelData.name] : []
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

                Bar.MediaWidget {
                    id: mediaWidget

                    anchors.centerIn: parent
                    player: mediaController.player
                }

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    visible: !mediaWidget.visible
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: ToplevelManager.activeToplevel ? ToplevelManager.activeToplevel.title : ""
                    color: UI.Theme.text
                    elide: Text.ElideRight
                    font.family: UI.Theme.textFont
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

                UI.IconButton {
                    id: trayButton

                    visible: panel.trayCount > 0
                    icon: "\uf078"
                    active: panel.activePopup === "tray"
                    onClicked: panel.togglePopup("tray")
                }

                Item {
                    id: batteryItem

                    visible: panel.battery && panel.battery.ready && panel.battery.isLaptopBattery
                    width: visible ? 28 : 0
                    height: parent.height

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 5
                        anchors.verticalCenter: parent.verticalCenter
                        text: panel.battery && (panel.battery.state === UPowerDeviceState.Charging || panel.battery.state === UPowerDeviceState.PendingCharge) ? "\uf0e7" : panel.battery && panel.battery.state === UPowerDeviceState.FullyCharged ? "\uf240" : ["\uf244", "\uf243", "\uf242", "\uf241", "\uf240"][Math.min(4, Math.max(0, Math.floor(panel.battery.percentage * 5)))]
                        color: panel.battery && panel.battery.state === UPowerDeviceState.Charging ? UI.Theme.accentText : panel.battery && panel.battery.percentage <= 0.15 ? UI.Theme.danger : panel.battery && panel.battery.percentage <= 0.3 ? UI.Theme.warning : UI.Theme.text
                        font.family: UI.Theme.iconFont
                        font.pixelSize: 16
                    }

                    MouseArea {
                        id: batteryMouseArea

                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        hoverEnabled: true
                    }
                }

                Item {
                    id: clockItem

                    width: clockText.implicitWidth + 16
                    height: parent.height

                    Text {
                        id: clockText

                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: Qt.formatTime(systemClock.date, "HH:mm")
                        color: UI.Theme.text
                        font.family: UI.Theme.textFont
                        font.pixelSize: 14
                        font.weight: 600
                    }

                    MouseArea {
                        id: clockMouseArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: panel.togglePopup("calendar")
                    }
                }

                UI.IconButton {
                    id: notificationButton

                    icon: panel.notificationCount > 0 ? "\uf0f3" : "\uf1f6"
                    active: panel.notificationCount > 0
                    onClicked: panel.togglePopup("notifications")
                }

                UI.IconButton {
                    id: volumeButton

                    icon: {
                        if (!panel.audioSink || !panel.audioSink.audio)
                            return "\uf026"; // volume muted
                        if (panel.audioSink.audio.muted || panel.audioSink.audio.volume <= 0)
                            return "\uf026"; // volume muted
                        if (panel.audioSink.audio.volume < 0.5)
                            return "\uf027"; // volume medium
                        return "\uf028"; // volume full
                    }
                    active: panel.audioSink && panel.audioSink.audio && !panel.audioSink.audio.muted
                    disabled: !panel.audioSink || !panel.audioSink.audio
                    onClicked: panel.togglePopup("audio")
                    onScrolled: function(value) {
                        if (panel.audioSink && panel.audioSink.audio)
                            panel.audioSink.audio.volume = Math.max(0, Math.min(1, panel.audioSink.audio.volume + (value > 0 ? 0.05 : -0.05)));
                    }
                }

                UI.IconButton {
                    id: wifiButton

                    icon: "\uf1eb"
                    active: Networking.wifiEnabled && panel.wifiDevice && panel.wifiDevice.connected
                    onClicked: panel.togglePopup("wifi")
                }

                UI.IconButton {
                    id: bluetoothButton

                    icon: "\uf294"
                    active: panel.bluetoothAdapter && panel.bluetoothAdapter.enabled
                    onClicked: panel.togglePopup("bluetooth")
                }

                UI.IconButton {
                    id: wallpaperButton

                    icon: "\uf03e"
                    active: panel.activePopup === "wallpaper"
                    onClicked: panel.togglePopup("wallpaper")
                }

                UI.IconButton {
                    id: sessionButton

                    icon: "\uf011"
                    active: panel.activePopup === "session"
                    onClicked: panel.togglePopup("session")
                }
            }

            Bar.BatteryTooltip {
                targetItem: batteryItem
                battery: panel.battery
                open: batteryMouseArea.containsMouse
            }

            Bar.ClockTooltip {
                targetItem: clockItem
                clock: systemClock
                open: clockMouseArea.containsMouse
            }

            Audio.AudioPopup {
                panelWindow: panel
                outputNode: panel.audioSink
                inputNode: panel.audioSource
                open: panel.activePopup === "audio"
                onCloseRequested: panel.activePopup = ""
            }

            Calendar.CalendarPopup {
                panelWindow: panel
                clock: systemClock
                weatherLocation: weatherService.location.replace(/_/g, " ")
                weatherText: weatherService.text
                open: panel.activePopup === "calendar"
                onRefreshWeatherRequested: weatherService.refresh()
                onCloseRequested: panel.activePopup = ""
            }

            Notifications.NotificationsPopup {
                panelWindow: panel
                server: notificationServer
                open: panel.activePopup === "notifications"
                onCloseRequested: panel.activePopup = ""
            }

            Wallpaper.WallpaperPopup {
                panelWindow: panel
                open: panel.activePopup === "wallpaper"
                onCloseRequested: panel.activePopup = ""
            }

            Session.SessionMenu {
                panelWindow: panel
                idleLockEnabled: shellRoot.idleLockEnabled
                open: panel.activePopup === "session"
                onLockRequested: {
                    panel.activePopup = "";
                    sessionLock.requestLock();
                }
                onToggleIdleRequested: shellRoot.idleLockEnabled = !shellRoot.idleLockEnabled
                onActionRequested: function(action) {
                    panel.activePopup = "";
                    if (action === "logout")
                        Quickshell.execDetached(["swaymsg", "exit"]);
                    else if (action === "suspend")
                        Quickshell.execDetached(["systemctl", "suspend"]);
                    else if (action === "reboot")
                        Quickshell.execDetached(["systemctl", "reboot"]);
                    else if (action === "shutdown")
                        Quickshell.execDetached(["systemctl", "poweroff"]);
                }
                onCloseRequested: panel.activePopup = ""
            }

            Tray.TrayPopup {
                panelWindow: panel
                open: panel.activePopup === "tray"
                onCloseRequested: panel.activePopup = ""
            }

            Network.WifiPopup {
                panelWindow: panel
                wifiDevice: panel.wifiDevice
                open: panel.activePopup === "wifi"
                onCloseRequested: panel.activePopup = ""
            }

            BluetoothFeature.BluetoothPopup {
                panelWindow: panel
                adapter: panel.bluetoothAdapter
                open: panel.activePopup === "bluetooth"
                onCloseRequested: panel.activePopup = ""
            }
        }
    }
}
