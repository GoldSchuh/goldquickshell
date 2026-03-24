import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "."

PanelWindow {
    id: root

    property bool controlCenterOpen: false
    property bool stickyNoteOpen: false

    function closeAllPopups() {
        root.controlCenterOpen = false
        root.stickyNoteOpen = false
    }

    function togglePopup(name) {
        let shouldOpen = false;
        if (name === "sticky")
            shouldOpen = !root.stickyNoteOpen;
        else
            shouldOpen = !root.controlCenterOpen;

        closeAllPopups()

        if (shouldOpen) {
            if (name === "sticky") {
                root.stickyNoteOpen = true
            } else if (name === "control") {
                root.controlCenterOpen = true
            }
        }
    }

    color: "transparent"
    implicitHeight: 48

    anchors {
        top: true
        left: true
        right: true
    }

    exclusionMode: ExclusionMode.Normal
    exclusiveZone: implicitHeight + 10

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Item {
        anchors.fill: parent
        anchors.margins: 10

        RowLayout {
            anchors.fill: parent
            spacing: 10

            RowLayout {
                Layout.alignment: Qt.AlignVCenter
                spacing: 8

                WorkspaceWidget {
                    screen: root.screen
                }

                MediaWidget {}
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                RowLayout {
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: 4
                    spacing: 8

                    Item {
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: launcherWidget.implicitHeight

                        ProgramLauncherWidget {
                            id: launcherWidget
                            anchors.centerIn: parent
                        }
                    }

                    Item {
                        id: stickyNoteSlot
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: stickyNoteWidget.implicitHeight

                        HoverHandler {
                            id: stickyNoteSlotHover
                            cursorShape: Qt.PointingHandCursor
                        }

                        TapHandler {
                            onTapped: root.togglePopup("sticky")
                        }

                        StickyNoteWidget {
                            id: stickyNoteWidget
                            anchors.centerIn: parent
                            interactive: false
                            hovered: stickyNoteSlotHover.hovered
                            active: root.stickyNoteOpen
                            label: stickyNotePanel.selectedFileName()
                        }
                    }
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignVCenter
                spacing: 8

                SettingsWidget {}

                BatteryWidget {}

                ClockWidget {}

                ControlCenterWidget {
                    active: root.controlCenterOpen
                    onToggleRequested: root.togglePopup("control")
                }
            }
        }
    }

    ControlCenterPanel {
        screen: root.screen
        open: root.controlCenterOpen
        onCloseRequested: root.controlCenterOpen = false
    }

    StickyNotePanel {
        id: stickyNotePanel
        screen: root.screen
        open: root.stickyNoteOpen
        triggerLeftX: stickyNoteWidget.mapToItem(null, 0, 0).x
        triggerRightX: stickyNoteWidget.mapToItem(null, stickyNoteWidget.width, 0).x
        triggerCenterX: stickyNoteWidget.mapToItem(null, stickyNoteWidget.width / 2, 0).x
        triggerBottomY: stickyNoteWidget.mapToItem(null, 0, stickyNoteWidget.height).y
        onCloseRequested: root.stickyNoteOpen = false
    }
}
