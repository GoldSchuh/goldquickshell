import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Widgets

Pill {
    id: root

    visible: trayRepeater.count > 0
    horizontalPadding: 10
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
        spacing: 6

        Repeater {
            id: trayRepeater
            model: SystemTray.items

            delegate: MouseArea {
                required property SystemTrayItem modelData

                implicitWidth: 16
                implicitHeight: 16
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onClicked: event => {
                    if (event.button === Qt.LeftButton)
                        modelData.activate();
                    else if (event.button === Qt.RightButton && modelData.secondaryActivate)
                        modelData.secondaryActivate();
                }

                IconImage {
                    anchors.fill: parent
                    source: modelData.icon
                }
            }
        }
    }
}
