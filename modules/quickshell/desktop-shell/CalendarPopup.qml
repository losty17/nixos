pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

PopupWindow {
    id: root

    property var panelWindow
    property var clock
    property string weatherLocation: "Santa Cruz do Sul"
    property string weatherText: "Weather unavailable"
    property var monthDate: new Date()
    property var calendarDays: []
    property var eventDayCounts: ({})
    property var monthEvents: []
    property string agendaStatus: ""
    property bool open: false
    signal refreshWeatherRequested()
    signal closeRequested()

    visible: open
    grabFocus: true
    color: "transparent"
    implicitWidth: 430
    implicitHeight: 600

    anchor.window: panelWindow
    anchor.rect.x: panelWindow ? panelWindow.width - width - 4 : 0
    anchor.rect.y: panelWindow ? panelWindow.height + 4 : 0
    anchor.edges: Edges.Top | Edges.Left
    anchor.gravity: Edges.Bottom | Edges.Right
    anchor.adjustment: PopupAdjustment.All

    function pad(value) {
        return value < 10 ? "0" + value : String(value);
    }

    function dateKey(date) {
        return date.getFullYear() + "-" + pad(date.getMonth() + 1) + "-" + pad(date.getDate());
    }

    function parseDate(value) {
        const parts = String(value || "").split("-");
        if (parts.length !== 3)
            return null;
        return new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]), 12, 0, 0, 0);
    }

    function requestDate(date) {
        return date.getFullYear() + "-" + pad(date.getMonth() + 1) + "-" + pad(date.getDate());
    }

    function rebuildCalendar() {
        const year = root.monthDate.getFullYear();
        const month = root.monthDate.getMonth();
        const firstDay = new Date(year, month, 1, 12, 0, 0, 0);
        const firstWeekday = firstDay.getDay();
        const today = new Date();
        const days = [];

        for (let i = 0; i < 42; ++i) {
            const date = new Date(year, month, 1 - firstWeekday + i, 12, 0, 0, 0);
            const key = root.dateKey(date);
            days.push({
                day: date.getDate(),
                key: key,
                inMonth: date.getMonth() === month,
                isToday: key === root.dateKey(today),
                eventCount: root.eventDayCounts[key] || 0
            });
        }

        root.calendarDays = days;
    }

    function monthRequestStart() {
        const today = new Date();
        const monthStart = new Date(root.monthDate.getFullYear(), root.monthDate.getMonth(), 1, 12, 0, 0, 0);
        return monthStart < today ? monthStart : today;
    }

    function monthRequestEnd() {
        const today = new Date();
        const todayEnd = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 8, 12, 0, 0, 0);
        const monthEnd = new Date(root.monthDate.getFullYear(), root.monthDate.getMonth() + 2, 14, 12, 0, 0, 0);
        return monthEnd > todayEnd ? monthEnd : todayEnd;
    }

    function refreshAgenda() {
        root.agendaStatus = "Loading Google agenda...";
        const start = root.monthRequestStart();
        const end = root.monthRequestEnd();
        agendaProcess.exec([
            "timeout",
            "8s",
            "gcalcli",
            "--nocolor",
            "--nocache",
            "agenda",
            root.requestDate(start),
            root.requestDate(end),
            "--tsv",
            "--nodeclined"
        ]);
    }

    function refreshAll() {
        root.refreshAgenda();
        root.refreshWeatherRequested();
    }

    function navigateMonth(offset) {
        root.monthDate = new Date(root.monthDate.getFullYear(), root.monthDate.getMonth() + offset, 1, 12, 0, 0, 0);
        root.rebuildCalendar();
        root.refreshAgenda();
    }

    function parseAgenda(output) {
        const text = String(output || "").trim();
        root.monthEvents = [];
        if (text.length === 0) {
            root.eventDayCounts = ({});
            root.monthEvents = [];
            root.rebuildCalendar();
            return 0;
        }

        const lines = text.split(/\r?\n/);
        const headers = lines.shift().split("\t");
        const events = [];
        const dayCounts = ({});

        function field(fields, name) {
            const index = headers.indexOf(name);
            return index >= 0 && index < fields.length ? fields[index] : "";
        }

        function isInDisplayedMonth(event) {
            const start = root.parseDate(event.startDate);
            if (!start)
                return false;

            const monthStart = new Date(root.monthDate.getFullYear(), root.monthDate.getMonth(), 1, 12, 0, 0, 0);
            const monthEnd = new Date(root.monthDate.getFullYear(), root.monthDate.getMonth() + 1, 1, 12, 0, 0, 0);
            let end = root.parseDate(event.endDate) || start;
            if (end > start && !event.startTime)
                end = new Date(end.getFullYear(), end.getMonth(), end.getDate() - 1, 12, 0, 0, 0);

            return start < monthEnd && end >= monthStart;
        }

        function markEventDays(startDate, endDate, startTime) {
            const start = root.parseDate(startDate);
            if (!start)
                return;

            let last = root.parseDate(endDate) || start;
            if (last > start && !startTime)
                last = new Date(last.getFullYear(), last.getMonth(), last.getDate() - 1, 12, 0, 0, 0);

            const cursor = new Date(start);
            let guard = 0;
            while (cursor <= last && guard < 32) {
                const key = root.dateKey(cursor);
                dayCounts[key] = (dayCounts[key] || 0) + 1;
                cursor.setDate(cursor.getDate() + 1);
                ++guard;
            }
        }

        for (let i = 0; i < lines.length; ++i) {
            const line = lines[i].trim();
            if (!line)
                continue;

            const fields = line.split("\t");
            const startDate = field(fields, "start_date");
            if (!root.parseDate(startDate))
                continue;

            const event = {
                startDate: startDate,
                startTime: field(fields, "start_time"),
                endDate: field(fields, "end_date"),
                endTime: field(fields, "end_time"),
                title: field(fields, "title") || "Untitled event"
            };
            markEventDays(event.startDate, event.endDate, event.startTime);
            events.push(event);
        }

        events.sort(function(a, b) {
            const dateA = root.parseDate(a.startDate);
            const dateB = root.parseDate(b.startDate);
            if (dateA.getTime() !== dateB.getTime())
                return dateA - dateB;
            return a.startTime.localeCompare(b.startTime);
        });

        const monthEvents = [];
        for (let i = 0; i < events.length; ++i) {
            if (isInDisplayedMonth(events[i]))
                monthEvents.push(events[i]);
        }

        root.eventDayCounts = dayCounts;
        root.monthEvents = monthEvents;
        root.rebuildCalendar();
        return monthEvents.length;
    }

    function eventDateLabel(event) {
        const date = root.parseDate(event.startDate);
        if (!date)
            return event.startDate;
        const day = Qt.formatDate(date, "ddd d MMM");
        return event.startTime ? day + "  " + event.startTime : day + "  All day";
    }

    onVisibleChanged: {
        if (!visible) {
            if (panelWindow && panelWindow.calendarOpen)
                panelWindow.calendarOpen = false;
        } else {
            root.monthDate = new Date();
            root.rebuildCalendar();
            root.refreshAll();
        }
    }

    Component.onCompleted: root.rebuildCalendar()

    Process {
        id: agendaProcess

        stdout: StdioCollector {
            id: agendaOutput

            onStreamFinished: {
                const count = root.parseAgenda(agendaOutput.text);
                root.agendaStatus = count > 0 ? "Synced from Google Calendar" : "No events this month";
            }
        }

        stderr: StdioCollector {
            id: agendaError
        }

        onExited: function(exitCode) {
            if (exitCode !== 0 && root.agendaStatus === "Loading Google agenda...") {
                root.eventDayCounts = ({});
                root.monthEvents = [];
                root.rebuildCalendar();
                root.agendaStatus = "Calendar unavailable. Run `gcalcli init`.";
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: "#14151a"
        border.width: 1
        border.color: "#30323b"

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
                    color: "#e6e8ee"
                    font.bold: true
                    font.pixelSize: 13
                }

                Row {
                    id: calendarActions

                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: previousButton.width + nextButton.width + refreshButton.width + openButton.width
                    height: 28

                    ConnectivityButton {
                        id: previousButton

                        icon: "\uf104"
                        onClicked: root.navigateMonth(-1)
                    }

                    ConnectivityButton {
                        id: nextButton

                        icon: "\uf105"
                        onClicked: root.navigateMonth(1)
                    }

                    ConnectivityButton {
                        id: refreshButton

                        icon: "\uf021"
                        onClicked: root.refreshAll()
                    }

                    ConnectivityButton {
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
                        color: "#8f94a3"
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
                            color: modelData.isToday ? "#774c81" : "transparent"
                            border.width: modelData.eventCount > 0 && !modelData.isToday ? 1 : 0
                            border.color: "#392a48"
                            opacity: modelData.inMonth ? 1 : 0.35
                        }

                        Text {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -2
                            text: modelData.day
                            color: modelData.isToday ? "#ffffff" : modelData.inMonth ? "#e6e8ee" : "#666b78"
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
                                    color: dayCell.modelData.isToday ? "#ffffff" : "#d8b8e3"
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: "#30323b"
            }

            Row {
                width: parent.width
                height: 34
                spacing: 8

                Text {
                    id: weatherTitle

                    text: "Weather"
                    color: "#e6e8ee"
                    font.bold: true
                    font.pixelSize: 12
                }

                Text {
                    width: parent.width - weatherTitle.width - 8
                    text: root.weatherLocation + "  |  " + root.weatherText.replace(/\|/g, "  |  ")
                    color: "#c7cad4"
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
                    color: "#e6e8ee"
                    font.bold: true
                    font.pixelSize: 12
                }

                Text {
                    width: parent.width - monthTitle.width - 8
                    text: root.agendaStatus
                    color: "#8f94a3"
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
                            color: "#1c1d22"
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            width: 92
                            text: root.eventDateLabel(modelData)
                            color: "#d8b8e3"
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
                            color: "#e6e8ee"
                            elide: Text.ElideRight
                            font.pixelSize: 11
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: root.monthEvents.length === 0
                    text: "No events this month"
                    color: "#8f94a3"
                    font.pixelSize: 11
                }
            }
        }
    }
}
