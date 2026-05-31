{ pkgs, ... }:
{
  programs.fish = {
    enable = true;

    # config.fish
    interactiveShellInit = ''
      if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
        source /nix/var/nix/profiles/default/etc/profile.d/nix.fish
      end

      fenv source ~/.nix-profile/etc/profile.d/hm-session-vars.sh
      zoxide init fish | source
      set -gx LS_COLORS "$LS_COLORS:ow=0:tw=0"
      set -g fish_greeting

      # Starship
      if test "$TERM" != "linux"
        set -x STARSHIP_CONFIG ~/.config/bspwm/apps/starship/default.toml
        starship init fish | source
      end
    '';

    # aliases
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

    # functions
    functions = {
      aevum = {
        body = ''
          set -l AEVUM_DIR "$HOME/.config/aevum"
          set -l INSTALLER "$AEVUM_DIR/cli/installer"
          set -l SUBCMD "$AEVUM_DIR/cli/subcommands"

          switch "$argv[1]"
            case '' --help -h help
              if test "$argv[1]" = ""
                cd $AEVUM_DIR
                return
              end
              echo ""
              echo "  Usage: aevum <command> [args]"
              echo ""
              echo "  (no args)                  cd into ~/.config/aevum"
              echo "  deps <args>                run deps.sh"
              echo "  link-config <args>         run config-linker.sh"
              echo "  link-local <args>          run local-linker.sh"
              echo "  srcrec <args>              run srcrec.sh"
              echo "  help                       show this message"
              echo ""
            case deps
              bash $INSTALLER/deps.sh $argv[2..]
            case link-config
              bash $INSTALLER/config-linker.sh $argv[2..]
            case link-local
              bash $INSTALLER/local-linker.sh $argv[2..]
            case srcrec
              bash $SUBCMD/srcrec.sh $argv[2..]
            case '*'
              echo "  ✗  Unknown command: $argv[1]"
              echo "     Run 'aevum help' for usage"
              return 1
          end
        '';
      };

      fish_greeting = {
        body = ''
          set_color "white"
          figlet -f slant "Aevum"
          set_color normal
        '';
      };

      initbspwm = {
        body = ''
          exec startx 1> ~/.startx.log 2>&1
        '';
      };

      notify-send = {
        body = ''
          xdo raise -N "qs-notify"
          xdo raise -N "qs-powermenu"
          /usr/bin/notify-send $argv
        '';
      };

      thunar_pseudo = {
        body = ''
          bspc rule -a Thunar --one-shot state=pseudo_tiled
          thunar &
          set window_id_thun (xdotool search --sync --class Thunar | tail -1)
          xdotool windowsize $window_id_thun 1000 600
        '';
      };

      wallpicker = {
        body = ''
          qs -p ~/.config/bspwm/apps/wallpicker/shell.qml
        '';
      };

      fenv = {
        body = ''
          if count $argv >/dev/null
            if string trim -- $argv | string length -q
              fenv.main $argv
              return $status
            end
            return 0
          else
            echo (set_color red)'error:' (set_color normal)'parameter missing'
            echo (set_color cyan)'usage:' (set_color normal)'fenv <bash command>'
            return 23
          end
        '';
      };

      # TTY vs GUI aliases
      ls = {
        body = ''
          if test "$TERM" = "linux"
            command ls $argv
          else
            eza --icons $argv
          end
        '';
      };

      ll = {
        body = ''
          if test "$TERM" = "linux"
            command ls -l $argv
          else
            eza --icons -l $argv
          end
        '';
      };

      la = {
        body = ''
          if test "$TERM" = "linux"
            command ls -la $argv
          else
            eza --icons -la $argv
          end
        '';
      };
    };

    # plugins
    plugins = [
      {
        name = "foreign-env";
        src = pkgs.fishPlugins.foreign-env.src;
      }
    ];
  };
}
