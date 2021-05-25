# Set up the prompt
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
zstyle ':vcs_info:git:*' formats '%F{227}git:(%b)%f'
zstyle ':vcs_info:*' enable git

PROMPT='%(?.%F{green}√.%F{red}?%?)%f %B%F{39}%1~%f%b $vcs_info_msg_0_ %# '

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
setopt histignorealldups sharehistory
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

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
