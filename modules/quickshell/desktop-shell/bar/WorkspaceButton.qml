import QtQuick
import Quickshell
import Quickshell.Widgets
import "../components" as UI

Item {
    id: root

    required property var workspace
    property string screenName: ""
    property var applications: []
    readonly property bool onScreen: root.workspace && root.workspace.monitor && root.workspace.monitor.name === root.screenName

    visible: onScreen
    implicitWidth: label.implicitWidth + appIcons.width + 24
    width: visible ? implicitWidth : 0
    height: 28

    Rectangle {
        anchors.fill: parent
        color: root.workspace && root.workspace.focused ? UI.Theme.accent : root.workspace && root.workspace.urgent ? UI.Theme.urgent : "transparent"
    }

    Text {
        id: label

        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        text: root.workspace ? root.workspace.name : ""
        color: root.workspace && (root.workspace.focused || root.workspace.urgent) ? UI.Theme.accentForeground : UI.Theme.subduedText
        font.family: UI.Theme.textFont
        font.pixelSize: 14
        font.weight: 600
    }

    Row {
        id: appIcons

        anchors.left: label.right
        anchors.leftMargin: 5
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Repeater {
            model: root.applications

            delegate: Item {
                required property var modelData

                width: 16
                height: 16

                function iconSource() {
                    const appId = modelData && modelData.appId ? modelData.appId : "";
                    const className = modelData && modelData.className ? modelData.className : "";
                    const appIdLower = appId.toLowerCase();
                    const classNameLower = className.toLowerCase();
                    function themed(name) {
                        return name && Quickshell.hasThemeIcon(name) ? Quickshell.iconPath(name) : "";
                    }
                    return themed(appId)
                        || themed(appIdLower)
                        || themed(className)
                        || themed(classNameLower)
                        || "";
                }

                IconImage {
                    anchors.fill: parent
                    asynchronous: true
                    source: parent.iconSource()
                }

                Text {
                    anchors.centerIn: parent
                    visible: parent.children[0].source.length === 0
                    text: modelData && (modelData.appId || modelData.className) ? (modelData.appId || modelData.className).substring(0, 1).toUpperCase() : "?"
                    color: UI.Theme.mutedText
                    font.pixelSize: 9
                    font.bold: true
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.onScreen
        cursorShape: Qt.PointingHandCursor
        onClicked: root.workspace.activate()
    }
}
