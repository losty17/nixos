pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

PopupWindow {
    id: root

    property var panelWindow
    property string wallpaperDirectory: Quickshell.env("HOME") + "/Pictures/Wallpapers"
    property string wallpaperStateFile: Quickshell.env("HOME") + "/.config/quickshell/wallpaper-state"
    property var wallpapers: []
    property string selectedPath: ""
    property bool open: false
    signal closeRequested()

    visible: open
    grabFocus: true
    color: "transparent"
    implicitWidth: 360
    implicitHeight: 390

    anchor.window: panelWindow
    anchor.rect.x: panelWindow ? panelWindow.width - width - 4 : 0
    anchor.rect.y: panelWindow ? panelWindow.height + 4 : 0
    anchor.edges: Edges.Top | Edges.Left
    anchor.gravity: Edges.Bottom | Edges.Right
    anchor.adjustment: PopupAdjustment.All

    function loadWallpapers() {
        wallpaperProcess.exec(["find", "-L", root.wallpaperDirectory, "-maxdepth", "1", "-type", "f", "-print"]);
    }

    function applyWallpaper(path) {
        if (!path)
            return;
        root.selectedPath = path;
        Quickshell.execDetached(["awww", "img", "--transition-type", "fade", path]);
        Quickshell.execDetached(["sh", "-c", "printf '%s\\n' \"$1\" > \"$2\"", "wallpaper-state", path, root.wallpaperStateFile]);
    }

    onVisibleChanged: {
        if (!visible) {
            if (panelWindow && panelWindow.wallpaperOpen)
                panelWindow.wallpaperOpen = false;
        } else {
            root.loadWallpapers();
        }
    }

    Process {
        id: wallpaperProcess

        stdout: StdioCollector {
            id: wallpaperOutput

            onStreamFinished: {
                const lines = wallpaperOutput.text.trim().split("\n");
                const result = [];
                for (let i = 0; i < lines.length; ++i) {
                    const path = lines[i].trim();
                    if (path.length === 0)
                        continue;
                    if (/\.(png|jpe?g|webp|gif)$/i.test(path))
                        result.push(path);
                }
                result.sort();
                root.wallpapers = result;
            }
        }
    }

    FileView {
        id: wallpaperStateView

        path: root.wallpaperStateFile
        printErrors: false

        onLoaded: {
            const savedPath = wallpaperStateView.text().trim();
            if (savedPath.length > 0)
                root.selectedPath = savedPath;
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
            spacing: 10

            Row {
                width: parent.width
                height: 32

                Column {
                    spacing: 2

                    Text {
                        text: "Wallpaper"
                        color: "#e6e8ee"
                        font.bold: true
                        font.pixelSize: 16
                    }

                    Text {
                        text: root.wallpaperDirectory
                        color: "#8f94a3"
                        elide: Text.ElideMiddle
                        font.pixelSize: 10
                    }
                }

                Item {
                    width: parent.width - refreshButton.width - 8
                    height: 1
                }

                ConnectivityButton {
                    id: refreshButton

                    icon: "\uf021"
                    onClicked: root.loadWallpapers()
                }
            }

            Item {
                width: parent.width
                height: 290

                ListView {
                    anchors.fill: parent
                    spacing: 5
                    clip: true
                    model: root.wallpapers

                    delegate: Rectangle {
                        required property string modelData

                        width: ListView.view ? ListView.view.width : 0
                        height: 42
                        radius: 7
                        color: modelData === root.selectedPath ? "#201d2a" : mouseArea.containsMouse ? "#2a202f" : "#1c1d22"
                        border.width: modelData === root.selectedPath ? 1 : 0
                        border.color: "#774c81"

                        Rectangle {
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            width: 48
                            height: 30
                            radius: 5
                            color: "#0f1014"

                            Image {
                                anchors.fill: parent
                                source: "file://" + modelData
                                asynchronous: true
                                cache: true
                                fillMode: Image.PreserveAspectCrop
                            }
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 64
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.substring(modelData.lastIndexOf("/") + 1)
                            color: "#e6e8ee"
                            elide: Text.ElideMiddle
                            font.pixelSize: 12
                        }

                        MouseArea {
                            id: mouseArea

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.applyWallpaper(modelData)
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: root.wallpapers.length === 0
                    text: "No wallpapers found"
                    color: "#8f94a3"
                    font.pixelSize: 12
                }
            }

            Text {
                width: parent.width
                text: "Add images to ~/Pictures/Wallpapers"
                color: "#666b78"
                font.pixelSize: 10
            }
        }
    }
}
