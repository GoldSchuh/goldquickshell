import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Pill {
    id: root

    required property ShellScreen screen

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screen)
    readonly property int activeWorkspaceId: monitor?.activeWorkspace?.id || 1
    horizontalPadding: 6
    sizingItem: row

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onContainsMouseChanged: root.hovered = containsMouse
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 2

        Repeater {
            model: 8

            delegate: Rectangle {
                required property int index

                readonly property int workspaceId: index + 1
                readonly property bool active: root.activeWorkspaceId === workspaceId

                radius: 100
                implicitWidth: active ? 38 : 28
                implicitHeight: 24
                color: active ? "#e6222222" : "transparent"
                border.width: active ? 1 : 0
                border.color: "#ffd4af37"

                Behavior on implicitWidth {
                    NumberAnimation {
                        duration: 140
                        easing.type: Easing.OutCubic
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: workspaceId
                    color: active ? "#ffd4af37" : "#ffe0e0e0"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    font.weight: Font.Bold
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("workspace " + parent.workspaceId)
                }
            }
        }
    }
}
