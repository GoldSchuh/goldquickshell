import QtQuick
import Quickshell
import qs.modules.widgets.dashboard.controls
import qs.modules.components
import qs.modules.globals
import qs.modules.theme
import qs.config

FloatingWindow {
    id: settingsWindow

    implicitWidth: 900
    implicitHeight: 650
    visible: GlobalStates.settingsWindowVisible
    color: "transparent"

    StyledRect {
        anchors.fill: parent
        variant: "bg"
        radius: 0

        SettingsTab {
            anchors.fill: parent
            anchors.margins: 16
        }
    }

    onVisibleChanged: {
        if (!visible && GlobalStates.settingsWindowVisible)
            GlobalStates.settingsWindowVisible = false;
    }

    Connections {
        target: GlobalStates
        function onSettingsWindowVisibleChanged() {
            settingsWindow.visible = GlobalStates.settingsWindowVisible;
        }
    }
}
