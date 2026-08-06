pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.I3
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Services.Mpris
import Quickshell.Services.Notifications
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import Quickshell.Wayland

ShellRoot {
    id: shellRoot

    property var workspaceApplications: ({})
    property string weatherLocation: "Santa_Cruz_do_Sul"
    property string weatherText: "Weather unavailable"
    property bool idleLockEnabled: true
    property int idleLockTimeout: 900
    property var mediaPlayer: null

    function refreshWeather() {
        weatherProcess.exec(weatherCommand);
    }

    function chooseMediaPlayer() {
        const players = Mpris.players && Mpris.players.values ? Mpris.players.values : [];
        for (let i = 0; i < players.length; ++i) {
            if (players[i].isPlaying)
                return players[i];
        }
        return players.length > 0 ? players[0] : null;
    }

    function updateWorkspaceApplications(output) {
        if (!output || output.trim().length === 0)
            return;

        try {
            const tree = JSON.parse(output);
            const next = ({});

            function walk(node, workspaceName) {
                if (!node)
                    return;

                let currentWorkspace = workspaceName;
                if (node.type === "workspace") {
                    currentWorkspace = node.name || workspaceName;
                    if (currentWorkspace && !next[currentWorkspace])
                        next[currentWorkspace] = [];
                }

                const nodes = (node.nodes || []).concat(node.floating_nodes || []);
                const properties = node.window_properties || {};
                const appId = node.app_id || "";
                const className = properties.class || properties.instance || "";

                if (currentWorkspace && node.type === "con" && (appId || className) && (nodes.length === 0 || node.pid)) {
                    const key = String(node.id || appId || className);
                    const existing = next[currentWorkspace];
                    let duplicate = false;
                    for (let i = 0; i < existing.length; ++i) {
                        if (existing[i].key === key) {
                            duplicate = true;
                            break;
                        }
                    }
                    if (!duplicate)
                        existing.push({ key: key, appId: appId, className: className, title: node.name || "" });
                }

                for (let i = 0; i < nodes.length; ++i)
                    walk(nodes[i], currentWorkspace);
            }

            walk(tree, "");
            shellRoot.workspaceApplications = next;
        } catch (error) {
            // Sway can return a partial tree while it is reloading.
        }
    }

    readonly property var weatherCommand: ["curl", "-fsSL", "--max-time", "8", "https://wttr.in/" + weatherLocation + "?format=%c|%t|%C"]

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

    SessionLock {
        id: sessionLock

        clock: systemClock
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

    Process {
        id: workspaceTreeProcess

        command: ["swaymsg", "-t", "get_tree", "-r"]
        running: true

        stdout: StdioCollector {
            id: workspaceTreeOutput

            onStreamFinished: shellRoot.updateWorkspaceApplications(workspaceTreeOutput.text)
        }
    }

    Process {
        id: weatherProcess

        command: shellRoot.weatherCommand
        running: true

        stdout: StdioCollector {
            id: weatherOutput

            onStreamFinished: {
                const output = weatherOutput.text.trim();
                if (output.length > 0)
                    shellRoot.weatherText = output;
            }
        }
    }

    Timer {
        interval: 2000
        repeat: true
        running: true
        onTriggered: workspaceTreeProcess.exec(workspaceTreeProcess.command)
    }

    Timer {
        interval: 900000
        repeat: true
        running: true
        onTriggered: shellRoot.refreshWeather()
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: shellRoot.mediaPlayer = shellRoot.chooseMediaPlayer()
    }

    Component.onCompleted: {
        shellRoot.mediaPlayer = shellRoot.chooseMediaPlayer();
        shellRoot.refreshWeather();
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel

            property var modelData
            property bool wifiOpen: false
            property bool bluetoothOpen: false
            property bool audioOpen: false
            property bool calendarOpen: false
            property bool notificationsOpen: false
            property bool wallpaperOpen: false
            property bool sessionOpen: false
            property bool trayOpen: false
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
                        applications: shellRoot.workspaceApplications && shellRoot.workspaceApplications[modelData.name] ? shellRoot.workspaceApplications[modelData.name] : []
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

                MediaWidget {
                    id: mediaWidget

                    anchors.centerIn: parent
                    player: shellRoot.mediaPlayer
                }

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    visible: !mediaWidget.visible
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

                ConnectivityButton {
                    id: trayButton

                    visible: panel.trayCount > 0
                    icon: "\uf078"
                    active: panel.trayOpen
                    onClicked: {
                        panel.wifiOpen = false;
                        panel.bluetoothOpen = false;
                        panel.audioOpen = false;
                        panel.calendarOpen = false;
                        panel.notificationsOpen = false;
                        panel.wallpaperOpen = false;
                        panel.sessionOpen = false;
                        panel.trayOpen = !panel.trayOpen;
                    }
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
                        color: panel.battery && panel.battery.state === UPowerDeviceState.Charging ? "#d8b8e3" : panel.battery && panel.battery.percentage <= 0.15 ? "#e06c75" : panel.battery && panel.battery.percentage <= 0.3 ? "#e5c07b" : "#e6e8ee"
                        font.family: "Symbols Nerd Font"
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
                        color: "#e6e8ee"
                        font.family: "Inter"
                        font.pixelSize: 14
                        font.weight: 600
                    }

                    MouseArea {
                        id: clockMouseArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            panel.wifiOpen = false;
                            panel.bluetoothOpen = false;
                            panel.audioOpen = false;
                            panel.notificationsOpen = false;
                            panel.wallpaperOpen = false;
                            panel.sessionOpen = false;
                            panel.trayOpen = false;
                            panel.calendarOpen = !panel.calendarOpen;
                        }
                    }
                }

                ConnectivityButton {
                    id: notificationButton

                    icon: panel.notificationCount > 0 ? "\uf0f3" : "\uf1f6"
                    active: panel.notificationCount > 0
                    onClicked: {
                        panel.wifiOpen = false;
                        panel.bluetoothOpen = false;
                        panel.audioOpen = false;
                        panel.calendarOpen = false;
                        panel.wallpaperOpen = false;
                        panel.sessionOpen = false;
                        panel.trayOpen = false;
                        panel.notificationsOpen = !panel.notificationsOpen;
                    }
                }

                ConnectivityButton {
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
                    onClicked: {
                        panel.wifiOpen = false;
                        panel.bluetoothOpen = false;
                        panel.calendarOpen = false;
                        panel.notificationsOpen = false;
                        panel.wallpaperOpen = false;
                        panel.sessionOpen = false;
                        panel.trayOpen = false;
                        panel.audioOpen = !panel.audioOpen;
                    }
                    onScrolled: function(value) {
                        if (panel.audioSink && panel.audioSink.audio)
                            panel.audioSink.audio.volume = Math.max(0, Math.min(1, panel.audioSink.audio.volume + (value > 0 ? 0.05 : -0.05)));
                    }
                }

                ConnectivityButton {
                    id: wifiButton

                    icon: "\uf1eb"
                    active: Networking.wifiEnabled && panel.wifiDevice && panel.wifiDevice.connected
                    onClicked: {
                        panel.bluetoothOpen = false;
                        panel.audioOpen = false;
                        panel.calendarOpen = false;
                        panel.notificationsOpen = false;
                        panel.wallpaperOpen = false;
                        panel.sessionOpen = false;
                        panel.trayOpen = false;
                        panel.wifiOpen = !panel.wifiOpen;
                    }
                }

                ConnectivityButton {
                    id: bluetoothButton

                    icon: "\uf294"
                    active: panel.bluetoothAdapter && panel.bluetoothAdapter.enabled
                    onClicked: {
                        panel.wifiOpen = false;
                        panel.audioOpen = false;
                        panel.calendarOpen = false;
                        panel.notificationsOpen = false;
                        panel.wallpaperOpen = false;
                        panel.sessionOpen = false;
                        panel.trayOpen = false;
                        panel.bluetoothOpen = !panel.bluetoothOpen;
                    }
                }

                ConnectivityButton {
                    id: wallpaperButton

                    icon: "\uf03e"
                    active: panel.wallpaperOpen
                    onClicked: {
                        panel.wifiOpen = false;
                        panel.bluetoothOpen = false;
                        panel.audioOpen = false;
                        panel.calendarOpen = false;
                        panel.notificationsOpen = false;
                        panel.sessionOpen = false;
                        panel.trayOpen = false;
                        panel.wallpaperOpen = !panel.wallpaperOpen;
                    }
                }

                ConnectivityButton {
                    id: sessionButton

                    icon: "\uf011"
                    active: panel.sessionOpen
                    onClicked: {
                        panel.wifiOpen = false;
                        panel.bluetoothOpen = false;
                        panel.audioOpen = false;
                        panel.calendarOpen = false;
                        panel.notificationsOpen = false;
                        panel.wallpaperOpen = false;
                        panel.trayOpen = false;
                        panel.sessionOpen = !panel.sessionOpen;
                    }
                }
            }

            BatteryTooltip {
                targetItem: batteryItem
                battery: panel.battery
                open: batteryMouseArea.containsMouse
            }

            ClockTooltip {
                targetItem: clockItem
                clock: systemClock
                open: clockMouseArea.containsMouse
            }

            AudioPopup {
                panelWindow: panel
                outputNode: panel.audioSink
                inputNode: panel.audioSource
                open: panel.audioOpen
                onCloseRequested: panel.audioOpen = false
            }

            CalendarPopup {
                panelWindow: panel
                clock: systemClock
                weatherLocation: shellRoot.weatherLocation.replace("_", " ")
                weatherText: shellRoot.weatherText
                open: panel.calendarOpen
                onRefreshWeatherRequested: shellRoot.refreshWeather()
                onCloseRequested: panel.calendarOpen = false
            }

            NotificationsPopup {
                panelWindow: panel
                server: notificationServer
                open: panel.notificationsOpen
                onCloseRequested: panel.notificationsOpen = false
            }

            WallpaperPopup {
                panelWindow: panel
                open: panel.wallpaperOpen
                onCloseRequested: panel.wallpaperOpen = false
            }

            SessionMenu {
                panelWindow: panel
                idleLockEnabled: shellRoot.idleLockEnabled
                open: panel.sessionOpen
                onLockRequested: {
                    panel.sessionOpen = false;
                    sessionLock.requestLock();
                }
                onToggleIdleRequested: shellRoot.idleLockEnabled = !shellRoot.idleLockEnabled
                onActionRequested: function(action) {
                    panel.sessionOpen = false;
                    if (action === "logout")
                        Quickshell.execDetached(["swaymsg", "exit"]);
                    else if (action === "suspend")
                        Quickshell.execDetached(["systemctl", "suspend"]);
                    else if (action === "reboot")
                        Quickshell.execDetached(["systemctl", "reboot"]);
                    else if (action === "shutdown")
                        Quickshell.execDetached(["systemctl", "poweroff"]);
                }
                onCloseRequested: panel.sessionOpen = false
            }

            TrayPopup {
                panelWindow: panel
                open: panel.trayOpen
                onCloseRequested: panel.trayOpen = false
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
