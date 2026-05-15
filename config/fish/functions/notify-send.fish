#!/bin/fish
function notify-send
  xdo raise -N "qs-notify"
  xdo raise -N "qs-powermenu"
  /usr/bin/notify-send $argv 
end
