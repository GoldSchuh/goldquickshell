import QtQuick
import Quickshell.Io

Pill {
    id: root

    property string label: "\u266a"
    property bool active: false
    visible: active || label === "\u266a"
    sizingItem: labelText

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onContainsMouseChanged: root.hovered = containsMouse
        onClicked: togglePlayer.running = true
    }

    Text {
        id: labelText
        anchors.centerIn: parent
        text: root.label
        color: "#ffffffff"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 14
        font.weight: Font.Bold
        elide: Text.ElideRight
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: mediaProbe.running = true
    }

    Process {
        id: mediaProbe
        command: ["bash", "-lc", "playerctl metadata --format '{{status}}|{{artist}} - {{title}}' 2>/dev/null || true"]
        stdout: StdioCollector {
            onStreamFinished: {
                const line = text.trim();
                if (line.length === 0) {
                    root.active = false;
                    root.label = "\u266a";
                    return;
                }

                const parts = line.split("|");
                const state = parts[0] || "";
                const title = (parts[1] || "").trim();
                root.active = true;
                root.label = (state === "Playing" ? "\uf04b " : "\uf04c ") + (title.length > 0 ? title : "MPD");
            }
        }
    }

    Process {
        id: togglePlayer
        command: ["playerctl", "play-pause"]
    }
}
