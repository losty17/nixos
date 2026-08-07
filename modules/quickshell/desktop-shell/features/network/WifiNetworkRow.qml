import QtQuick
import "../../components" as UI

Item {
    id: root

    property var network
    signal activated()

    width: ListView.view ? ListView.view.width : 0
    height: 48

    Rectangle {
        anchors.fill: parent
        radius: 7
        color: mouseArea.containsMouse ? UI.Theme.hover : root.network && root.network.connected ? UI.Theme.selected : UI.Theme.raised
        border.width: root.network && root.network.connected ? 1 : 0
        border.color: UI.Theme.accent
    }

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        text: "\uf1eb"
        color: root.network && root.network.connected ? UI.Theme.accentText : UI.Theme.mutedText
        font.family: UI.Theme.iconFont
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
            color: UI.Theme.text
            elide: Text.ElideRight
            font.pixelSize: 13
        }

        Text {
            text: root.network && root.network.connected ? "Connected" : root.network && root.network.known ? "Saved network" : "Password required"
            color: UI.Theme.mutedText
            font.pixelSize: 11
        }
    }

    Text {
        id: signalLabel

        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        text: root.network ? Math.round(root.network.signalStrength * 100) + "%" : ""
        color: UI.Theme.mutedText
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
