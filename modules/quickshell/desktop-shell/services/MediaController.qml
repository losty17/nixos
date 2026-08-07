import QtQuick
import Quickshell.Services.Mpris

Item {
    id: root

    property var player: null

    function selectPlayer() {
        const players = Mpris.players && Mpris.players.values ? Mpris.players.values : [];
        for (let i = 0; i < players.length; ++i) {
            if (players[i].isPlaying)
                return players[i];
        }
        return players.length > 0 ? players[0] : null;
    }

    visible: false

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.player = root.selectPlayer()
    }
}
