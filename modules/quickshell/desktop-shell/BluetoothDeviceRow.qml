import QtQuick

Item {
    id: root

    property var device
    signal activated()

    width: ListView.view ? ListView.view.width : 0
    height: 48

    Rectangle {
        anchors.fill: parent
        radius: 7
        color: mouseArea.containsMouse ? "#2a202f" : root.device && root.device.connected ? "#201d2a" : "#1c1d22"
        border.width: root.device && root.device.connected ? 1 : 0
        border.color: "#774c81"
    }

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        text: "\uf294"
        color: root.device && root.device.connected ? "#d8b8e3" : "#8f94a3"
        font.family: "Symbols Nerd Font"
        font.pixelSize: 15
    }

    Column {
        anchors.left: parent.left
        anchors.leftMargin: 38
        anchors.right: statusLabel.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Text {
            width: parent.width
            text: root.device ? root.device.name : ""
            color: "#e6e8ee"
            elide: Text.ElideRight
            font.pixelSize: 13
        }

        Text {
            text: root.device && root.device.connected ? "Connected" : "Paired device"
            color: "#8f94a3"
            font.pixelSize: 11
        }
    }

    Text {
        id: statusLabel

        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        text: root.device && root.device.batteryAvailable ? Math.round(root.device.battery * 100) + "%" : root.device && root.device.connected ? "On" : "Off"
        color: "#8f94a3"
        font.pixelSize: 11
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
