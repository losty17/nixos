import QtQuick
import Quickshell.Io

Item {
    id: root

    property string location: "Santa_Cruz_do_Sul"
    property string text: "Weather unavailable"

    function refresh() {
        weatherProcess.exec(weatherProcess.command);
    }

    visible: false

    Process {
        id: weatherProcess

        command: ["curl", "-fsSL", "--max-time", "8", "https://wttr.in/" + root.location + "?format=%c|%t|%C"]

        stdout: StdioCollector {
            id: weatherOutput

            onStreamFinished: {
                const output = weatherOutput.text.trim();
                if (output.length > 0)
                    root.text = output;
            }
        }
    }

    Timer {
        interval: 900000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
