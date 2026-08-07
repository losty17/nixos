import QtQuick
import Quickshell
import "../../components" as UI

PopupWindow {
    id: root

    property Item targetItem
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

    anchor.item: root.targetItem
    anchor.rect.x: 0
    anchor.rect.y: root.targetItem ? root.targetItem.height + 4 : 0
    anchor.adjustment: PopupAdjustment.All

    onVisibleChanged: {
        if (!visible)
            Qt.callLater(function() {
                if (!root.visible && root.open)
                    root.closeRequested();
            });
    }

    UI.PopupFrame {
        anchors.fill: parent

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 7

            Text {
                text: "Session"
                color: UI.Theme.text
                font.bold: true
                font.pixelSize: 16
            }

            Text {
                text: "Power and session controls"
                color: UI.Theme.mutedText
                font.pixelSize: 11
            }

            UI.Divider { width: parent.width }

            Rectangle {
                width: parent.width
                height: 36
                radius: 7
                color: lockMouse.containsMouse ? UI.Theme.hover : UI.Theme.raised

                Text { anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter; text: "\uf023  Lock screen"; color: UI.Theme.text; font.pixelSize: 12 }
                MouseArea { id: lockMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.lockRequested() }
            }

            Rectangle {
                width: parent.width
                height: 36
                radius: 7
                color: idleMouse.containsMouse ? UI.Theme.hover : UI.Theme.raised

                Text { anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter; text: "\uf2f2  Idle lock"; color: UI.Theme.text; font.pixelSize: 12 }
                Text { anchors.right: parent.right; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter; text: root.idleLockEnabled ? "On" : "Off"; color: root.idleLockEnabled ? UI.Theme.accentText : UI.Theme.mutedText; font.pixelSize: 11 }
                MouseArea { id: idleMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.toggleIdleRequested() }
            }

            Rectangle {
                width: parent.width
                height: 36
                radius: 7
                color: logoutMouse.containsMouse ? UI.Theme.hover : UI.Theme.raised

                Text { anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter; text: "\uf08b  Log out"; color: UI.Theme.text; font.pixelSize: 12 }
                MouseArea { id: logoutMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.actionRequested("logout") }
            }

            Rectangle {
                width: parent.width
                height: 36
                radius: 7
                color: suspendMouse.containsMouse ? UI.Theme.hover : UI.Theme.raised

                Text { anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter; text: "\uf4b3  Suspend"; color: UI.Theme.text; font.pixelSize: 12 }
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
                    color: rebootMouse.containsMouse ? UI.Theme.hover : UI.Theme.raised
                    Text { anchors.centerIn: parent; text: "\uf021  Reboot"; color: UI.Theme.text; font.pixelSize: 11 }
                    MouseArea { id: rebootMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.actionRequested("reboot") }
                }

                Rectangle {
                    width: (parent.width - 7) / 2
                    height: 36
                    radius: 7
                    color: shutdownMouse.containsMouse ? UI.Theme.dangerHover : UI.Theme.dangerSurface
                    Text { anchors.centerIn: parent; text: "\uf011  Shut down"; color: UI.Theme.accentForeground; font.pixelSize: 11 }
                    MouseArea { id: shutdownMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.actionRequested("shutdown") }
                }
            }
        }
    }
}
