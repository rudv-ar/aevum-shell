

if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish 
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish 
  source /nix/var/nix/profiles/default/etc/profile.d/nix.fish  
end

fenv source ~/.nix-profile/etc/profile.d/hm-session-vars.sh
zoxide init fish | source
set -gx LS_COLORS "$LS_COLORS:ow=0:tw=0"
set -g fish_greeting
