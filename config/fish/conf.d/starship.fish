
# Detect TTY vs GUI

if test "$TERM" = "linux"
	echo ""
else
	set -x STARSHIP_CONFIG ~/.config/bspwm/apps/starship/default.toml
	starship init fish | source
end


