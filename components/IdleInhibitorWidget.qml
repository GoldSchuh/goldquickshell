import QtQuick
import Quickshell
import Quickshell.Wayland

Pill {
    id: root

    property bool inhibited: false
    sizingItem: labelText

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onContainsMouseChanged: root.hovered = containsMouse
        onClicked: root.inhibited = !root.inhibited
    }

    Text {
        id: labelText
        anchors.centerIn: parent
        text: root.inhibited ? "\uf06e" : "\uf070"
        color: "#ffffffff"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 14
        font.weight: Font.Bold
    }

    IdleInhibitor {
        enabled: root.inhibited
        window: PanelWindow {
            implicitWidth: 0
            implicitHeight: 0
            color: "transparent"

            anchors {
                right: true
                bottom: true
            }

            mask: Region {
                item: null
            }
        }
    }
}
