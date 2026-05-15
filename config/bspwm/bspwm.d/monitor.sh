#!/bin/bash

#set -Eeuo pipefail
#trap 'echo "[ERROR] line $LINENO: $BASH_COMMAND" >&2' ERR

##################################### MONITORS ##########################################
## Manage Monitors and Workspaces
## Default Setup (Set 8 workspaces on each monitor)

workspaces() {
	name=1
	for monitor in $(bspc query -M); do
		bspc monitor "$monitor" -d '1' '2' '3' '4' '5' '6' '7' '8'
		#bspc monitor ${monitor} -n "$name" -d '' '' '' '' '' ''
		(( name++ ))
	done
}


## Two Monitors Setup (Laptop and external monitor, set 4 workspaces on each monitor)
two_monitors_workspaces() {
	# change these values according to your system
	# you can use `xrandr -q` to get the names of monitors
	INTERNAL_MONITOR="eDP"
	EXTERNAL_MONITOR="HDMI-A-0"
	if [[ $(xrandr -q | grep "${EXTERNAL_MONITOR} connected") ]]; then
		bspc monitor "$EXTERNAL_MONITOR" -d '' '' '' ''
		bspc monitor "$INTERNAL_MONITOR" -d '' '' '' ''
		bspc wm -O "$EXTERNAL_MONITOR" "$INTERNAL_MONITOR"
	else
		bspc monitor "$INTERNAL_MONITOR" -d '' '' '' '' '' '' '' ''
	fi
}

## Three Monitors Setup (Laptop and two external monitor, 3-2-3 workspaces)
three_monitors_workspaces() {
	# again, change these values accordingly
	MONITOR_1="eDP"
	MONITOR_2="HDMI-A-0"
	MONITOR_3="HDMI-A-1"
	bspc monitor "$MONITOR_1" -d '' ''
	bspc monitor "$MONITOR_2" -d '' '' ''
	bspc monitor "$MONITOR_3" -d '' '' ''
	bspc wm -O "$MONITOR_2" "$MONITOR_1" "$MONITOR_3"
}

## Uncomment only one function according to your needs

## Apply these in bspwm configurations
