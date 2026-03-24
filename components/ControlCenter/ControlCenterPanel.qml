import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root

    required property ShellScreen screen
    property bool open: false
    property string timeText: "--:--"
    property string dateText: "--"
    property string batteryIcon: "\uf1e6"
    property string batteryText: "--"
    property bool batteryCharging: false
    property string cpuText: "--%"
    property string memoryText: "-- GB"
    property string uptimeText: "--"
    property string hostText: "host"
    property string mediaText: "No active playback"
    property bool mediaActive: false
    property string volumeText: "--%"
    property real volumeValue: 0
    property bool volumeMuted: false
    property bool volumeDragging: false
    property var pendingPowerCommand: []

    signal closeRequested

    visible: open
    color: "transparent"
    implicitWidth: 430
    implicitHeight: panelHeight

    anchors {
        top: true
        right: true
    }

    readonly property real panelTopY: 67
    readonly property real panelContentHeight: 560
    readonly property real panelHeight: panelContentHeight - panelTopY - 10

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    margins {
        top: panelTopY
        right: 10
        left: 10
        bottom: 10
    }

    function refreshClock() {
        const now = new Date();
        root.timeText = Qt.formatTime(now, "hh:mm");
        root.dateText = Qt.formatDate(now, "dddd, dd MMMM");
    }

    Rectangle {
        anchors.fill: parent
        radius: 10
        topLeftRadius: 10
        topRightRadius: 10
        bottomLeftRadius: 18
        bottomRightRadius: 18
        color: "#cc111318"
        border.width: 2
        border.color: "#55d4af37"
        clip: true

        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            width: 180
            height: 180
            radius: 90
            x: 50
            y: -70
            color: "#18d4af37"
        }

        Rectangle {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            width: 220
            height: 220
            radius: 110
            x: -90
            y: 90
            color: "#0f8fb7c7"
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14

            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: "CONTROL CENTER"
                        color: "#88ffffff"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        font.letterSpacing: 1.6
                    }

                    Text {
                        text: root.hostText
                        color: "#ffffffff"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 22
                        font.weight: Font.Bold
                    }

                    Text {
                        text: root.uptimeText
                        color: "#99ffffff"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 13
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 52
                    Layout.preferredHeight: 52
                    radius: 16
                    color: "#22161a20"
                    border.width: 1
                    border.color: "#44ffffff"

                    Text {
                        anchors.centerIn: parent
                        text: "\uf011"
                        color: "#ffffffff"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 20
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.closeRequested()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 114
                radius: 20
                color: "#18171b22"
                border.width: 1
                border.color: "#33ffffff"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 6

                    Text {
                        text: root.timeText
                        color: "#ffffffff"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 34
                        font.weight: Font.Bold
                    }

                    Text {
                        text: root.dateText
                        color: "#bbffffff"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14
                    }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 12
                rowSpacing: 12

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 90
                    radius: 18
                    color: "#18171b22"
                    border.width: 1
                    border.color: "#33ffffff"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 4

                        Text {
                            text: "BATTERY"
                            color: "#88ffffff"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            font.letterSpacing: 1.4
                        }

                        Text {
                            text: root.batteryIcon + "  " + root.batteryText
                            color: root.batteryCharging ? "#ffd4af37" : "#ffffffff"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 22
                            font.weight: Font.Bold
                        }

                        Text {
                            text: root.batteryCharging ? "Charging" : "Battery power"
                            color: "#99ffffff"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 90
                    radius: 18
                    color: "#18171b22"
                    border.width: 1
                    border.color: "#33ffffff"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 4

                        Text {
                            text: "MEDIA"
                            color: "#88ffffff"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            font.letterSpacing: 1.4
                        }

                        Text {
                            text: root.mediaText
                            color: root.mediaActive ? "#ffffffff" : "#99ffffff"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 14
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: playerToggle.running = true
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 90
                    radius: 18
                    color: "#18171b22"
                    border.width: 1
                    border.color: "#33ffffff"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 4

                        Text {
                            text: "CPU"
                            color: "#88ffffff"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            font.letterSpacing: 1.4
                        }

                        Text {
                            text: root.cpuText
                            color: "#ffffffff"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 22
                            font.weight: Font.Bold
                        }

                        Text {
                            text: "Processor usage"
                            color: "#99ffffff"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 90
                    radius: 18
                    color: "#18171b22"
                    border.width: 1
                    border.color: "#33ffffff"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 4

                        Text {
                            text: "MEMORY"
                            color: "#88ffffff"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            font.letterSpacing: 1.4
                        }

                        Text {
                            text: root.memoryText
                            color: "#ffffffff"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 22
                            font.weight: Font.Bold
                        }

                        Text {
                            text: "RAM in use"
                            color: "#99ffffff"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 108
                radius: 20
                color: "#18171b22"
                border.width: 1
                border.color: "#33ffffff"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "VOLUME"
                            color: "#88ffffff"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            font.letterSpacing: 1.4
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: root.volumeMuted ? "\uf6a9 " + root.volumeText : "\uf028 " + root.volumeText
                            color: "#ffffffff"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 13
                            font.weight: Font.Bold
                        }
                    }

                    Slider {
                        Layout.fillWidth: true
                        from: 0
                        to: 1
                        value: root.volumeValue

                        onMoved: {
                            root.volumeDragging = true;
                            root.volumeValue = value;
                            root.volumeText = Math.round(value * 100) + "%";
                            volumeSet.targetValue = value;
                            volumeSet.running = true;
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 124
                radius: 20
                color: "#18171b22"
                border.width: 1
                border.color: "#33ffffff"

                GridLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    columns: 3
                    rowSpacing: 10
                    columnSpacing: 10

                    Repeater {
                        model: [
                            { icon: "\uf011", label: "Shutdown", command: ["systemctl", "poweroff"] },
                            { icon: "\uf2f1", label: "Reboot", command: ["systemctl", "reboot"] },
                            { icon: "\uf186", label: "Suspend", command: ["systemctl", "suspend"] }
                        ]

                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 72
                            radius: 16
                            color: "#22161a20"
                            border.width: 1
                            border.color: "#33ffffff"

                            Column {
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: parent.parent.modelData.icon
                                    color: "#ffffffff"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 20
                                    font.weight: Font.Bold
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: parent.parent.modelData.label
                                    color: "#ccffffff"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 12
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.pendingPowerCommand = parent.modelData.command;
                                    powerAction.running = true;
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        refreshClock();
        statsProbe.running = true;
        mediaProbe.running = true;
        volumeProbe.running = true;
    }

    onOpenChanged: {
        if (open) {
            refreshClock();
            statsProbe.running = true;
            mediaProbe.running = true;
            volumeProbe.running = true;
        }
    }

    Timer {
        interval: 1000
        running: root.open
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshClock()
    }

    Timer {
        interval: 5000
        running: root.open
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            statsProbe.running = true;
            mediaProbe.running = true;
            volumeProbe.running = true;
        }
    }

    Process {
        id: statsProbe
        command: [
            "bash",
            "-lc",
            "HOST=$(hostnamectl --static 2>/dev/null || hostname 2>/dev/null || printf 'host'); " +
            "CPU=$(top -bn1 | awk '/Cpu\\(s\\)/ { print int($2 + $4 + 0.5) \"%\"; exit }'); " +
            "MEM=$(free -h | awk '/Mem:/ { print $3; exit }'); " +
            "UP=$(uptime -p 2>/dev/null | sed 's/^up //'); " +
            "BATTERY_LINE=$(for base in /sys/class/power_supply/BAT*; do [ -e \"$base\" ] || continue; cap=''; stat=''; [ -r \"$base/capacity\" ] && cap=$(cat \"$base/capacity\"); [ -r \"$base/status\" ] && stat=$(cat \"$base/status\"); if [ -n \"$cap\" ]; then if [ \"$stat\" = 'Charging' ] || [ \"$stat\" = 'Full' ]; then printf '|%s%%|%s\\n' \"$cap\" \"$stat\"; else printf '|%s%%|%s\\n' \"$cap\" \"$stat\"; fi; break; fi; done); " +
            "if [ -n \"$BATTERY_LINE\" ]; then printf '%s\\n' \"$BATTERY_LINE\"; elif [ -r /sys/class/power_supply/AC/online ] && [ \"$(cat /sys/class/power_supply/AC/online)\" = '1' ]; then printf '|AC|Plugged\\n'; else printf '|--|Unknown\\n'; fi; " +
            "printf '%s\\n%s\\n%s\\n%s\\n' \"$HOST\" \"$CPU\" \"$MEM\" \"$UP\""
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                if (lines.length < 5)
                    return;

                const batteryParts = (lines[0] || "").split("|");
                root.batteryIcon = batteryParts[0] || "\uf1e6";
                root.batteryText = batteryParts[1] || "--";
                const batteryState = batteryParts[2] || "";
                root.batteryCharging = batteryState === "Charging" || batteryState === "Full" || batteryState === "Plugged";
                root.hostText = lines[1] || "host";
                root.cpuText = lines[2] || "--%";
                root.memoryText = lines[3] || "-- GB";
                root.uptimeText = lines[4] || "--";
            }
        }
    }

    Process {
        id: mediaProbe
        command: ["bash", "-lc", "playerctl metadata --format '{{status}}|{{artist}} - {{title}}' 2>/dev/null || true"]
        stdout: StdioCollector {
            onStreamFinished: {
                const line = text.trim();
                if (line.length === 0) {
                    root.mediaActive = false;
                    root.mediaText = "No active playback";
                    return;
                }

                const parts = line.split("|");
                const state = parts[0] || "";
                const title = (parts[1] || "").trim();
                root.mediaActive = true;
                root.mediaText = (state === "Playing" ? "\uf04b " : "\uf04c ") + (title.length > 0 ? title : "Media player");
            }
        }
    }

    Process {
        id: playerToggle
        command: ["playerctl", "play-pause"]
    }

    Process {
        id: powerAction
        command: root.pendingPowerCommand
    }

    Process {
        id: volumeProbe
        command: [
            "bash",
            "-lc",
            "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{ muted=\"false\"; vol=\"0\"; for (i=1; i<=NF; ++i) { if ($i == \"[MUTED]\") muted=\"true\"; if ($i ~ /^[0-9.]+$/) vol=$i; } printf(\"%s|%d\\n\", muted, int(vol*100 + 0.5)); }'"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                if (root.volumeDragging)
                    return;

                const parts = text.trim().split("|");
                if (parts.length < 2)
                    return;

                const muted = parts[0] === "true";
                const percent = parseInt(parts[1], 10);
                if (isNaN(percent))
                    return;

                root.volumeMuted = muted;
                root.volumeValue = Math.max(0, Math.min(1, percent / 100));
                root.volumeText = percent + "%";
                root.volumeDragging = false;
            }
        }
    }

    Process {
        id: volumeSet
        property real targetValue: 0
        command: ["bash", "-lc", "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + Math.max(0, Math.min(1, targetValue)).toFixed(2)]
        onExited: volumeProbe.running = true
    }
}
