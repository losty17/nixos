import QtQuick

Item {
    id: root

    property var player
    visible: !!player
    width: visible ? 290 : 0
    height: 28

    Row {
        anchors.fill: parent
        spacing: 2

        ConnectivityButton {
            icon: "\uf04a"
            active: true
            disabled: !root.player || !root.player.canGoPrevious
            onClicked: if (root.player) root.player.previous()
        }

        ConnectivityButton {
            icon: root.player && root.player.isPlaying ? "\uf04c" : "\uf04b"
            active: true
            disabled: !root.player || !root.player.canTogglePlaying
            onClicked: if (root.player) root.player.togglePlaying()
        }

        ConnectivityButton {
            icon: "\uf04e"
            active: true
            disabled: !root.player || !root.player.canGoNext
            onClicked: if (root.player) root.player.next()
        }

        Column {
            width: parent.width - 86
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            Text {
                width: parent.width
                text: root.player ? (root.player.trackTitle || root.player.identity || "Nothing playing") : ""
                color: "#e6e8ee"
                elide: Text.ElideRight
                font.pixelSize: 11
                font.weight: 600
            }

            Text {
                width: parent.width
                text: root.player ? (root.player.trackArtist || root.player.identity || "") : ""
                color: "#8f94a3"
                elide: Text.ElideRight
                font.pixelSize: 10
            }
        }
    }
}
