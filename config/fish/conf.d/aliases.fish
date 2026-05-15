# ~/.config/fish/conf.d/aliases.fish
#
# Detect TTY vs GUI
if test "$TERM" = "linux"
	# TTY config
	alias l='ls'
	alias ll='ls -l'
	alias la='ls -la'
else
	# GUI Alacritty Config
	alias ls='eza --icons'
	alias ll='eza --icons -l'
	alias la='eza --icons -la'
end

alias grep='grep --color=auto'
alias cdir='cd ~/Workspace/C'
alias git_downloads='cd ~/Downloads/Git'
alias btop='btop --force-utf'
alias workspace='cd ~/Workspace'
alias github='cd ~/Workspace/Github'
alias aevum='cd ~/.config/aevum'

# git aliases
alias gs='git switch'
alias gb='git branch'
alias ga='git add .'
alias gc='git commit -m'
alias gm='git merge'
