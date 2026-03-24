//@ pragma UseQApplication
//@ pragma ShellId quickshellself

import QtQuick
import Quickshell
import "components"

ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {
            required property ShellScreen modelData

            screen: modelData
        }

    }

}
