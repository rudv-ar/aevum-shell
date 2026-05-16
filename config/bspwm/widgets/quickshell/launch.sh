#!/bin/bash 

qs -p ~/.config/bspwm/shell/topbar/shell.qml > /dev/null 2>&1 &
topbar_pid=$!
qs -p ~/.config/bspwm/shell/notifications/shell.qml > /dev/null 2>&1 &
notifications_pid=$!
qs -p ~/.config/bspwm/shell/panes/shell.qml > /dev/null 2>&1 &
panes_pid=$!
qs -p ~/.config/bspwm/shell/powermenu/shell.qml > /dev/null 2>&1 & 
powermenu_pid=$!

sleep 30
topbar_wid=$(xdotool search --pid $topbar_pid)
xdotool set_window --classname "qs-topbar" --class "qs-topbar" $topbar_wid
#xprop -id $topbar_wid -f WM_CLASS 8s -set WM_CLASS "qs-topbar\000qs-topbar"
panes_wid=$(xdotool search --pid $panes_pid)
xdotool set_window --classname "qs-panes" --class "qs-panes" $panes_wid
#xprop -id $border_wid -f WM_CLASS 8s -set WM_CLASS "qs-border\000qs-border"
notifications_wid=$(xdotool search --pid $notifications_pid)
xdotool set_window --classname "qs-notify" --class "qs-notify" $notifications_wid
#xprop -id $notifications_wid -f WM_CLASS 8s -set WM_CLASS "qs-notify\000qs-notify"
powermenu_wid=$(xdotool search --pid $powermenu_pid)
xdotool set_window --classname "qs-powermenu" --class "qs-powermenu" $powermenu_wid

