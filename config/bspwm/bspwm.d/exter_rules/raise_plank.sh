#!/bin/bash
bspc subscribe node_add node_remove node_focus desktop_focus | while read -r _; do
  #xdo raise -N "qs-border"
  xdo raise -N Plank
  xdo raise -N "qs-notify"
  xdo raise -N "qs-panes"
  xdo raise -N "qs-topbar"
 
  xdo raise -N "qs-powermenu"


done &
