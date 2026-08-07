import QtQuick
import Quickshell
import Quickshell.Services.UPower
import "../components" as UI

PopupWindow {
    id: root

    required property Item targetItem
    required property var battery
    property bool open: false

    visible: root.open && root.battery && root.battery.ready
    color: "transparent"
    implicitWidth: 142
    implicitHeight: 48

    anchor.item: root.targetItem
    anchor.rect.x: root.targetItem ? (root.targetItem.width - root.width) / 2 : 0
    anchor.rect.y: root.targetItem ? root.targetItem.height + 4 : 0
    anchor.adjustment: PopupAdjustment.All

    UI.PopupFrame {
        anchors.fill: parent
        radius: UI.Theme.tooltipRadius

        Column {
            anchors.centerIn: parent
            spacing: 2

            Text {
                text: root.battery ? "State: " + UPowerDeviceState.toString(root.battery.state) : "State: Unknown"
                color: UI.Theme.accentText
                font.pixelSize: 11
            }

            Text {
                text: root.battery ? "Charge: " + Math.round(root.battery.percentage * 100) + "%" : "Charge: Unknown"
                color: UI.Theme.text
                font.pixelSize: 12
            }
        }
    }
}
