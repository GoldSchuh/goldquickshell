import QtQuick
import Quickshell.Io

Pill {
    id: root

    fg: "#ffd4af37"
    borderColor: "#ffd4af37"
    horizontalPadding: 16
    sizingItem: labelText

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onContainsMouseChanged: root.hovered = containsMouse
        onClicked: toggleLauncher.running = true
    }

    Text {
        id: labelText
        anchors.centerIn: parent
        text: "\uf422"
        color: root.fg
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 16
        font.weight: Font.Bold
    }

    Process {
        id: toggleLauncher
        command: ["bash", "-lc", "if pgrep -x wofi >/dev/null; then pkill -x wofi; else setsid -f /usr/bin/wofi --show drun >/dev/null 2>&1; fi"]
    }
}
