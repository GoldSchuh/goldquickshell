import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root

    required property ShellScreen screen
    property bool open: false
    property real triggerLeftX: screen.width / 2 - 60
    property real triggerRightX: screen.width / 2 + 60
    property real triggerCenterX: screen.width / 2
    property real triggerBottomY: 42
    property string vaultPath: StandardPaths.writableLocation(StandardPaths.DocumentsLocation) + "/Notes"
    property var fileEntries: []
    property string selectedRelativePath: ""
    property bool syncingEditor: false
    property bool fileListLoaded: false
    property bool createMode: false
    property string newFileName: ""

    signal closeRequested

    visible: open
    color: "transparent"
    implicitWidth: panelWidth + 40
    implicitHeight: panelHeight
    focusable: true

    readonly property real panelWidth: 600
    readonly property real panelRadius: 18
    readonly property real panelBottomMargin: 24
    readonly property real panelTopY: Math.max(triggerBottomY + 22, 74)
    readonly property real panelContentHeight: 620
    readonly property real panelHeight: panelContentHeight - panelTopY - panelBottomMargin
    readonly property real panelSideMargin: 20
    readonly property real panelX: Math.max(panelSideMargin, Math.min(screen.width - implicitWidth - panelSideMargin, triggerCenterX - implicitWidth / 2))

    anchors {
        top: true
    }

    margins {
        left: panelX
        top: panelTopY
    }

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    function refreshFiles() {
        fileListLoaded = false
        listFiles.running = true
    }

    function selectedFilePath() {
        return root.selectedRelativePath === "" ? "" : root.vaultPath + "/" + root.selectedRelativePath
    }

    function selectedFileName() {
        if (root.selectedRelativePath === "") {
            return ""
        }

        const parts = root.selectedRelativePath.split("/")
        return parts[parts.length - 1]
    }

    function syncEditorFromFile() {
        if (noteFile.path === "") {
            syncingEditor = true
            editor.text = ""
            syncingEditor = false
            return
        }

        syncingEditor = true
        editor.text = noteFile.text()
        syncingEditor = false
    }

    function normalizedNewFilePath() {
        const trimmed = root.newFileName.trim()
        if (trimmed === "") {
            return ""
        }

        return trimmed.endsWith(".md") ? trimmed : trimmed + ".md"
    }

    onOpenChanged: {
        if (open) {
            refreshFiles()
        }
    }

    Shortcut {
        sequence: "Escape"
        context: Qt.WindowShortcut
        enabled: root.open
        onActivated: root.closeRequested()
    }

    Item {
        x: root.panelSideMargin
        y: 0
        width: root.panelWidth
        height: root.implicitHeight
        clip: false

        Rectangle {
            width: parent.width
            height: parent.height
            y: 0
            radius: root.panelRadius
            color: "transparent"
            border.width: 0
            clip: false

            Rectangle {
                anchors.fill: parent
                radius: root.panelRadius
                color: "#dd111318"
                clip: true
            }

            Rectangle {
                anchors.fill: parent
                radius: root.panelRadius
                color: "transparent"
                border.width: 2
                border.color: "#55d4af37"
            }

            Item {
                anchors.fill: parent
                clip: true

                Rectangle {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    width: 200
                    height: 200
                    radius: 100
                    x: 70
                    y: -100
                    color: "#18d4af37"
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    width: 220
                    height: 220
                    radius: 110
                    x: -90
                    y: 120
                    color: "#108fb7c7"
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    anchors.topMargin: 14
                    spacing: 10

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 68
                        radius: 14
                        color: "#bb13161b"
                        border.width: 1
                        border.color: "#33ffffff"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: root.createMode ? "Neue Markdown-Datei" : "Markdown-Datei"
                                    color: "#e6ffffff"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                    font.letterSpacing: 0.8
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: root.createMode ? "Pfad + Name" : (root.fileEntries.length + " Dateien")
                                    color: "#88ffffff"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 9
                                    font.weight: Font.DemiBold
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                Loader {
                                    Layout.fillWidth: true
                                    sourceComponent: root.createMode ? createField : fileSelector
                                }

                                Rectangle {
                                    Layout.preferredWidth: 32
                                    Layout.preferredHeight: 32
                                    Layout.alignment: Qt.AlignVCenter
                                    radius: 9
                                    color: addMouse.containsMouse ? "#22ffffff" : "#14000000"
                                    border.width: 1
                                    border.color: "#33ffffff"

                                    MouseArea {
                                        id: addMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (root.createMode) {
                                                if (root.normalizedNewFilePath() !== "") {
                                                    createFile.running = true
                                                }
                                            } else {
                                                root.createMode = true
                                                root.newFileName = ""
                                            }
                                        }
                                    }
                                    Text {
                                        anchors.centerIn: parent
                                        text: root.createMode ? "\uf00c" : "\uf067"
                                        color: "#ffffffff"
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 12
                                        font.weight: Font.Bold
                                    }
                                }

                                Rectangle {
                                    Layout.preferredWidth: 32
                                    Layout.preferredHeight: 32
                                    Layout.alignment: Qt.AlignVCenter
                                    radius: 9
                                    color: refreshMouse.containsMouse ? "#22ffffff" : "#14000000"
                                    border.width: 1
                                    border.color: "#33ffffff"

                                    MouseArea {
                                        id: refreshMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.refreshFiles()
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: "\uf021"
                                        color: "#ffffffff"
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 12
                                        font.weight: Font.Bold
                                    }
                                }

                                Rectangle {
                                    Layout.preferredWidth: 32
                                    Layout.preferredHeight: 32
                                    Layout.alignment: Qt.AlignVCenter
                                    radius: 9
                                    color: closeMouse.containsMouse ? "#22ffffff" : "#14000000"
                                    border.width: 1
                                    border.color: "#33ffffff"

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
                                        font.pixelSize: 12
                                        font.weight: Font.Bold
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 16
                        color: "#c915181d"
                        border.width: 1
                        border.color: "#33ffffff"

                        StackLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            currentIndex: root.fileEntries.length > 0 ? 0 : 1

                            ColumnLayout {
                                spacing: 10

                                RowLayout {
                                    Layout.fillWidth: true

                                    Text {
                                        text: root.selectedFileName()
                                        color: "#ffd4af37"
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 13
                                        font.weight: Font.Bold
                                        elide: Text.ElideMiddle
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: "Markdown"
                                        color: "#88ffffff"
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 11
                                        font.weight: Font.DemiBold
                                    }
                                }

                                ScrollView {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    clip: true

                                    TextArea {
                                        id: editor
                                        color: "#f3f1e8"
                                        selectionColor: "#55d4af37"
                                        selectedTextColor: "#111318"
                                        wrapMode: TextEdit.Wrap
                                        textFormat: TextEdit.PlainText
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 14
                                        placeholderText: "Waehle oben eine Markdown-Datei aus."
                                        background: null

                                        onTextChanged: {
                                            if (!root.syncingEditor && noteFile.path !== "") {
                                                saveTimer.restart()
                                            }
                                        }
                                    }
                                }
                            }

                            Item {
                                Text {
                                    anchors.centerIn: parent
                                    text: root.fileListLoaded
                                        ? "Keine .md-Dateien im Vault gefunden."
                                        : "Lade Markdown-Dateien..."
                                    color: "#99ffffff"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 14
                                    font.weight: Font.DemiBold
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Timer {
        id: saveTimer
        interval: 500
        repeat: false
        onTriggered: {
            if (noteFile.path !== "") {
                noteFile.setText(editor.text)
            }
        }
    }

    Component {
        id: fileSelector

        ComboBox {
            id: fileCombo
            model: root.fileEntries
            textRole: "label"
            enabled: root.fileEntries.length > 0
            leftPadding: 12
            rightPadding: 34

            currentIndex: {
                for (let i = 0; i < root.fileEntries.length; i += 1) {
                    if (root.fileEntries[i].path === root.selectedRelativePath) {
                        return i
                    }
                }

                return root.fileEntries.length > 0 ? 0 : -1
            }

            onActivated: function(index) {
                if (index >= 0 && index < root.fileEntries.length) {
                    root.selectedRelativePath = root.fileEntries[index].path
                }
            }

            indicator: Text {
                x: fileCombo.width - width - 12
                y: Math.round((fileCombo.height - height) / 2)
                text: "\uf078"
                color: "#ffffffff"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                font.weight: Font.Bold
            }

            delegate: ItemDelegate {
                width: fileCombo.width
                text: modelData.label
                highlighted: fileCombo.highlightedIndex === index
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13

                contentItem: Text {
                    text: modelData.label
                    color: highlighted ? "#111318" : "#f3f1e8"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideMiddle
                }

                background: Rectangle {
                    radius: 8
                    color: highlighted ? "#ffd4af37" : (fileCombo.currentIndex === index ? "#221f232a" : "transparent")
                    border.width: highlighted ? 0 : 1
                    border.color: "#00000000"
                }
            }

            contentItem: Text {
                text: fileCombo.displayText
                color: "#ffffffff"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideMiddle
            }

            popup: Popup {
                y: fileCombo.height + 8
                width: fileCombo.width
                padding: 8

                background: Rectangle {
                    radius: 12
                    color: "#dd111318"
                    border.width: 1
                    border.color: "#55d4af37"
                }

                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: fileCombo.delegateModel
                    currentIndex: fileCombo.highlightedIndex
                    spacing: 4
                }
            }

            background: Rectangle {
                radius: 10
                color: fileCombo.down ? "#222831" : "#1d2026"
                border.width: 1
                border.color: fileCombo.visualFocus ? "#88d4af37" : "#44d4af37"
            }
        }
    }

    Component {
        id: createField

        TextField {
            text: root.newFileName
            placeholderText: "dateiname oder pfad/neue-notiz.md"
            color: "#ffffffff"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
            selectByMouse: true
            onTextEdited: root.newFileName = text
            onAccepted: createFile.running = root.normalizedNewFilePath() !== ""

            background: Rectangle {
                radius: 10
                color: "#1d2026"
                border.width: 1
                border.color: "#44d4af37"
            }
        }
    }

    FileView {
        id: noteFile
        path: root.selectedFilePath()
        watchChanges: true
        preload: true
        printErrors: true

        onLoaded: root.syncEditorFromFile()
        onTextChanged: root.syncEditorFromFile()
        onFileChanged: reload()
    }

    Process {
        id: listFiles
        command: [
            "bash",
            "-lc",
            "cd \"$1\" 2>/dev/null && find . -type f -name '*.md' -printf '%P\\n' | sort",
            "bash",
            root.vaultPath
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text
                    .split("\n")
                    .map(line => line.trim())
                    .filter(line => line !== "")

                root.fileEntries = lines.map(line => ({ label: line, path: line }))
                root.fileListLoaded = true

                if (root.fileEntries.length === 0) {
                    root.selectedRelativePath = ""
                    root.syncEditorFromFile()
                    return
                }

                let selectedExists = false

                for (let i = 0; i < root.fileEntries.length; i += 1) {
                    if (root.fileEntries[i].path === root.selectedRelativePath) {
                        selectedExists = true
                        break
                    }
                }

                if (!selectedExists) {
                    root.selectedRelativePath = root.fileEntries[0].path
                } else {
                    noteFile.reload()
                }
            }
        }
    }

    Process {
        id: createFile
        command: [
            "bash",
            "-lc",
            "TARGET=\"$1\"; mkdir -p \"$(dirname \"$TARGET\")\" && [ ! -e \"$TARGET\" ] && : > \"$TARGET\"",
            "bash",
            root.vaultPath + "/" + root.normalizedNewFilePath()
        ]
        onRunningChanged: {
            if (!running && root.createMode && root.normalizedNewFilePath() !== "") {
                root.createMode = false
                root.selectedRelativePath = root.normalizedNewFilePath()
                root.newFileName = ""
                root.refreshFiles()
            }
        }
    }
}
