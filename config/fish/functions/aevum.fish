# ~/.config/fish/functions/aevum.fish

set -l AEVUM_DIR "$HOME/.config/aevum"
set -l INSTALLER "$AEVUM_DIR/cli/installer"
set -l SUBCMD "$AEVUM_DIR/cli/subcommands"

function aevum
    set -l AEVUM_DIR "$HOME/.config/aevum"
    set -l INSTALLER "$AEVUM_DIR/cli/installer"
    set -l SUBCMD "$AEVUM_DIR/cli/subcommands"

    switch "$argv[1]"
        case '' --help -h help
            if test "$argv[1]" = ''
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
            echo "  theme <args>               run theme.sh"
            echo "  tasker <args>              run tasker.sh"
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

        case theme
            bash $SUBCMD/theme.sh $argv[2..]

        case tasker
            bash $SUBCMD/tasker.sh $argv[2..]

        case '*'
            echo "  ✗  Unknown command: $argv[1]"
            echo "     Run 'aevum help' for usage"
            return 1
    end
end
