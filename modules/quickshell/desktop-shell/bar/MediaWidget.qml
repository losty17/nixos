import QtQuick
import "../components" as UI

Item {
    id: root

    property var player
    property bool active: false
    signal clicked()

    visible: !!player
    width: visible ? 320 : 0
    height: 28

    Rectangle {
        anchors.fill: parent
        radius: UI.Theme.controlRadius
        color: mouseArea.pressed ? UI.Theme.accent : mouseArea.containsMouse || root.active ? UI.Theme.strongHover : "transparent"
        scale: mouseArea.pressed ? 0.98 : 1

        Behavior on color {
            ColorAnimation { duration: UI.Theme.animationFast }
        }

        Behavior on scale {
            NumberAnimation {
                duration: UI.Theme.animationFast
                easing.type: Easing.OutCubic
            }
        }

        Row {
            anchors.fill: parent
            anchors.leftMargin: 3
            anchors.rightMargin: 8
            spacing: 7

            Rectangle {
                width: 22
                height: 22
                anchors.verticalCenter: parent.verticalCenter
                radius: 4
                color: UI.Theme.inset
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
                    color: UI.Theme.mutedText
                    font.family: UI.Theme.iconFont
                    font.pixelSize: 12
                }
            }

            Text {
                width: parent.width - 29
                height: parent.height
                verticalAlignment: Text.AlignVCenter
                text: root.player ? (root.player.trackTitle || root.player.identity || "Nothing playing") + (root.player.trackArtist ? " - " + root.player.trackArtist : "") : ""
                color: UI.Theme.text
                elide: Text.ElideRight
                font.family: UI.Theme.textFont
                font.pixelSize: 12
                font.weight: 600
            }
        }

        MouseArea {
            id: mouseArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clicked()
        }
    }
}
