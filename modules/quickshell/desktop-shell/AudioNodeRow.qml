import QtQuick

Item {
    id: root

    required property var node
    property string role: "stream"
    property bool selected: false
    signal activated()

    width: ListView.view ? ListView.view.width : 0
    height: 58

    function volume() {
        return root.node && root.node.audio ? Math.max(0, Math.min(1, root.node.audio.volume)) : 0;
    }

    function displayName() {
        if (!root.node)
            return "Unknown device";
        return root.node.description || root.node.nickname || root.node.name || "Unknown device";
    }

    Rectangle {
        anchors.fill: parent
        radius: 7
        color: root.selected ? "#201d2a" : mouseArea.containsMouse ? "#2a202f" : "#1c1d22"
        border.width: root.selected ? 1 : 0
        border.color: "#774c81"
    }

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.top: parent.top
        anchors.topMargin: 8
        text: root.role === "sink" ? "\uf028" : root.role === "source" ? "\uf130" : "\uf1d8"
        color: root.selected ? "#d8b8e3" : "#8f94a3"
        font.family: "Symbols Nerd Font"
        font.pixelSize: 15
    }

    Column {
        anchors.left: parent.left
        anchors.leftMargin: 38
        anchors.right: levelLabel.left
        anchors.rightMargin: 8
        anchors.top: parent.top
        anchors.topMargin: 7
        spacing: 1

        Text {
            width: parent.width
            text: root.displayName()
            color: "#e6e8ee"
            elide: Text.ElideRight
            font.pixelSize: 12
        }

        Text {
            text: root.role === "sink" ? "Output" : root.role === "source" ? "Input" : "Application stream"
            color: "#8f94a3"
            font.pixelSize: 10
        }
    }

    Text {
        id: levelLabel

        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.top: parent.top
        anchors.topMargin: 9
        text: root.node && root.node.audio && root.node.audio.muted ? "Muted" : Math.round(root.volume() * 100) + "%"
        color: root.node && root.node.audio && root.node.audio.muted ? "#e06c75" : "#8f94a3"
        font.pixelSize: 10
    }

    Rectangle {
        id: volumeTrack

        anchors.left: parent.left
        anchors.leftMargin: 38
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        height: 4
        radius: 2
        color: "#30323b"

        Rectangle {
            width: parent.width * root.volume()
            height: parent.height
            radius: 2
            color: root.node && root.node.audio && root.node.audio.muted ? "#666b78" : "#774c81"
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: function(mouse) {
                if (!root.node || !root.node.audio)
                    return;
                root.node.audio.volume = Math.max(0, Math.min(1, mouse.x / width));
            }
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        anchors.bottomMargin: 18
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
