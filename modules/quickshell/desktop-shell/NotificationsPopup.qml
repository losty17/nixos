pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

PopupWindow {
    id: root

    property var panelWindow
    property var server
    property bool open: false
    signal closeRequested()

    visible: open
    grabFocus: true
    color: "transparent"
    implicitWidth: 380
    implicitHeight: 470

    anchor.window: panelWindow
    anchor.rect.x: panelWindow ? panelWindow.width - width - 4 : 0
    anchor.rect.y: panelWindow ? panelWindow.height + 4 : 0
    anchor.edges: Edges.Top | Edges.Left
    anchor.gravity: Edges.Bottom | Edges.Right
    anchor.adjustment: PopupAdjustment.All

    function clearAll() {
        if (!root.server || !root.server.trackedNotifications)
            return;
        const values = root.server.trackedNotifications.values;
        for (let i = values.length - 1; i >= 0; --i)
            values[i].dismiss();
    }

    onVisibleChanged: {
        if (!visible && panelWindow && panelWindow.notificationsOpen)
            panelWindow.notificationsOpen = false;
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
            spacing: 10

            Row {
                width: parent.width
                height: 30

                Text {
                    text: "Notifications"
                    color: "#e6e8ee"
                    font.bold: true
                    font.pixelSize: 16
                }

                Item {
                    width: parent.width - clearButton.width - 8 - parent.children[0].width
                    height: 1
                }

                ConnectivityButton {
                    id: clearButton

                    icon: "\uf1f8"
                    onClicked: root.clearAll()
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: "#30323b"
            }

            Item {
                width: parent.width
                height: 370

                ListView {
                    anchors.fill: parent
                    spacing: 5
                    clip: true
                    model: root.server ? root.server.trackedNotifications : null

                    delegate: NotificationRow {
                        required property var modelData

                        notification: modelData
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: !root.server || !root.server.trackedNotifications || root.server.trackedNotifications.values.length === 0
                    text: "No notifications"
                    color: "#8f94a3"
                    font.pixelSize: 12
                }
            }
        }
    }
}
