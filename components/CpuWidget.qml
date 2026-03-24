import QtQuick
import Quickshell.Io

Pill {
    id: root

    property string label: "\uf2db --%"
    sizingItem: labelText

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onContainsMouseChanged: root.hovered = containsMouse
        onClicked: launchHtop.running = true
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
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: cpuProbe.running = true
    }

    Process {
        id: cpuProbe
        command: ["bash", "-lc", "LC_ALL=C top -bn1 | awk '/Cpu\\(s\\)|%Cpu/ {for (i=1; i<=NF; i++) if ($i ~ /id,|id/) {gsub(/,/, \"\", $(i-1)); printf(\"%.0f\\n\", 100-$(i-1)); exit}}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const value = text.trim();
                if (value.length > 0)
                    root.label = "\uf2db " + value + "%";
            }
        }
    }

    Process {
        id: launchHtop
        command: ["kitty", "-e", "htop"]
    }
}
