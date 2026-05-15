
function thunar_pseudo
	bspc rule -a Thunar --one-shot state=pseudo_tiled
	thunar &
	set window_id_thun (xdotool search --sync --class Thunar | tail -1)
	xdotool windowsize $window_id_thun 1000 600
end
