pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets
import "../../components" as UI

PopupWindow {
    id: root

    property Item targetItem
    property var notifications: []
    property bool open: false
    readonly property int notificationHeight: 112
    readonly property int notificationSpacing: 8
    signal dismissRequested(notification: var)

    visible: root.open && root.notifications.length > 0
    grabFocus: false
    color: "transparent"
    implicitWidth: 360
    implicitHeight: Math.max(1, root.notifications.length * root.notificationHeight + Math.max(0, root.notifications.length - 1) * root.notificationSpacing)

    anchor.item: root.targetItem
    anchor.rect.x: root.targetItem ? root.targetItem.width - width : 0
    anchor.rect.y: root.targetItem ? root.targetItem.height + 4 : 0
    anchor.adjustment: PopupAdjustment.All

    function iconSource(icon) {
        if (!icon)
            return "";
        if (icon.indexOf("://") !== -1 || icon[0] === "/")
            return icon;
        return Quickshell.iconPath(icon) || icon;
    }

    Column {
        anchors.fill: parent
        spacing: root.notificationSpacing

        Repeater {
            model: root.notifications

            delegate: UI.PopupFrame {
                id: notificationFrame

                required property var modelData

                width: root.width
                height: root.notificationHeight

                Timer {
                    interval: Math.max(1, notificationFrame.modelData.expiresAt - Date.now())
                    running: true
                    onTriggered: root.dismissRequested(notificationFrame.modelData.notification)
                }

                IconImage {
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.top: parent.top
                    anchors.topMargin: 16
                    width: 32
                    height: 32
                    asynchronous: true
                    source: notificationFrame.modelData.notification ? root.iconSource(notificationFrame.modelData.notification.image || notificationFrame.modelData.notification.appIcon) : ""
                }

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: 60
                    anchors.right: dismissButton.left
                    anchors.rightMargin: 8
                    anchors.top: parent.top
                    anchors.topMargin: 14
                    spacing: 4

                    Text {
                        width: parent.width
                        text: notificationFrame.modelData.notification ? (notificationFrame.modelData.notification.appName || "Notification") : ""
                        color: UI.Theme.mutedText
                        elide: Text.ElideRight
                        font.pixelSize: 11
                    }

                    Text {
                        width: parent.width
                        text: notificationFrame.modelData.notification ? notificationFrame.modelData.notification.summary : ""
                        color: UI.Theme.text
                        elide: Text.ElideRight
                        font.bold: true
                        font.pixelSize: 13
                    }

                    Text {
                        width: parent.width
                        text: notificationFrame.modelData.notification ? notificationFrame.modelData.notification.body : ""
                        color: UI.Theme.secondaryText
                        elide: Text.ElideRight
                        maximumLineCount: 2
                        wrapMode: Text.Wrap
                        textFormat: Text.PlainText
                        font.pixelSize: 11
                    }
                }

                UI.IconButton {
                    id: dismissButton

                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    icon: "\uf00d"
                    onClicked: root.dismissRequested(notificationFrame.modelData.notification)
                }
            }
        }
    }
}
