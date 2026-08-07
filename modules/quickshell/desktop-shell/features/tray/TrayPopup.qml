pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import "../../components" as UI

PopupWindow {
    id: root

    property Item targetItem
    property bool open: false
    readonly property var items: SystemTray.items && SystemTray.items.values ? SystemTray.items.values : []
    readonly property int columns: 4
    readonly property int rowCount: Math.max(1, Math.ceil(root.items.length / root.columns))
    signal closeRequested()

    visible: open
    grabFocus: true
    color: "transparent"
    implicitWidth: 140
    implicitHeight: root.items.length > 0 ? root.rowCount * 52 + (root.rowCount - 1) * 6 : 58

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
        shown: root.open

        Column {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

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
