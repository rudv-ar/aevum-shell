#!/bin/bash
bspc subscribe node_add node_remove node_focus desktop_focus | while read -r _; do
  xdo raise -N Plank
  xdo raise -N "qs-shell"
done &
