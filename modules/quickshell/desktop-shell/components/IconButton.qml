import QtQuick

Rectangle {
    id: root

    property string icon: ""
    property bool active: true
    property bool disabled: false
    signal clicked()
    signal scrolled(int delta)

    implicitWidth: 28
    implicitHeight: 28
    width: implicitWidth
    height: implicitHeight
    radius: 6
    color: mouseArea.pressed ? Theme.accent : mouseArea.containsMouse ? Theme.strongHover : "transparent"
    opacity: disabled ? 0.45 : 1

    Text {
        anchors.centerIn: parent
        text: root.icon
        color: root.active ? Theme.text : Theme.inactiveIcon
        font.family: Theme.iconFont
        font.pixelSize: 16
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        enabled: !root.disabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
        onWheel: root.scrolled(wheel.angleDelta.y)
    }
}
