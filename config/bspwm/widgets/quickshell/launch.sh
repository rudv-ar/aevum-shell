#!/bin/bash 


qs ~/.config/aevum/shell/shell.qml > /dev/null 2>&1 &
shell_pid=$!

sleep 5
shell_wid=$(xdotool search --pid $shell_pid)
xdotool set_window --classname "qs-topbar" --class "qs-topbar" $shell_wid

