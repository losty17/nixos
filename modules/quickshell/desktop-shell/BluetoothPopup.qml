pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

PopupWindow {
    id: root

    property var panelWindow
    property var adapter
    property bool open: false
    signal closeRequested()

    visible: open
    grabFocus: true
    color: "transparent"
    implicitWidth: 360
    implicitHeight: 360

    anchor.window: panelWindow
    anchor.rect.x: panelWindow ? panelWindow.width - width - 4 : 0
    anchor.rect.y: panelWindow ? panelWindow.height + 4 : 0
    anchor.edges: Edges.Top | Edges.Left
    anchor.gravity: Edges.Bottom | Edges.Right
    anchor.adjustment: PopupAdjustment.All

    onVisibleChanged: {
        if (!visible && panelWindow && panelWindow.bluetoothOpen)
            panelWindow.bluetoothOpen = false;
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
                height: 32

                Column {
                    id: headerContent

                    spacing: 2

                    Text {
                        text: "Bluetooth"
                        color: "#e6e8ee"
                        font.bold: true
                        font.pixelSize: 16
                    }

                    Text {
                        text: root.adapter ? root.adapter.name : "No adapter"
                        color: "#8f94a3"
                        font.pixelSize: 11
                    }
                }

            }

            Rectangle {
                width: parent.width
                height: 36
                radius: 7
                color: "#1c1d22"

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Bluetooth"
                    color: "#e6e8ee"
                    font.pixelSize: 13
                }

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.adapter && root.adapter.enabled ? "On" : "Off"
                    color: root.adapter && root.adapter.enabled ? "#d8b8e3" : "#8f94a3"
                    font.pixelSize: 12
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: !!root.adapter
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.adapter.enabled = !root.adapter.enabled
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: "#30323b"
            }

            Row {
                width: parent.width
                height: 20

                Text {
                    id: devicesTitle

                    text: "Connected devices"
                    color: "#e6e8ee"
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
                    color: "#8f94a3"
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

                Text {
                    anchors.centerIn: parent
                    visible: !root.adapter || root.adapter.devices.values.length === 0
                    text: root.adapter ? "No connected devices" : "No Bluetooth adapter"
                    color: "#8f94a3"
                    font.pixelSize: 12
                }
            }

            Text {
                width: parent.width
                text: "Pairing and discovery are handled by BlueZ."
                color: "#666b78"
                elide: Text.ElideRight
                font.pixelSize: 11
            }
        }
    }
}
