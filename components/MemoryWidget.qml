import QtQuick
import Quickshell.Io

Pill {
    id: root

    property string label: "\uf0c9 --GB"
    sizingItem: labelText

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onContainsMouseChanged: root.hovered = containsMouse
    }

    Text {
        id: labelText
        anchors.centerIn: parent
        text: root.label
        color: "#ffffffff"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 14
        font.weight: Font.Bold
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: memProbe.running = true
    }

    Process {
        id: memProbe
        command: ["bash", "-lc", "awk '/MemTotal:/ { total=$2 } /MemAvailable:/ { avail=$2 } END { if (total > 0 && avail >= 0) printf(\"%.2f\\n\", (total-avail)/1024/1024); }' /proc/meminfo"]
        stdout: StdioCollector {
            onStreamFinished: {
                const value = text.trim();
                if (value.length > 0)
                    root.label = "\uf0c9 " + value + "GB";
                else
                    root.label = "\uf0c9 --GB";
            }
        }
    }
}
