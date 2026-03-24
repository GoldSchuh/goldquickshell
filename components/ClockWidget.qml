import QtQuick

Pill {
    id: root

    property bool altFormat: false
    property string label: ""
    sizingItem: labelText

    function refresh() {
        const now = new Date();
        root.label = altFormat
            ? "\uf133 " + Qt.formatDate(now, "ddd,MMM dd")
            : "\uf017 " + Qt.formatTime(now, "hh:mm AP");
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onContainsMouseChanged: root.hovered = containsMouse
        onClicked: {
            root.altFormat = !root.altFormat;
            root.refresh();
        }
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
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
