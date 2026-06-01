function fish_title
    set -l dir (string replace --regex "^$HOME" "~" $PWD)
    if test "$_" != fish
        echo "$_ — $dir"
    else
        echo $dir
    end
end
