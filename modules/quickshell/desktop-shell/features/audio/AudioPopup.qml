pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import "../../components" as UI

PopupWindow {
    id: root

    property Item targetItem
    property var outputNode
    property var inputNode
    property bool open: false
    signal closeRequested()

    visible: open
    grabFocus: true
    color: "transparent"
    implicitWidth: 390
    implicitHeight: 520

    anchor.item: root.targetItem
    anchor.rect.x: root.targetItem ? root.targetItem.width - width : 0
    anchor.rect.y: root.targetItem ? root.targetItem.height + 4 : 0
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
        if (!visible)
            Qt.callLater(function() {
                if (!root.visible && root.open)
                    root.closeRequested();
            });
    }

    UI.PopupFrame {
        anchors.fill: parent
        shown: root.open

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
                        color: UI.Theme.text
                        font.bold: true
                        font.pixelSize: 16
                    }

                    Text {
                        text: root.outputNode ? root.outputNode.description : "PipeWire"
                        color: UI.Theme.mutedText
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }
                }

                Item {
                    width: parent.width - parent.children[0].width - muteButton.width - 8
                    height: 1
                }

                UI.IconButton {
                    id: muteButton

                    icon: root.outputNode && root.outputNode.audio && root.outputNode.audio.muted ? "\uf026" : "\uf028"
                    active: !!root.outputNode && root.outputNode.audio && !root.outputNode.audio.muted
                    disabled: !root.outputNode || !root.outputNode.audio
                    onClicked: if (root.outputNode && root.outputNode.audio) root.outputNode.audio.muted = !root.outputNode.audio.muted
                }
            }

            Text {
                text: "Output devices"
                color: UI.Theme.text
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
                    color: UI.Theme.mutedText
                    font.pixelSize: 11
                }
            }

            Text {
                text: "Input devices"
                color: UI.Theme.text
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
                    color: UI.Theme.mutedText
                    font.pixelSize: 11
                }
            }

            UI.Divider {
                width: parent.width
            }

            Text {
                text: "Application streams"
                color: UI.Theme.text
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
                    color: UI.Theme.mutedText
                    font.pixelSize: 11
                }
            }
        }
    }
}
