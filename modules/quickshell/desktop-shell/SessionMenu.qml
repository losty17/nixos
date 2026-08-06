import QtQuick
import Quickshell

PopupWindow {
    id: root

    property var panelWindow
    property bool open: false
    property bool idleLockEnabled: true
    signal lockRequested()
    signal toggleIdleRequested()
    signal actionRequested(string action)
    signal closeRequested()

    visible: open
    grabFocus: true
    color: "transparent"
    implicitWidth: 260
    implicitHeight: 330

    anchor.window: panelWindow
    anchor.rect.x: panelWindow ? panelWindow.width - width - 4 : 0
    anchor.rect.y: panelWindow ? panelWindow.height + 4 : 0
    anchor.edges: Edges.Top | Edges.Left
    anchor.gravity: Edges.Bottom | Edges.Right
    anchor.adjustment: PopupAdjustment.All

    onVisibleChanged: {
        if (!visible && panelWindow)
            panelWindow.sessionOpen = false;
    }

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: "#14151a"
        border.width: 1
        border.color: "#30323b"

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 7

            Text {
                text: "Session"
                color: "#e6e8ee"
                font.bold: true
                font.pixelSize: 16
            }

            Text {
                text: "Power and session controls"
                color: "#8f94a3"
                font.pixelSize: 11
            }

            Rectangle { width: parent.width; height: 1; color: "#30323b" }

            Rectangle {
                width: parent.width
                height: 36
                radius: 7
                color: lockMouse.containsMouse ? "#2a202f" : "#1c1d22"

                Text { anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter; text: "\uf023  Lock screen"; color: "#e6e8ee"; font.pixelSize: 12 }
                MouseArea { id: lockMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.lockRequested() }
            }

            Rectangle {
                width: parent.width
                height: 36
                radius: 7
                color: idleMouse.containsMouse ? "#2a202f" : "#1c1d22"

                Text { anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter; text: "\uf2f2  Idle lock"; color: "#e6e8ee"; font.pixelSize: 12 }
                Text { anchors.right: parent.right; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter; text: root.idleLockEnabled ? "On" : "Off"; color: root.idleLockEnabled ? "#d8b8e3" : "#8f94a3"; font.pixelSize: 11 }
                MouseArea { id: idleMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.toggleIdleRequested() }
            }

            Rectangle {
                width: parent.width
                height: 36
                radius: 7
                color: logoutMouse.containsMouse ? "#2a202f" : "#1c1d22"

                Text { anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter; text: "\uf08b  Log out"; color: "#e6e8ee"; font.pixelSize: 12 }
                MouseArea { id: logoutMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.actionRequested("logout") }
            }

            Rectangle {
                width: parent.width
                height: 36
                radius: 7
                color: suspendMouse.containsMouse ? "#2a202f" : "#1c1d22"

                Text { anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter; text: "\uf4b3  Suspend"; color: "#e6e8ee"; font.pixelSize: 12 }
                MouseArea { id: suspendMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.actionRequested("suspend") }
            }

            Row {
                width: parent.width
                height: 36
                spacing: 7

                Rectangle {
                    width: (parent.width - 7) / 2
                    height: 36
                    radius: 7
                    color: rebootMouse.containsMouse ? "#2a202f" : "#1c1d22"
                    Text { anchors.centerIn: parent; text: "\uf021  Reboot"; color: "#e6e8ee"; font.pixelSize: 11 }
                    MouseArea { id: rebootMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.actionRequested("reboot") }
                }

                Rectangle {
                    width: (parent.width - 7) / 2
                    height: 36
                    radius: 7
                    color: shutdownMouse.containsMouse ? "#7b3038" : "#4c2028"
                    Text { anchors.centerIn: parent; text: "\uf011  Shut down"; color: "#ffffff"; font.pixelSize: 11 }
                    MouseArea { id: shutdownMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.actionRequested("shutdown") }
                }
            }
        }
    }
}
