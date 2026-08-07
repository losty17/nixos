import QtQuick
import Quickshell
import "../components" as UI

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

    UI.PopupFrame {
        anchors.fill: parent
        radius: UI.Theme.tooltipRadius
        shown: root.open

        Text {
            anchors.centerIn: parent
            text: root.clock ? Qt.formatTime(root.clock.date, "HH:mm:ss") : ""
            color: UI.Theme.text
            font.pixelSize: 12
        }
    }
}
