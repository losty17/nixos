pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../components" as UI

PopupWindow {
    id: root

    property Item targetItem
    property var adapter
    property bool open: false
    signal closeRequested()

    visible: open
    grabFocus: true
    color: "transparent"
    implicitWidth: 360
    implicitHeight: 360

    anchor.item: root.targetItem
    anchor.rect.x: root.targetItem ? root.targetItem.width - width : 0
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
            spacing: 10

            Row {
                width: parent.width
                height: 32

                Column {
                    id: headerContent

                    spacing: 2

                    Text {
                        text: "Bluetooth"
                        color: UI.Theme.text
                        font.bold: true
                        font.pixelSize: 16
                    }

                    Text {
                        text: root.adapter ? root.adapter.name : "No adapter"
                        color: UI.Theme.mutedText
                        font.pixelSize: 11
                    }
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
                    text: "Bluetooth"
                    color: UI.Theme.text
                    font.pixelSize: 13
                }

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.adapter && root.adapter.enabled ? "On" : "Off"
                    color: root.adapter && root.adapter.enabled ? UI.Theme.accentText : UI.Theme.mutedText
                    font.pixelSize: 12
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: !!root.adapter
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.adapter.enabled = !root.adapter.enabled
                }
            }

            UI.Divider {
                width: parent.width
            }

            Row {
                width: parent.width
                height: 20

                Text {
                    id: devicesTitle

                    text: "Connected devices"
                    color: UI.Theme.text
                    font.bold: true
                    font.pixelSize: 13
                }

                Item {
                    width: parent.width - devicesTitle.width - scanningLabel.width
                    height: 1
                }

                Text {
                    id: scanningLabel

                    text: root.adapter && root.adapter.discovering ? "Scanning..." : ""
                    color: UI.Theme.mutedText
                    font.pixelSize: 11
                }
            }

            Item {
                width: parent.width
                height: 205

                ListView {
                    anchors.fill: parent
                    spacing: 4
                    clip: true
                    model: root.adapter ? root.adapter.devices : null

                    delegate: BluetoothDeviceRow {
                        required property var modelData

                        device: modelData
                        onActivated: {
                            if (device.connected)
                                device.disconnect();
                            else
                                device.connect();
                        }
                    }
                }

                UI.EmptyState {
                    anchors.centerIn: parent
                    visible: !root.adapter || root.adapter.devices.values.length === 0
                    text: root.adapter ? "No connected devices" : "No Bluetooth adapter"
                }
            }

            Text {
                width: parent.width
                text: "Pairing and discovery are handled by BlueZ."
                color: UI.Theme.subduedText
                elide: Text.ElideRight
                font.pixelSize: 11
            }
        }
    }
}
