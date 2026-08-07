import QtQuick
import Quickshell.Io

Item {
    id: root

    property var monthDate: new Date()
    property var calendarDays: []
    property var eventDayCounts: ({})
    property var monthEvents: []
    property string agendaStatus: ""

    visible: false

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
        return dateKey(date);
    }

    function rebuild() {
        const year = root.monthDate.getFullYear();
        const month = root.monthDate.getMonth();
        const firstWeekday = new Date(year, month, 1, 12, 0, 0, 0).getDay();
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

    function refresh() {
        root.agendaStatus = "Loading Google agenda...";
        const today = new Date();
        const monthStart = new Date(root.monthDate.getFullYear(), root.monthDate.getMonth(), 1, 12, 0, 0, 0);
        const requestStart = monthStart < today ? monthStart : today;
        const todayEnd = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 8, 12, 0, 0, 0);
        const monthEnd = new Date(root.monthDate.getFullYear(), root.monthDate.getMonth() + 2, 14, 12, 0, 0, 0);
        const requestEnd = monthEnd > todayEnd ? monthEnd : todayEnd;
        agendaProcess.exec([
            "timeout", "8s", "gcalcli", "--nocolor", "--nocache", "agenda",
            root.requestDate(requestStart), root.requestDate(requestEnd), "--tsv", "--nodeclined"
        ]);
    }

    function reset() {
        root.monthDate = new Date();
        root.rebuild();
    }

    function navigate(offset) {
        root.monthDate = new Date(root.monthDate.getFullYear(), root.monthDate.getMonth() + offset, 1, 12, 0, 0, 0);
        root.rebuild();
        root.refresh();
    }

    function parseAgenda(output) {
        const text = String(output || "").trim();
        root.monthEvents = [];
        if (text.length === 0) {
            root.eventDayCounts = ({});
            root.rebuild();
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

        function markEventDays(event) {
            const start = root.parseDate(event.startDate);
            if (!start)
                return;
            let last = root.parseDate(event.endDate) || start;
            if (last > start && !event.startTime)
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
            const fields = lines[i].trim().split("\t");
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
            markEventDays(event);
            events.push(event);
        }

        events.sort(function(a, b) {
            const dateA = root.parseDate(a.startDate);
            const dateB = root.parseDate(b.startDate);
            return dateA.getTime() !== dateB.getTime() ? dateA - dateB : a.startTime.localeCompare(b.startTime);
        });
        root.monthEvents = events.filter(isInDisplayedMonth);
        root.eventDayCounts = dayCounts;
        root.rebuild();
        return root.monthEvents.length;
    }

    function eventDateLabel(event) {
        const date = root.parseDate(event.startDate);
        if (!date)
            return event.startDate;
        const day = Qt.formatDate(date, "ddd d MMM");
        return event.startTime ? day + "  " + event.startTime : day + "  All day";
    }

    Process {
        id: agendaProcess

        stdout: StdioCollector {
            id: agendaOutput

            onStreamFinished: {
                const count = root.parseAgenda(agendaOutput.text);
                root.agendaStatus = count > 0 ? "Synced from Google Calendar" : "No events this month";
            }
        }

        onExited: function(exitCode) {
            if (exitCode !== 0 && root.agendaStatus === "Loading Google agenda...") {
                root.eventDayCounts = ({});
                root.monthEvents = [];
                root.rebuild();
                root.agendaStatus = "Calendar unavailable. Run `gcalcli init`.";
            }
        }
    }

    Component.onCompleted: root.rebuild()
}
