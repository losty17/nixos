pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../components" as UI

PopupWindow {
    id: root

    property Item targetItem
    property var clock
    property string weatherLocation: "Santa Cruz do Sul"
    property string weatherText: "Weather unavailable"
    readonly property alias monthDate: calendarModel.monthDate
    readonly property alias calendarDays: calendarModel.calendarDays
    readonly property alias monthEvents: calendarModel.monthEvents
    readonly property alias agendaStatus: calendarModel.agendaStatus
    property bool open: false
    signal refreshWeatherRequested()
    signal closeRequested()

    visible: open
    grabFocus: true
    color: "transparent"
    implicitWidth: 430
    implicitHeight: 600

    anchor.item: root.targetItem
    anchor.rect.x: root.targetItem ? root.targetItem.width - width : 0
    anchor.rect.y: root.targetItem ? root.targetItem.height + 4 : 0
    anchor.adjustment: PopupAdjustment.All

    function refreshAll() {
        calendarModel.refresh();
        root.refreshWeatherRequested();
    }

    function navigateMonth(offset) {
        calendarModel.navigate(offset);
    }

    function eventDateLabel(event) {
        return calendarModel.eventDateLabel(event);
    }

    onVisibleChanged: {
        if (!visible) {
            Qt.callLater(function() {
                if (!root.visible && root.open)
                    root.closeRequested();
            });
        } else {
            calendarModel.reset();
            root.refreshAll();
        }
    }

    CalendarModel {
        id: calendarModel
    }

    UI.PopupFrame {
        anchors.fill: parent

        Column {
            anchors.fill: parent
            anchors.margins: 16
            anchors.topMargin: 0
            spacing: 8

            Item {
                id: calendarHeader

                width: parent.width
                height: 50

                Text {
                    id: monthLabel

                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: Qt.formatDate(root.monthDate, "MMMM yyyy")
                    color: UI.Theme.text
                    font.bold: true
                    font.pixelSize: 13
                }

                Row {
                    id: calendarActions

                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: previousButton.width + nextButton.width + refreshButton.width + openButton.width
                    height: 28

                    UI.IconButton {
                        id: previousButton

                        icon: "\uf104"
                        onClicked: root.navigateMonth(-1)
                    }

                    UI.IconButton {
                        id: nextButton

                        icon: "\uf105"
                        onClicked: root.navigateMonth(1)
                    }

                    UI.IconButton {
                        id: refreshButton

                        icon: "\uf021"
                        onClicked: root.refreshAll()
                    }

                    UI.IconButton {
                        id: openButton

                        icon: "\uf35d"
                        onClicked: Quickshell.execDetached(["xdg-open", "https://calendar.google.com"])
                    }
                }
            }

            Row {
                id: weekdayRow

                width: parent.width
                height: 20
                spacing: 3

                Repeater {
                    model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

                    delegate: Text {
                        required property string modelData

                        width: (weekdayRow.width - 18) / 7
                        text: modelData
                        color: UI.Theme.mutedText
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 10
                    }
                }
            }

            Grid {
                id: calendarGrid

                width: parent.width
                height: 219
                columns: 7
                columnSpacing: 3
                rowSpacing: 3

                Repeater {
                    model: root.calendarDays

                    delegate: Item {
                        id: dayCell

                        required property var modelData

                        width: (calendarGrid.width - 18) / 7
                        height: 33

                        Rectangle {
                            anchors.fill: parent
                            radius: 6
                            color: modelData.isToday ? UI.Theme.accent : "transparent"
                            border.width: modelData.eventCount > 0 && !modelData.isToday ? 1 : 0
                            border.color: UI.Theme.strongHover
                            opacity: modelData.inMonth ? 1 : 0.35
                        }

                        Text {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -2
                            text: modelData.day
                            color: modelData.isToday ? UI.Theme.accentForeground : modelData.inMonth ? UI.Theme.text : UI.Theme.subduedText
                            font.pixelSize: 12
                            font.weight: modelData.isToday ? 600 : 400
                        }

                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 4
                            spacing: 2

                            Repeater {
                                model: Math.min(3, modelData.eventCount)

                                delegate: Rectangle {
                                    width: 4
                                    height: 4
                                    radius: 2
                                    color: dayCell.modelData.isToday ? UI.Theme.accentForeground : UI.Theme.accentText
                                }
                            }
                        }
                    }
                }
            }

            UI.Divider {
                width: parent.width
            }

            Row {
                width: parent.width
                height: 34
                spacing: 8

                Text {
                    id: weatherTitle

                    text: "Weather"
                    color: UI.Theme.text
                    font.bold: true
                    font.pixelSize: 12
                }

                Text {
                    width: parent.width - weatherTitle.width - 8
                    text: root.weatherLocation + "  |  " + root.weatherText.replace(/\|/g, "  |  ")
                    color: UI.Theme.secondaryText
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 11
                }
            }

            Row {
                width: parent.width
                height: 24
                spacing: 8

                Text {
                    id: monthTitle

                    text: "Current month"
                    color: UI.Theme.text
                    font.bold: true
                    font.pixelSize: 12
                }

                Text {
                    width: parent.width - monthTitle.width - 8
                    text: root.agendaStatus
                    color: UI.Theme.mutedText
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: 10
                }
            }

            Item {
                width: parent.width
                height: 120

                ListView {
                    anchors.fill: parent
                    spacing: 4
                    clip: true
                    model: root.monthEvents

                    delegate: Item {
                        required property var modelData

                        width: ListView.view ? ListView.view.width : 0
                        height: 30

                        Rectangle {
                            anchors.fill: parent
                            radius: 6
                            color: UI.Theme.raised
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            width: 92
                            text: root.eventDateLabel(modelData)
                            color: UI.Theme.accentText
                            elide: Text.ElideRight
                            font.pixelSize: 10
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 106
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.title
                            color: UI.Theme.text
                            elide: Text.ElideRight
                            font.pixelSize: 11
                        }
                    }
                }

                UI.EmptyState {
                    anchors.centerIn: parent
                    visible: root.monthEvents.length === 0
                    text: "No events this month"
                    font.pixelSize: 11
                }
            }
        }
    }
}
