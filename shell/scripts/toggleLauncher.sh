#!/bin/bash 

PREV_WIN=$(xdotool getactivewindow)


xdotool windowfocus $(xdotool search --class "qs-launcher")
qs -p ~/.config/bspwm/shell/launcher/shell.qml ipc call dock toggle


