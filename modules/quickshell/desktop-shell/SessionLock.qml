import QtQuick
import Quickshell
import Quickshell.Services.Pam
import Quickshell.Wayland

Item {
    id: root

    property var clock
    property bool locked: false
    property string pendingPassword: ""
    property string errorMessage: ""

    function requestLock() {
        root.errorMessage = "";
        root.pendingPassword = "";
        root.locked = true;
    }

    function authenticate(password) {
        if (pam.active)
            pam.abort();
        root.pendingPassword = password;
        root.errorMessage = "Authenticating...";
        if (!pam.start())
            root.errorMessage = "Unable to start authentication";
        else if (pam.responseRequired)
            pam.respond(root.pendingPassword);
    }

    onLockedChanged: {
        if (locked) {
            root.errorMessage = "";
            root.pendingPassword = "";
        } else if (pam.active) {
            pam.abort();
        }
    }

    PamContext {
        id: pam

        config: "login"
        user: Quickshell.env("USER")
    }

    Connections {
        target: pam

        function onPamMessage() {
            if (pam.responseRequired)
                pam.respond(root.pendingPassword);
        }

        function onCompleted(result) {
            if (result === PamResult.Success) {
                root.errorMessage = "";
                root.locked = false;
            } else {
                root.pendingPassword = "";
                root.errorMessage = "Incorrect password";
            }
        }

        function onError() {
            root.errorMessage = pam.message || "Authentication error";
        }
    }

    WlSessionLock {
        id: sessionLock

        locked: root.locked

        surface: Component {
            WlSessionLockSurface {
                color: "#0a0a0a"

                Rectangle {
                    anchors.fill: parent
                    color: "#0a0a0a"

                    Column {
                        anchors.centerIn: parent
                        width: Math.min(360, parent.width - 40)
                        spacing: 12

                        Text {
                            width: parent.width
                            text: "Session locked"
                            color: "#e6e8ee"
                            horizontalAlignment: Text.AlignHCenter
                            font.bold: true
                            font.pixelSize: 28
                        }

                        Text {
                            width: parent.width
                            text: root.clock ? Qt.formatDateTime(root.clock.date, "dddd, MMMM d, yyyy | HH:mm:ss") : ""
                            color: "#8f94a3"
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 13
                        }

                        Rectangle {
                            width: parent.width
                            height: 42
                            radius: 8
                            color: "#1c1d22"
                            border.width: passwordInput.activeFocus ? 1 : 0
                            border.color: "#774c81"

                            TextInput {
                                id: passwordInput

                                anchors.fill: parent
                                anchors.leftMargin: 14
                                anchors.rightMargin: 14
                                verticalAlignment: TextInput.AlignVCenter
                                color: "#e6e8ee"
                                echoMode: TextInput.Password
                                font.pixelSize: 13
                                focus: true
                                Keys.onReturnPressed: {
                                    root.authenticate(text);
                                    text = "";
                                }

                                Text {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    visible: passwordInput.text.length === 0
                                    text: "Password"
                                    color: "#666b78"
                                    font.pixelSize: 13
                                }
                            }
                        }

                        Text {
                            width: parent.width
                            text: root.errorMessage
                            color: root.errorMessage === "Authenticating..." ? "#d8b8e3" : "#e06c75"
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.Wrap
                            font.pixelSize: 11
                        }

                        Text {
                            width: parent.width
                            text: "Press Enter to unlock"
                            color: "#666b78"
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 11
                        }
                    }
                }

                Component.onCompleted: passwordInput.forceActiveFocus()
            }
        }
    }
}
