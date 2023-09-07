/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install git
brew install gh
brew install exa
brew install jq
brew install powerlevel10k
echo "source $HOMEBREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme" >>~/.zshrc

brew install derailed/k9s/k9s
brew install grpcurl
