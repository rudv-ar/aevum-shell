{ pkgs, ... }:
{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
        source /nix/var/nix/profiles/default/etc/profile.d/nix.fish
      end

      fenv source ~/.nix-profile/etc/profile.d/hm-session-vars.sh
      zoxide init fish | source
      set -gx LS_COLORS "$LS_COLORS:ow=0:tw=0"
      set -g fish_greeting

      if test "$TERM" != "linux"
        set -x STARSHIP_CONFIG ~/.config/bspwm/apps/starship/default.toml
        starship init fish | source
      end
    '';

    shellAliases = {
      grep = "grep --color=auto";
      cdir = "cd ~/Workspace/C";
      git_downloads = "cd ~/Downloads/Git";
      btop = "btop --force-utf";
      workspace = "cd ~/Workspace";
      github = "cd ~/Workspace/Github";
      gs = "git switch";
      gb = "git branch";
      ga = "git add .";
      gc = "git commit -m";
      gm = "git merge";
      gp = "git push";
    };

    functions = {
      fish_greeting.body = ''
        set_color "white"
        figlet -f slant "Aevum"
        set_color normal
      '';

      initbspwm.body = ''
        exec startx 1> ~/.startx.log 2>&1
      '';

      notify-send.body = ''
        xdo raise -N "qs-notify"
        xdo raise -N "qs-powermenu"
        /usr/bin/notify-send $argv
      '';

      thunar_pseudo.body = ''
        bspc rule -a Thunar --one-shot state=pseudo_tiled
        thunar &
        set window_id_thun (xdotool search --sync --class Thunar | tail -1)
        xdotool windowsize $window_id_thun 1000 600
      '';

      wallpicker.body = ''
        qs -p ~/.config/bspwm/apps/wallpicker/shell.qml
      '';

      ls.body = ''
        if test "$TERM" = "linux"
          command ls $argv
        else
          eza --icons $argv
        end
      '';

      ll.body = ''
        if test "$TERM" = "linux"
          command ls -l $argv
        else
          eza --icons -l $argv
        end
      '';

      la.body = ''
        if test "$TERM" = "linux"
          command ls -la $argv
        else
          eza --icons -la $argv
        end
      '';
    };

    plugins = [
      {
        name = "foreign-env";
        src = pkgs.fishPlugins.foreign-env.src;
      }
    ];
  };

  # aevum function as a separate file to avoid Nix string escaping issues
  home.file.".config/fish/functions/aevum.fish".source =
    ../config/fish/functions/aevum.fish;

  # fenv functions
  home.file.".config/fish/functions/fenv.fish".source =
    ../config/fish/functions/fenv.fish;

  home.file.".config/fish/functions/fenv.main.fish".source =
    ../config/fish/functions/fenv.main.fish;
}
