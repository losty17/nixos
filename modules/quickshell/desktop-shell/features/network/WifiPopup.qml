pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Networking
import "../../components" as UI

PopupWindow {
    id: root

    property var panelWindow
    property var wifiDevice
    property bool open: false
    property var pendingNetwork: null
    property bool passwordPrompt: false
    property string errorMessage: ""
    signal closeRequested()

    visible: open
    grabFocus: true
    color: "transparent"
    implicitWidth: 360
    implicitHeight: passwordPrompt ? 230 : 430

    anchor.window: panelWindow
    anchor.rect.x: panelWindow ? panelWindow.width - width - 4 : 0
    anchor.rect.y: panelWindow ? panelWindow.height + 4 : 0
    anchor.edges: Edges.Top | Edges.Left
    anchor.gravity: Edges.Bottom | Edges.Right
    anchor.adjustment: PopupAdjustment.All

    onVisibleChanged: {
        if (!visible) {
            if (wifiDevice)
                wifiDevice.scannerEnabled = false;
            if (open)
                root.closeRequested();
            passwordPrompt = false;
            pendingNetwork = null;
            errorMessage = "";
        } else if (wifiDevice) {
            wifiDevice.scannerEnabled = true;
        }
    }

    onPasswordPromptChanged: {
        if (passwordPrompt)
            passwordInput.forceActiveFocus();
    }

    function selectNetwork(network) {
        if (!network || network.stateChanging)
            return;

        errorMessage = "";
        pendingNetwork = network;

        if (network.known || network.security === WifiSecurityType.Open || network.security === WifiSecurityType.Owe) {
            network.connect();
            errorMessage = "Connecting...";
            return;
        }

        passwordInput.text = "";
        passwordPrompt = true;
    }

    function submitPassword() {
        if (!pendingNetwork || passwordInput.text.length === 0) {
            errorMessage = "Enter a password to continue.";
            return;
        }

        pendingNetwork.connectWithPsk(passwordInput.text);
        passwordPrompt = false;
        errorMessage = "Connecting...";
    }

    Connections {
        target: root.pendingNetwork

        function onConnectionFailed(reason) {
            root.errorMessage = "Could not connect. Check the password.";
            root.passwordPrompt = true;
            passwordInput.text = "";
        }
    }

    UI.PopupFrame {
        id: card

        anchors.fill: parent

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10
            visible: !root.passwordPrompt

            Row {
                width: parent.width
                height: 32
                spacing: 8

                Column {
                    id: headerContent

                    spacing: 2

                    Text {
                        text: "Wi-Fi"
                        color: UI.Theme.text
                        font.bold: true
                        font.pixelSize: 16
                    }

                    Text {
                        text: root.wifiDevice ? root.wifiDevice.name : "No adapter"
                        color: UI.Theme.mutedText
                        font.pixelSize: 11
                    }
                }

                Item {
                    width: parent.width - headerContent.width - refreshButton.width - 8
                    height: 1
                }

                UI.IconButton {
                    id: refreshButton

                    icon: "\uf021"
                    onClicked: if (root.wifiDevice) root.wifiDevice.scannerEnabled = true
                }
            }

            Rectangle {
                width: parent.width
                height: 36
                radius: 7
                color: UI.Theme.raised

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Wi-Fi"
                    color: UI.Theme.text
                    font.pixelSize: 13
                }

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: Networking.wifiEnabled ? "On" : "Off"
                    color: Networking.wifiEnabled ? UI.Theme.accentText : UI.Theme.mutedText
                    font.pixelSize: 12
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
                }
            }

            UI.Divider {
                width: parent.width
            }

            Row {
                width: parent.width
                height: 20

                Text {
                    id: nearbyTitle

                    text: "Nearby networks"
                    color: UI.Theme.text
                    font.bold: true
                    font.pixelSize: 13
                }

                Item {
                    width: parent.width - nearbyTitle.width - scanningLabel.width
                    height: 1
                }

                Text {
                    id: scanningLabel

                    text: root.wifiDevice && root.wifiDevice.scannerEnabled ? "Scanning..." : ""
                    color: UI.Theme.mutedText
                    font.pixelSize: 11
                }
            }

            Item {
                width: parent.width
                height: 245

                ListView {
                    anchors.fill: parent
                    spacing: 4
                    clip: true
                    model: root.wifiDevice ? root.wifiDevice.networks : null

                    delegate: WifiNetworkRow {
                        required property var modelData

                        network: modelData
                        onActivated: root.selectNetwork(network)
                    }
                }

                UI.EmptyState {
                    anchors.centerIn: parent
                    visible: !root.wifiDevice || root.wifiDevice.networks.values.length === 0
                    text: root.wifiDevice ? "No networks found" : "No Wi-Fi adapter"
                }
            }

            Text {
                width: parent.width
                visible: root.errorMessage.length > 0
                text: root.errorMessage
                color: root.errorMessage === "Connecting..." ? UI.Theme.accentText : UI.Theme.danger
                elide: Text.ElideRight
                font.pixelSize: 11
            }
        }

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
            visible: root.passwordPrompt

            Text {
                text: "Connect to Wi-Fi"
                color: UI.Theme.text
                font.bold: true
                font.pixelSize: 16
            }

            Text {
                width: parent.width
                text: root.pendingNetwork ? root.pendingNetwork.name : ""
                color: UI.Theme.mutedText
                elide: Text.ElideRight
                font.pixelSize: 12
            }

            Rectangle {
                width: parent.width
                height: 40
                radius: 7
                color: UI.Theme.raised
                border.width: passwordInput.activeFocus ? 1 : 0
                border.color: UI.Theme.accent

                TextInput {
                    id: passwordInput

                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    verticalAlignment: TextInput.AlignVCenter
                    color: UI.Theme.text
                    echoMode: TextInput.Password
                    font.pixelSize: 13
                    selectByMouse: true
                    focus: root.passwordPrompt
                    Keys.onReturnPressed: root.submitPassword()

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        visible: passwordInput.text.length === 0
                        text: "Password"
                        color: UI.Theme.subduedText
                        font.pixelSize: 13
                    }
                }
            }

            Text {
                width: parent.width
                visible: root.errorMessage.length > 0 && root.errorMessage !== "Connecting..."
                text: root.errorMessage
                color: UI.Theme.danger
                wrapMode: Text.WordWrap
                font.pixelSize: 11
            }

            Row {
                width: parent.width
                height: 36
                spacing: 8

                Item {
                    width: parent.width - cancelButton.width - connectButton.width - 8
                    height: 1
                }

                Rectangle {
                    id: cancelButton

                    width: 86
                    height: 36
                    radius: 7
                    color: cancelMouse.containsMouse ? UI.Theme.hover : UI.Theme.raised

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: UI.Theme.text
                        font.pixelSize: 12
                    }

                    MouseArea {
                        id: cancelMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.passwordPrompt = false
                    }
                }

                Rectangle {
                    id: connectButton

                    width: 86
                    height: 36
                    radius: 7
                    color: connectMouse.containsMouse ? UI.Theme.accentHover : UI.Theme.accent

                    Text {
                        anchors.centerIn: parent
                        text: "Connect"
                        color: UI.Theme.accentForeground
                        font.bold: true
                        font.pixelSize: 12
                    }

                    MouseArea {
                        id: connectMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.submitPassword()
                    }
                }
            }
        }
    }
}
