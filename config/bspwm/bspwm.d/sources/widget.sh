#!/bin/bash

# file : widget.sh
# function : sourced by autostart.sh to start widget services

############################################# WIDGET ##############################################
# is widget system enabled?
export is_widget=true

# what widget bar is the system using?
export widget_bar='quickshell'

if [[ "$widget_bar" == "quickshell" && "$is_widget" == "true" ]]; then 
  echo "$widget_bar" > ~/.config/aevum/settings/states/.shell.state
else 
  echo "null"  > ~/.config/aevum/settings/states/.shell.state 
fi
is_plank=false

# [ tip : the other bars include : polybar, eww, quickshell, lemonbar, etc]
