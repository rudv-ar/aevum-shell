#!/bin/bash 


qs -p ~/.config/aevum/shell/shell.qml &
shell_pid=$!

sleep 5
shell_wid=$(xdotool search --pid $shell_pid)
xdotool set_window --classname "qs-shell" --class "qs-shell" $shell_wid

