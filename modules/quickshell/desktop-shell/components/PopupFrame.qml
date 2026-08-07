import QtQuick

Rectangle {
    property bool shown: true
    property int animationOrigin: Item.TopRight

    radius: Theme.popupRadius
    color: Theme.surface
    border.width: 1
    border.color: Theme.border
    opacity: shown ? 1 : 0
    scale: shown ? 1 : 0.96
    transformOrigin: animationOrigin

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.animationNormal
            easing.type: Easing.OutCubic
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: Theme.animationNormal
            easing.type: Easing.OutCubic
        }
    }
}
