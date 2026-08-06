pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

PopupWindow {
    id: root

    property var panelWindow
    property var outputNode
    property var inputNode
    property bool open: false
    signal closeRequested()

    visible: open
    grabFocus: true
    color: "transparent"
    implicitWidth: 390
    implicitHeight: 520

    anchor.window: panelWindow
    anchor.rect.x: panelWindow ? panelWindow.width - width - 4 : 0
    anchor.rect.y: panelWindow ? panelWindow.height + 4 : 0
    anchor.edges: Edges.Top | Edges.Left
    anchor.gravity: Edges.Bottom | Edges.Right
    anchor.adjustment: PopupAdjustment.All

    function mediaClass(node) {
        if (!node || !node.properties)
            return "";
        return String(node.properties["media.class"] || "");
    }

    function nodesFor(kind) {
        const nodes = Pipewire.nodes && Pipewire.nodes.values ? Pipewire.nodes.values : [];
        const result = [];
        for (let i = 0; i < nodes.length; ++i) {
            const node = nodes[i];
            const media = root.mediaClass(node);
            if (!node || !node.audio)
                continue;
            if (kind === "sink" && media.indexOf("Audio/Sink") === 0)
                result.push(node);
            else if (kind === "source" && media.indexOf("Audio/Source") === 0)
                result.push(node);
            else if (kind === "stream" && (media.indexOf("Stream/Output/Audio") === 0 || media.indexOf("Stream/Input/Audio") === 0))
                result.push(node);
        }
        return result;
    }

    function selectNode(node, role) {
        if (!node)
            return;
        if (role === "sink")
            Pipewire.preferredDefaultAudioSink = node;
        else if (role === "source")
            Pipewire.preferredDefaultAudioSource = node;
    }

    onVisibleChanged: {
        if (!visible && panelWindow && panelWindow.audioOpen)
            panelWindow.audioOpen = false;
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
            spacing: 8

            Row {
                width: parent.width
                height: 32
                spacing: 8

                Column {
                    spacing: 2

                    Text {
                        text: "Audio"
                        color: "#e6e8ee"
                        font.bold: true
                        font.pixelSize: 16
                    }

                    Text {
                        text: root.outputNode ? root.outputNode.description : "PipeWire"
                        color: "#8f94a3"
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }
                }

                Item {
                    width: parent.width - parent.children[0].width - muteButton.width - 8
                    height: 1
                }

                ConnectivityButton {
                    id: muteButton

                    icon: root.outputNode && root.outputNode.audio && root.outputNode.audio.muted ? "\uf026" : "\uf028"
                    active: !!root.outputNode && root.outputNode.audio && !root.outputNode.audio.muted
                    disabled: !root.outputNode || !root.outputNode.audio
                    onClicked: if (root.outputNode && root.outputNode.audio) root.outputNode.audio.muted = !root.outputNode.audio.muted
                }
            }

            Text {
                text: "Output devices"
                color: "#e6e8ee"
                font.bold: true
                font.pixelSize: 12
            }

            Item {
                width: parent.width
                height: 116

                ListView {
                    anchors.fill: parent
                    spacing: 4
                    clip: true
                    model: root.nodesFor("sink")

                    delegate: AudioNodeRow {
                        required property var modelData

                        node: modelData
                        role: "sink"
                        selected: modelData === root.outputNode
                        onActivated: root.selectNode(node, role)
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: root.nodesFor("sink").length === 0
                    text: "No output devices"
                    color: "#8f94a3"
                    font.pixelSize: 11
                }
            }

            Text {
                text: "Input devices"
                color: "#e6e8ee"
                font.bold: true
                font.pixelSize: 12
            }

            Item {
                width: parent.width
                height: 116

                ListView {
                    anchors.fill: parent
                    spacing: 4
                    clip: true
                    model: root.nodesFor("source")

                    delegate: AudioNodeRow {
                        required property var modelData

                        node: modelData
                        role: "source"
                        selected: modelData === root.inputNode
                        onActivated: root.selectNode(node, role)
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: root.nodesFor("source").length === 0
                    text: "No input devices"
                    color: "#8f94a3"
                    font.pixelSize: 11
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: "#30323b"
            }

            Text {
                text: "Application streams"
                color: "#e6e8ee"
                font.bold: true
                font.pixelSize: 12
            }

            Item {
                width: parent.width
                height: 116

                ListView {
                    anchors.fill: parent
                    spacing: 4
                    clip: true
                    model: root.nodesFor("stream")

                    delegate: AudioNodeRow {
                        required property var modelData

                        node: modelData
                        role: "stream"
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: root.nodesFor("stream").length === 0
                    text: "No application streams"
                    color: "#8f94a3"
                    font.pixelSize: 11
                }
            }
        }
    }
}
