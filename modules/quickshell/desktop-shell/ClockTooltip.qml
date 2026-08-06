import QtQuick
import Quickshell

PopupWindow {
    id: root

    required property Item targetItem
    required property var clock
    property bool open: false

    visible: root.open && !!root.clock
    color: "transparent"
    implicitWidth: 82
    implicitHeight: 32

    anchor.item: root.targetItem
    anchor.rect.x: root.targetItem ? (root.targetItem.width - root.width) / 2 : 0
    anchor.rect.y: root.targetItem ? root.targetItem.height + 4 : 0
    anchor.adjustment: PopupAdjustment.All

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: "#14151a"
        border.width: 1
        border.color: "#30323b"

        Text {
            anchors.centerIn: parent
            text: root.clock ? Qt.formatTime(root.clock.date, "HH:mm:ss") : ""
            color: "#e6e8ee"
            font.pixelSize: 12
        }
    }
}
