import QtQuick

Item {
    id: root

    property var network
    signal activated()

    width: ListView.view ? ListView.view.width : 0
    height: 48

    Rectangle {
        anchors.fill: parent
        radius: 7
        color: mouseArea.containsMouse ? "#2a202f" : root.network && root.network.connected ? "#201d2a" : "#1c1d22"
        border.width: root.network && root.network.connected ? 1 : 0
        border.color: "#774c81"
    }

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        text: "\uf1eb"
        color: root.network && root.network.connected ? "#d8b8e3" : "#8f94a3"
        font.family: "Symbols Nerd Font"
        font.pixelSize: 15
    }

    Column {
        anchors.left: parent.left
        anchors.leftMargin: 38
        anchors.right: signalLabel.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Text {
            width: parent.width
            text: root.network ? root.network.name : ""
            color: "#e6e8ee"
            elide: Text.ElideRight
            font.pixelSize: 13
        }

        Text {
            text: root.network && root.network.connected ? "Connected" : root.network && root.network.known ? "Saved network" : "Password required"
            color: "#8f94a3"
            font.pixelSize: 11
        }
    }

    Text {
        id: signalLabel

        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        text: root.network ? Math.round(root.network.signalStrength * 100) + "%" : ""
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
