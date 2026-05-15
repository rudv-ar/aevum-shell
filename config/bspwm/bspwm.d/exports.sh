#!/bin/bash 

## General ---------------------------------------------------#

## Bspwm config directory
BSPDIR="$HOME/.config/bspwm"

## Export bspwm/bin dir to PATH
export PATH="${PATH}:$BSPDIR/src"
export XDG_CURRENT_DESKTOP='bspwm'

## Run java applications without issues
export _JAVA_AWT_WM_NONREPARENTING=1
#wmname LG3D

QML_XHR_ALLOW_FILE_READ=1

