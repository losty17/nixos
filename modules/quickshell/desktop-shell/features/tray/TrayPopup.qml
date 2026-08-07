pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import "../../components" as UI

PopupWindow {
    id: root

    property var panelWindow
    property bool open: false
    readonly property var items: SystemTray.items && SystemTray.items.values ? SystemTray.items.values : []
    readonly property int columns: 4
    readonly property int rowCount: Math.max(1, Math.ceil(root.items.length / root.columns))
    signal closeRequested()

    visible: open
    grabFocus: true
    color: "transparent"
    implicitWidth: 280
    implicitHeight: root.items.length > 0 ? 78 + root.rowCount * 52 + (root.rowCount - 1) * 6 : 108

    anchor.window: panelWindow
    anchor.rect.x: panelWindow ? panelWindow.width - width - 4 : 0
    anchor.rect.y: panelWindow ? panelWindow.height + 4 : 0
    anchor.edges: Edges.Top | Edges.Left
    anchor.gravity: Edges.Bottom | Edges.Right
    anchor.adjustment: PopupAdjustment.All

    onVisibleChanged: {
        if (!visible && open)
            root.closeRequested();
    }

    UI.PopupFrame {
        anchors.fill: parent

        Column {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            Row {
                width: parent.width
                height: 26
                spacing: 8

                Text {
                    text: "System tray"
                    color: UI.Theme.text
                    font.bold: true
                    font.pixelSize: 16
                }

                Item {
                    width: parent.width - parent.children[0].width - itemCount.width - 8
                    height: 1
                }

                Text {
                    id: itemCount

                    text: String(root.items.length)
                    color: UI.Theme.mutedText
                    font.pixelSize: 11
                    verticalAlignment: Text.AlignVCenter
                }
            }

            UI.Divider {
                width: parent.width
            }

            Item {
                width: parent.width
                height: root.items.length > 0 ? root.rowCount * 52 + (root.rowCount - 1) * 6 : 32

                Grid {
                    id: trayGrid

                    anchors.fill: parent
                    columns: root.columns
                    columnSpacing: 6
                    rowSpacing: 6

                    Repeater {
                        model: root.items

                        delegate: Item {
                            required property var modelData

                            width: (trayGrid.width - (root.columns - 1) * trayGrid.columnSpacing) / root.columns
                            height: 52

                            Rectangle {
                                anchors.fill: parent
                                radius: 7
                                color: trayMouseArea.containsMouse ? UI.Theme.strongHover : "transparent"
                            }

                            TrayItem {
                                id: trayIcon

                                anchors.top: parent.top
                                anchors.topMargin: 3
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 32
                                height: 32
                                trayItem: modelData
                                panelWindow: root
                            }

                            Text {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 3
                                text: modelData ? (modelData.tooltipTitle || modelData.title || "Tray item") : "Tray item"
                                color: UI.Theme.secondaryText
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                                font.pixelSize: 9
                            }

                            MouseArea {
                                id: trayMouseArea

                                anchors.fill: parent
                                acceptedButtons: Qt.NoButton
                                hoverEnabled: true
                            }
                        }
                    }
                }

                UI.EmptyState {
                    anchors.centerIn: parent
                    visible: root.items.length === 0
                    text: "No tray items"
                }
            }
        }
    }
}
