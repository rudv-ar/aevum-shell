#!/bin/bash 


qs -p ~/.config/aevum/shell/shell.qml &
shell_pid=$!
qs -p ~/.config/aevum/shell/notifications/shell.qml
notify_pid=$!

sleep 60
shell_wid=$(xdotool search --pid $shell_pid)
xdotool set_window --classname "qs-shell" --class "qs-shell" $shell_wid

notify_wid=$(xdotool search --pid $notify_pid)
xdotool set_window --classname "qs-notify" --class "qs-notify" $notify_wid

