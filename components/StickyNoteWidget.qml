import QtQuick
import QtQuick.Layouts

Pill {
    id: root

    property bool active: false
    property string label: ""
    property bool interactive: true

    signal toggleRequested

    fg: "#ffd4af37"
    bg: active ? "#dd111318" : "#cc111318"
    borderColor: active ? "#ffd4af37" : "#99d4af37"
    hovered: hoverHandler.hovered
    horizontalPadding: active ? 18 : 14
    verticalPadding: active ? 4 : 2
    sizingItem: contentRow
    implicitWidth: 120

    HoverHandler {
        id: hoverHandler
        enabled: root.interactive
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        enabled: root.interactive
        onTapped: root.toggleRequested()
    }

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: root.label === "" ? 0 : 8

        Text {
            text: root.active ? "\uf249" : "\uf24a"
            color: root.fg
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 16
            font.weight: Font.Bold
        }

        Text {
            visible: root.label !== ""
            text: root.label
            color: "#e6ffffff"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            font.weight: Font.DemiBold
            elide: Text.ElideRight
            Layout.maximumWidth: 180
        }
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }
}
