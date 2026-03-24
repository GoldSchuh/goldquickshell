import QtQuick

Rectangle {
    id: root

    property color fg: "#ffffff"
    property color bg: "#cc111318"
    property color borderColor: "#99d4af37"
    property color hoverBg: "#e6222222"
    property color hoverBorderColor: "#ffd4af37"
    property bool hovered: false
    property int horizontalPadding: 14
    property int verticalPadding: 2
    property Item sizingItem: null

    radius: 100
    implicitWidth: sizingItem ? sizingItem.implicitWidth + horizontalPadding * 2 : 30
    implicitHeight: sizingItem ? Math.max(30, sizingItem.implicitHeight + verticalPadding * 2) : 30
    color: hovered ? hoverBg : bg
    border.width: 1
    border.color: hovered ? hoverBorderColor : borderColor

    Behavior on color {
        ColorAnimation { duration: 140 }
    }
}
