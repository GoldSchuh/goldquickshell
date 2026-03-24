import QtQuick
import Quickshell.Io

Pill {
    id: root

    property string label: "\uf1e6 AC"
    property bool charging: false
    sizingItem: labelText

    borderColor: charging ? "#ffd4af37" : "#99d4af37"

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
        color: root.charging ? "#ffd4af37" : "#ffffffff"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 14
        font.weight: Font.Bold
    }

    Timer {
        interval: 15000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: batteryProbe.running = true
    }

    Process {
        id: batteryProbe
        command: ["bash", "-lc", "for BATDIR in /sys/class/power_supply/BAT*; do if [ -d \"$BATDIR\" ] && [ -r \"$BATDIR/capacity\" ]; then CAP=$(cat \"$BATDIR/capacity\"); STATUS=$(cat \"$BATDIR/status\" 2>/dev/null); ICON=''; [ \"$CAP\" -ge 20 ] && ICON=''; [ \"$CAP\" -ge 40 ] && ICON=''; [ \"$CAP\" -ge 60 ] && ICON=''; [ \"$CAP\" -ge 80 ] && ICON=''; [ \"$STATUS\" = 'Charging' ] && ICON='󰂄'; [ \"$STATUS\" = 'Full' ] && ICON=''; printf '%s|%s|%s\\n' \"$ICON\" \"$CAP\" \"$STATUS\"; exit 0; fi; done; if [ -r /sys/class/power_supply/AC/online ] && [ \"$(cat /sys/class/power_supply/AC/online)\" = '1' ]; then printf '|AC|Plugged\\n'; else printf '|--|Unknown\\n'; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split("|");
                const icon = parts[0] || "\uf1e6";
                const value = parts[1] || "AC";
                const status = parts[2] || "";
                root.charging = status === "Charging" || status === "Full" || status === "Plugged";
                root.label = icon + " " + value + (value === "AC" ? "" : "%");
            }
        }
    }
}
