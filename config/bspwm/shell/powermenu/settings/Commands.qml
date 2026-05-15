pragma Singleton
import QtQuick
import Quickshell

QtObject {
    function powerLock()    { return ["betterlockscreen", "--lock"] }
    function powerSuspend() { return ["systemctl", "suspend"] }
    function powerLogout()  { return ["bspc", "quit"] }
    function powerReboot()  { return ["systemctl", "reboot"] }
    function powerOff()     { return ["systemctl", "poweroff"] }
}



