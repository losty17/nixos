import QtQuick

Item {
    id: root

    required property var workspace
    property string screenName: ""
    readonly property bool onScreen: root.workspace && root.workspace.monitor && root.workspace.monitor.name === root.screenName

    visible: onScreen
    implicitWidth: label.implicitWidth + 20
    width: visible ? implicitWidth : 0
    height: 28

    Rectangle {
        anchors.fill: parent
        color: root.workspace && root.workspace.focused ? "#774c81" : root.workspace && root.workspace.urgent ? "#900000" : "transparent"
    }

    Text {
        id: label

        anchors.centerIn: parent
        text: root.workspace ? root.workspace.name : ""
        color: root.workspace && (root.workspace.focused || root.workspace.urgent) ? "#ffffff" : "#666666"
        font.family: "Inter"
        font.pixelSize: 14
        font.weight: 600
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.onScreen
        cursorShape: Qt.PointingHandCursor
        onClicked: root.workspace.activate()
    }
}
