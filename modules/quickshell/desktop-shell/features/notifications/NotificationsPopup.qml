pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../components" as UI

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
        if (!visible && open)
            root.closeRequested();
    }

    UI.PopupFrame {
        anchors.fill: parent

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10

            Row {
                width: parent.width
                height: 30

                Text {
                    text: "Notifications"
                    color: UI.Theme.text
                    font.bold: true
                    font.pixelSize: 16
                }

                Item {
                    width: parent.width - clearButton.width - 8 - parent.children[0].width
                    height: 1
                }

                UI.IconButton {
                    id: clearButton

                    icon: "\uf1f8"
                    onClicked: root.clearAll()
                }
            }

            UI.Divider {
                width: parent.width
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

                UI.EmptyState {
                    anchors.centerIn: parent
                    visible: !root.server || !root.server.trackedNotifications || root.server.trackedNotifications.values.length === 0
                    text: "No notifications"
                }
            }
        }
    }
}
