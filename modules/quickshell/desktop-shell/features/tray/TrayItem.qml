import QtQuick
import Quickshell
import Quickshell.Widgets
import "../../components" as UI

Item {
    id: root

    required property var trayItem
    property var panelWindow

    width: 28
    height: 28

    function iconSource(icon) {
        if (!icon)
            return "";

        if (icon.indexOf("?path=") !== -1) {
            const chunks = icon.split("?path=");
            const name = chunks[0];
            const path = chunks[1];
            const fileName = name.substring(name.lastIndexOf("/") + 1);
            return "file://" + path + "/" + fileName;
        }

        if (icon.indexOf("://") !== -1 || icon[0] === "/")
            return icon;

        return Quickshell.iconPath(icon) || icon;
    }

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: mouseArea.containsMouse ? UI.Theme.strongHover : "transparent"
    }

    IconImage {
        anchors.centerIn: parent
        width: 18
        height: 18
        asynchronous: true
        source: root.trayItem ? root.iconSource(root.trayItem.icon) : ""
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: function(mouse) {
            if (!root.trayItem)
                return;

            const position = root.panelWindow.itemPosition(root);
            if (mouse.button === Qt.LeftButton) {
                if (root.trayItem.onlyMenu && root.trayItem.hasMenu)
                    root.trayItem.display(root.panelWindow, position.x, root.panelWindow.height);
                else
                    root.trayItem.activate();
            } else if (mouse.button === Qt.MiddleButton) {
                root.trayItem.secondaryActivate();
            } else if (root.trayItem.hasMenu) {
                root.trayItem.display(root.panelWindow, position.x, root.panelWindow.height);
            }
        }
    }
}
