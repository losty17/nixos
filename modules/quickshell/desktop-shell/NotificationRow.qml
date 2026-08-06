pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets

Item {
    id: root

    required property var notification
    property bool hasActions: notification && notification.actions && notification.actions.length > 0

    width: ListView.view ? ListView.view.width : 0
    height: hasActions ? 126 : 88

    function iconSource(icon) {
        if (!icon)
            return "";
        if (icon.indexOf("://") !== -1 || icon[0] === "/")
            return icon;
        return Quickshell.iconPath(icon) || icon;
    }

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: mouseArea.containsMouse ? "#2a202f" : "#1c1d22"
    }

    IconImage {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.top: parent.top
        anchors.topMargin: 12
        width: 28
        height: 28
        asynchronous: true
        source: root.notification ? root.iconSource(root.notification.image || root.notification.appIcon) : ""
    }

    Column {
        anchors.left: parent.left
        anchors.leftMargin: 52
        anchors.right: dismissButton.left
        anchors.rightMargin: 8
        anchors.top: parent.top
        anchors.topMargin: 10
        spacing: 3

        Text {
            width: parent.width
            text: root.notification ? (root.notification.appName || "Notification") : ""
            color: "#8f94a3"
            elide: Text.ElideRight
            font.pixelSize: 10
        }

        Text {
            width: parent.width
            text: root.notification ? root.notification.summary : ""
            color: "#e6e8ee"
            elide: Text.ElideRight
            font.bold: true
            font.pixelSize: 12
        }

        Text {
            width: parent.width
            text: root.notification ? root.notification.body : ""
            color: "#c7cad4"
            elide: Text.ElideRight
            maximumLineCount: 2
            wrapMode: Text.Wrap
            textFormat: Text.PlainText
            font.pixelSize: 11
        }
    }

    ConnectivityButton {
        id: dismissButton

        anchors.right: parent.right
        anchors.rightMargin: 6
        anchors.top: parent.top
        anchors.topMargin: 6
        icon: "\uf00d"
        onClicked: if (root.notification) root.notification.dismiss()
    }

    Row {
        id: actionRow

        anchors.left: parent.left
        anchors.leftMargin: 52
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        spacing: 4
        visible: root.hasActions

        Repeater {
            model: root.notification ? root.notification.actions : []

            delegate: Rectangle {
                required property var modelData

                width: Math.min(120, Math.max(58, actionLabel.implicitWidth + 18))
                height: 24
                radius: 5
                color: actionMouse.containsMouse ? "#774c81" : "#30323b"

                Text {
                    id: actionLabel

                    anchors.centerIn: parent
                    text: modelData.text
                    color: "#e6e8ee"
                    elide: Text.ElideRight
                    font.pixelSize: 10
                }

                MouseArea {
                    id: actionMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: modelData.invoke()
                }
            }
        }
    }

    MouseArea {
        id: mouseArea

        anchors.left: parent.left
        anchors.right: dismissButton.left
        anchors.rightMargin: 4
        anchors.top: parent.top
        anchors.bottom: root.hasActions ? actionRow.top : parent.bottom
        anchors.bottomMargin: root.hasActions ? 4 : 0
        hoverEnabled: true
        onClicked: function(mouse) {
            if (root.notification && mouse.button === Qt.LeftButton)
                root.notification.dismiss();
        }
    }
}
