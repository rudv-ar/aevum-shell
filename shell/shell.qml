pragma ComponentBehavior: Bound

import Quickshell
import qs.modules.shell
import QtQuick

ShellRoot {
    settings.watchFiles: true

    Variants {
        model: Quickshell.screens

        delegate: Component {
            Shell {
                required property ShellScreen modelData
                screen: modelData
            }
        }
    }
}
