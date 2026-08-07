pragma Singleton

import QtQuick

QtObject {
    readonly property color background: "#0a0a0a"
    readonly property color inset: "#0f1014"
    readonly property color surface: "#14151a"
    readonly property color raised: "#1c1d22"
    readonly property color selected: "#201d2a"
    readonly property color hover: "#2a202f"
    readonly property color strongHover: "#392a48"
    readonly property color border: "#30323b"
    readonly property color accent: "#774c81"
    readonly property color accentHover: "#91609c"
    readonly property color accentText: "#d8b8e3"
    readonly property color text: "#e6e8ee"
    readonly property color secondaryText: "#c7cad4"
    readonly property color mutedText: "#8f94a3"
    readonly property color subduedText: "#666b78"
    readonly property color inactiveIcon: "#666666"
    readonly property color danger: "#e06c75"
    readonly property color dangerSurface: "#4c2028"
    readonly property color dangerHover: "#7b3038"
    readonly property color warning: "#e5c07b"
    readonly property color urgent: "#900000"
    readonly property color accentForeground: "#ffffff"

    readonly property string textFont: "Inter"
    readonly property string iconFont: "Symbols Nerd Font"
    readonly property int popupRadius: 10
    readonly property int tooltipRadius: 6
    readonly property int controlRadius: 7
    readonly property int popupMargin: 16
}
