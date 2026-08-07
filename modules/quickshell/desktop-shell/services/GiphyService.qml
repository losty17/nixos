import QtQuick
import Quickshell.Io

Item {
    id: root

    property string query: ""
    property var results: []
    property bool searching: false
    property string error: ""
    property string requestQuery: ""

    visible: false

    function scheduleSearch(value) {
        root.query = value;
        root.error = "";
        searchTimer.restart();
        if (value.trim().length === 0) {
            searchTimer.stop();
            root.results = [];
        }
    }

    function searchNow() {
        searchTimer.stop();
        const value = root.query.trim();
        if (value.length === 0) {
            root.results = [];
            root.searching = false;
            return;
        }
        root.requestQuery = value;
        root.searching = true;
        root.error = "";
        root.results = [];
        searchProcess.exec(["giphy-search", value, "--limit", "24"]);
    }

    Timer {
        id: searchTimer

        interval: 350
        onTriggered: root.searchNow()
    }

    Process {
        id: searchProcess

        stdout: StdioCollector {
            id: searchOutput

            onStreamFinished: {
                if (root.requestQuery !== root.query.trim())
                    return;
                try {
                    const parsed = JSON.parse(searchOutput.text);
                    if (parsed.query !== root.requestQuery)
                        return;
                    root.results = parsed.results instanceof Array ? parsed.results : [];
                } catch (error) {
                    root.results = [];
                    root.error = "Giphy returned an invalid response";
                }
            }
        }

        stderr: StdioCollector {
            id: searchError
        }

        onExited: function(exitCode) {
            if (root.requestQuery !== root.query.trim())
                return;
            root.searching = false;
            if (exitCode !== 0) {
                root.results = [];
                root.error = searchError.text.trim() || "Giphy search failed";
            }
        }
    }
}
