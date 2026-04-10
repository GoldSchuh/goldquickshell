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
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

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
                        font.pixelSize: 18
                        font.weight: Font.Bold
                    }
                }

                Rectangle {
                    id: powerButton
                    Layout.preferredWidth: 38
                    Layout.preferredHeight: 38
                    radius: 19
                    color: powerMouse.containsMouse ? "#26d95763" : "#14000000"
                    border.width: 1
                    border.color: powerMouse.containsMouse ? "#66d95763" : "#33ffffff"

                    MouseArea {
                        id: powerMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (powerMenu.opened)
                                powerMenu.close();
                            else
                                powerMenu.open();
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "\uf011"
                        color: "#ffffffff"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14
                        font.weight: Font.Bold
                    }
                }

                Item {
                    Layout.preferredWidth: 4
                    Layout.preferredHeight: 4
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 150
                radius: 24
                color: "#cc161a20"
                border.width: 1
                border.color: "#33ffffff"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 14

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: root.timeText
                            color: "#ffffffff"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 48
                            font.weight: Font.Black
                        }

                        Text {
                            text: root.dateText
                            color: "#b3ffffff"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                        }

                        Text {
                            text: batteryCharging ? "Charging" : "Running on battery"
                            color: batteryCharging ? "#ffd4af37" : "#88ffffff"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                        }
                    }

                    ColumnLayout {
                        spacing: 10

                        Rectangle {
                            Layout.preferredWidth: 118
                            Layout.preferredHeight: 46
                            radius: 16
                            color: "#181c2027"
                            border.width: 1
                            border.color: "#33ffffff"

                            Column {
                                anchors.centerIn: parent
                                spacing: 2

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: root.batteryIcon + " " + root.batteryText
                                    color: root.batteryCharging ? "#ffd4af37" : "#ffffffff"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 15
                                    font.weight: Font.Bold
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "Battery"
                                    color: "#88ffffff"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                }
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 118
                            Layout.preferredHeight: 46
                            radius: 16
                            color: "#181c2027"
                            border.width: 1
                            border.color: "#33ffffff"

                            Column {
                                anchors.centerIn: parent
                                spacing: 2

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: root.uptimeText
                                    color: "#ffffffff"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 15
                                    font.weight: Font.Bold
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "Uptime"
                                    color: "#88ffffff"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 96
                radius: 22
                color: "#bb13161b"
                border.width: 1
                border.color: "#33ffffff"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "\uf028  Volume"
                            color: "#88ffffff"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: root.volumeMuted ? "Muted" : root.volumeText
                            color: root.volumeMuted ? "#ff9d6b6b" : "#ffffffff"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 13
                            font.weight: Font.Bold
                        }
                    }

                    Slider {
                        id: control
                        Layout.fillWidth: true
                        Layout.preferredHeight: 24
                        orientation: Qt.Horizontal
                        live: true
                        padding: 0
                        from: 0
                        to: 1.0
                        value: root.volumeValue
                        onMoved: {
                            root.volumeDragging = true;
                            root.volumeMuted = false;
                            root.volumeValue = value;
                            root.volumeText = Math.round(value * 100) + "%";
                        }
                        onPressedChanged: {
                            if (pressed) {
                                root.volumeDragging = true;
                                return;
                            }

                            volumeSet.targetValue = value;
                            volumeSet.running = true;
                        }

                        background: Rectangle {
                            x: control.leftPadding
                            y: (control.height - height) / 2
                            width: control.availableWidth
                            height: 8
                            radius: 4
                            color: "#221f232b"

                            Rectangle {
                                width: control.visualPosition * parent.width
                                height: parent.height
                                radius: parent.radius
                                color: root.volumeMuted ? "#aa9d6b6b" : "#ffd4af37"
                            }
                        }

                        handle: Rectangle {
                            x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
                            y: (control.height - height) / 2
                            width: 18
                            height: 18
                            radius: 9
                            color: "#ffffffff"
                            border.width: 1
                            border.color: root.volumeMuted ? "#aa9d6b6b" : "#ffd4af37"
                        }
                    }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 14
                rowSpacing: 14

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 104
                    radius: 22
                    color: "#bb13161b"
                    border.width: 1
                    border.color: "#33ffffff"

                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: 18
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6

                        Text {
                            text: "\uf2db  CPU"
                            color: "#88ffffff"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                        }

                        Text {
                            text: root.cpuText
                            color: "#ffffffff"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 27
                            font.weight: Font.Bold
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 104
                    radius: 22
                    color: "#bb13161b"
                    border.width: 1
                    border.color: "#33ffffff"

                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: 18
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6

                        Text {
                            text: "\uf538  Memory"
                            color: "#88ffffff"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                        }

                        Text {
                            text: root.memoryText
                            color: "#ffffffff"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 27
                            font.weight: Font.Bold
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 22
                color: "#bb13161b"
                border.width: 1
                border.color: "#33ffffff"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "\uf001  Media"
                            color: "#88ffffff"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: root.mediaActive ? "Active" : "Idle"
                            color: root.mediaActive ? "#ffd4af37" : "#88ffffff"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.mediaText
                        color: root.mediaActive ? "#ffffffff" : "#88ffffff"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 15
                        font.weight: Font.Bold
                        wrapMode: Text.Wrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                    }

                    Item { Layout.fillHeight: true }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            radius: 14
                            color: playPauseMouse.containsMouse ? "#26d4af37" : "#181c2027"
                            border.width: 1
                            border.color: "#44d4af37"

                            MouseArea {
                                id: playPauseMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: playerToggle.running = true
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "\uf04b  Play / Pause"
                                color: "#ffffffff"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            radius: 14
                            color: closeActionMouse.containsMouse ? "#22ffffff" : "#181c2027"
                            border.width: 1
                            border.color: "#33ffffff"

                            MouseArea {
                                id: closeActionMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.closeRequested()
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "\uf00d  Close"
                                color: "#ffffffff"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 8
            anchors.rightMargin: 8
            width: 26
            height: 26
            radius: 13
            color: closeMouse.containsMouse ? "#22ffffff" : "#10000000"
            border.width: 1
            border.color: "#2effffff"
            z: 3

            MouseArea {
                id: closeMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.closeRequested()
            }

            Text {
                anchors.centerIn: parent
                text: "\uf00d"
                color: "#ffffffff"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 11
                font.weight: Font.Bold
            }
        }

        Popup {
            id: powerMenu
            parent: root.contentItem
            modal: false
            dim: false
            padding: 0
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside | Popup.CloseOnPressOutsideParent
            x: Math.min(powerButton.x + powerButton.width + 20, root.width - implicitWidth - 20)
            y: Math.max(20, powerButton.y - 4)
            z: 4

            background: Rectangle {
                radius: 18
                color: "#cc161a20"
                border.width: 1
                border.color: "#33ffffff"
            }

            contentItem: Column {
                spacing: 0

                Repeater {
                    model: [
                        {
                            label: "Sleep",
                            icon: "\uf186",
                            command: ["systemctl", "suspend"]
                        },
                        {
                            label: "Restart",
                            icon: "\uf2f1",
                            command: ["systemctl", "reboot"]
                        },
                        {
                            label: "Shut down",
                            icon: "\uf011",
                            command: ["systemctl", "poweroff"]
                        }
                    ]

                    delegate: Rectangle {
                        id: actionButton
                        required property var modelData

                        width: 188
                        height: 52
                        radius: index === 0 ? 18 : (index === 2 ? 18 : 0)
                        topLeftRadius: index === 0 ? 18 : 0
                        topRightRadius: index === 0 ? 18 : 0
                        bottomLeftRadius: index === 2 ? 18 : 0
                        bottomRightRadius: index === 2 ? 18 : 0
                        color: actionMouse.containsMouse ? "#221f232b" : "#00000000"

                        MouseArea {
                            id: actionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.pendingPowerCommand = parent.modelData.command;
                                powerAction.running = true;
                                powerMenu.close();
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            height: 1
                            visible: index < 2
                            color: "#22ffffff"
                        }

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            spacing: 12

                            Text {
                                text: actionButton.modelData.icon
                                color: "#ffd4af37"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                            }

                            Column {
                                spacing: 2

                                Text {
                                    text: actionButton.modelData.label
                                    color: "#ffffffff"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 13
                                    font.weight: Font.Bold
                                }

                                Text {
                                    text: actionButton.modelData.label === "Sleep"
                                        ? "Suspend session"
                                        : (actionButton.modelData.label === "Restart" ? "Reboot system" : "Power off system")
                                    color: "#88ffffff"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshClock()
    }

    Shortcut {
        sequence: "Escape"
        enabled: root.open
        onActivated: {
            if (powerMenu.opened)
                powerMenu.close();
            else
                root.closeRequested();
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            systemProbe.running = true;
            mediaProbe.running = true;
            if (!root.volumeDragging)
                volumeProbe.running = true;
        }
    }

    Process {
        id: systemProbe
        command: [
            "bash",
            "-lc",
            "HOST=$(hostnamectl --static 2>/dev/null || hostname); " +
            "CPU=$(LC_ALL=C top -bn1 | awk '/Cpu\\(s\\)|%Cpu/ {for (i=1; i<=NF; i++) if ($i ~ /id,|id/) {gsub(/,/, \"\", $(i-1)); printf(\"%.0f%%\", 100-$(i-1)); exit}}'); " +
            "MEM=$(awk '/MemTotal:/ { total=$2 } /MemAvailable:/ { avail=$2 } END { if (total > 0 && avail >= 0) printf(\"%.1f GB\", (total-avail)/1024/1024); else print \"-- GB\"; }' /proc/meminfo); " +
            "UP=$(awk '{ total=int($1); days=int(total/86400); hrs=int((total%86400)/3600); mins=int((total%3600)/60); if (days>0) printf(\"%dd %02dh\", days, hrs); else printf(\"%02dh %02dm\", hrs, mins); }' /proc/uptime); " +
            "BATTERY_LINE=''; for BATDIR in /sys/class/power_supply/BAT*; do if [ -d \"$BATDIR\" ] && [ -r \"$BATDIR/capacity\" ]; then CAP=$(cat \"$BATDIR/capacity\"); STATUS=$(cat \"$BATDIR/status\" 2>/dev/null); ICON=''; [ \"$CAP\" -ge 20 ] && ICON=''; [ \"$CAP\" -ge 40 ] && ICON=''; [ \"$CAP\" -ge 60 ] && ICON=''; [ \"$CAP\" -ge 80 ] && ICON=''; [ \"$STATUS\" = 'Charging' ] && ICON='󰂄'; [ \"$STATUS\" = 'Full' ] && ICON=''; BATTERY_LINE=$(printf '%s|%s%%|%s' \"$ICON\" \"$CAP\" \"$STATUS\"); break; fi; done; " +
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
