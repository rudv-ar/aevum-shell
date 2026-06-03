#!/bin/fish
function notify-send
  xdo raise -N "qs-notify"
  /usr/bin/notify-send $argv 
end
