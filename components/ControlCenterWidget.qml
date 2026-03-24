import QtQuick

Pill {
    id: root

    property bool active: false
    signal toggleRequested

    borderColor: active ? "#ffd4af37" : "#99d4af37"
    hovered: hoverHandler.hovered
    color: active ? "#dd2a2117" : (hovered ? hoverBg : bg)
    sizingItem: labelText

    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: root.toggleRequested()
    }

    Text {
        id: labelText
        anchors.centerIn: parent
        text: "\uf1de"
        color: root.active ? "#ffd4af37" : "#ffffffff"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 16
        font.weight: Font.Bold
    }
}
