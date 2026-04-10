# goldquickshell

`goldquickshell` is a Quickshell configuration for Hyprland. The project provides a top bar with workspace indicators, media status, an app launcher, sticky notes, and a control center.

## Features

- top panel bar for all detected screens
- workspace switching via `Quickshell.Hyprland`
- media display and play/pause control via `playerctl`
- application launching with `wofi`
- clock and battery widgets
- control center with hostname, CPU, memory, uptime, battery, and volume information
- power menu for suspend, reboot, and poweroff
- sticky note panel backed by Markdown files from a configurable local notes vault

## Requirements

At minimum, these components need to be available:

- `quickshell`
- `hyprland`
- `wofi`
- `playerctl`
- `wpctl` from  PipeWire / WirePlumber
- `systemctl`
- `hostnamectl`
- a Nerd Font; `JetBrainsMono Nerd Font` is currently referenced directly in the QML

The project also reads system information directly from `/proc` and `/sys/class/power_supply`.

## Running

Run it directly from the project directory:

```bash
quickshell --path path_to/goldquickshell
```

In the current Hyprland configuration, the shell is started like this:

```ini
exec-once = quickshell --path ~/goldquickshell
```

## Structure

- `shell.qml`: entry point, creates the bar for each screen
- `components/Bar.qml`: main bar with widgets and popup state handling
- `components/ControlCenter/`: control center button and panel
- `components/StickyNotePanel.qml`: Markdown editor for local notes
- `components/*.qml`: individual widgets such as clock, battery, media, and launcher

## Important Customizations

Some values are currently hard-coded in the source:

- notes vault: `components/StickyNotePanel.qml` uses `~/Documents/Notes` by default
- launcher: `components/ProgramLauncherWidget.qml` starts `/usr/bin/wofi --show drun`
- font: several components expect `JetBrainsMono Nerd Font`
- workspaces: `components/WorkspaceWidget.qml` shows fixed IDs from 1 to 8

If you want to use the project on another system, you should adjust these paths and assumptions first.

## Usage

- click a workspace pill to switch the active Hyprland workspace
- click the launcher icon to open or close `wofi`
- click the clock widget to toggle between time and date format
- click the sticky note widget to open the Markdown editor
- click the control center icon to open the right-side panel
- press `Escape` to close the sticky note panel

## Notes

- the repository currently does not include separate install logic or packaging
- the shell is clearly tailored to Wayland, Hyprland, and a local desktop environment
- the sticky note panel automatically loads, creates, and live-saves Markdown files
