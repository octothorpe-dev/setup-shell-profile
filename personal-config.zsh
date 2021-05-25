# Set up the prompt
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
zstyle ':vcs_info:git:*' formats '%F{227}git:(%b)%f'
zstyle ':vcs_info:*' enable git

PROMPT='%(?.%F{green}√.%F{red}?%?)%f %B%F{39}%1~%f%b $vcs_info_msg_0_ %# '

setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# git aliases
alias ga='git add'
alias gb='git branch'
alias gsw='git switch'
alias gswc='git switch -c'
alias grb='git rebase'
alias grbc='git rebase --continue'
alias gst='git status'
alias gcmsg='git commit -m'
alias gp='git push'
alias gup='git pull'

# exa aliases
alias ls='exa'
alias ll='exa -l'
alias lla='exa -la'

# autosuggestions
source ~/.personal-shell-config/zsh-autosuggestions/zsh-autosuggestions.zsh

# syntax highlighting - MUST BE AT BOTTOM!
source ~/.personal-shell-config/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
