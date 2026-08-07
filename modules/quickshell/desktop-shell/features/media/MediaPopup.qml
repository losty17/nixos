import QtQuick
import Quickshell
import "../../components" as UI

PopupWindow {
    id: root

    property Item targetItem
    property var player
    property bool open: false
    signal closeRequested()

    visible: open && !!player
    grabFocus: true
    color: "transparent"
    implicitWidth: 380
    implicitHeight: 480

    anchor.item: root.targetItem
    anchor.rect.x: 0
    anchor.rect.y: root.targetItem ? root.targetItem.height + 4 : 0
    anchor.adjustment: PopupAdjustment.All

    onVisibleChanged: {
        if (!visible)
            Qt.callLater(function() {
                if (!root.visible && root.open)
                    root.closeRequested();
            });
    }

    UI.PopupFrame {
        anchors.fill: parent

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14

            Rectangle {
                width: 300
                height: 300
                anchors.horizontalCenter: parent.horizontalCenter
                radius: UI.Theme.controlRadius
                color: UI.Theme.inset
                border.width: 1
                border.color: UI.Theme.border
                clip: true

                Image {
                    id: coverImage

                    anchors.fill: parent
                    source: root.player ? root.player.trackArtUrl : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true
                    visible: status === Image.Ready
                }

                Text {
                    anchors.centerIn: parent
                    visible: !coverImage.visible
                    text: "\uf001"
                    color: UI.Theme.subduedText
                    font.family: UI.Theme.iconFont
                    font.pixelSize: 72
                }
            }

            Column {
                width: parent.width
                spacing: 4

                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: root.player ? (root.player.trackTitle || "Unknown song") : ""
                    color: UI.Theme.text
                    elide: Text.ElideRight
                    font.family: UI.Theme.textFont
                    font.pixelSize: 18
                    font.bold: true
                }

                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: root.player ? (root.player.trackAlbum || "Unknown album") : ""
                    color: UI.Theme.secondaryText
                    elide: Text.ElideRight
                    font.family: UI.Theme.textFont
                    font.pixelSize: 12
                }

                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: root.player ? (root.player.trackArtist || "Unknown artist") : ""
                    color: UI.Theme.mutedText
                    elide: Text.ElideRight
                    font.family: UI.Theme.textFont
                    font.pixelSize: 12
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 14

                UI.IconButton {
                    icon: "\uf04a"
                    disabled: !root.player || !root.player.canGoPrevious
                    onClicked: if (root.player) root.player.previous()
                }

                UI.IconButton {
                    implicitWidth: 42
                    implicitHeight: 42
                    radius: 21
                    color: UI.Theme.accent
                    icon: root.player && root.player.isPlaying ? "\uf04c" : "\uf04b"
                    disabled: !root.player || !root.player.canTogglePlaying
                    onClicked: if (root.player) root.player.togglePlaying()
                }

                UI.IconButton {
                    icon: "\uf04e"
                    disabled: !root.player || !root.player.canGoNext
                    onClicked: if (root.player) root.player.next()
                }
            }

        }
    }
}
