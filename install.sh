#!/bin/sh

set -e

# Default settings
ZSH=${ZSH:-~/.personal-shell-config}
REPO=${REPO:-octothorpe-dev/setup-shell-profile}
REMOTE=${REMOTE:-git@github.com:${REPO}.git}
BRANCH=${BRANCH:-main}

command_exists() {
	command -v "$@" >/dev/null 2>&1
}

fmt_error() {
  printf '%sError: %s%s\n' "$BOLD$RED" "$*" "$RESET" >&2
}

fmt_underline() {
  printf '\033[4m%s\033[24m\n' "$*"
}

fmt_code() {
  # shellcheck disable=SC2016 # backtic in single-quote
  printf '`\033[38;5;247m%s%s`\n' "$*" "$RESET"
}

setup_color() {
	# Only use colors if connected to a terminal
	if [ -t 1 ]; then
		RED=$(printf '\033[31m')
		GREEN=$(printf '\033[32m')
		YELLOW=$(printf '\033[33m')
		BLUE=$(printf '\033[34m')
		BOLD=$(printf '\033[1m')
		RESET=$(printf '\033[m')
	else
		RED=""
		GREEN=""
		YELLOW=""
		BLUE=""
		BOLD=""
		RESET=""
	fi
}

setup_git_repos() {
  # Prevent the cloned repository from having insecure permissions. Failing to do
  # so causes compinit() calls to fail with "command not found: compdef" errors
  # for users with insecure umasks (e.g., "002", allowing group writability). Note
  # that this will be ignored under Cygwin by default, as Windows ACLs take
  # precedence over umasks except for filesystems mounted with option "noacl".
  umask g-w,o-w

  echo "${BLUE}Cloning setup-shell-profile...${RESET}"

  command_exists git || {
    fmt_error "git is not installed"
    exit 1
  }

  git clone -c core.eol=lf -c core.autocrlf=false \
    -c fsck.zeroPaddedFilemode=ignore \
    -c fetch.fsck.zeroPaddedFilemode=ignore \
    -c receive.fsck.zeroPaddedFilemode=ignore \
    --depth=1 --branch "$BRANCH" "$REMOTE" "$ZSH/setup-shell-profile" || {
    fmt_error "git clone of set-shell-profile repo failed"
    exit 1
  }

    git clone -c core.eol=lf -c core.autocrlf=false \
    -c fsck.zeroPaddedFilemode=ignore \
    -c fetch.fsck.zeroPaddedFilemode=ignore \
    -c receive.fsck.zeroPaddedFilemode=ignore \
    --depth=1 --branch "master" "https://github.com/zsh-users/zsh-autosuggestions.git" "$ZSH/zsh-autosuggestions" || {
    fmt_error "git clone of zsh-users autosuggestions repo failed"
    exit 1
  }

    git clone -c core.eol=lf -c core.autocrlf=false \
    -c fsck.zeroPaddedFilemode=ignore \
    -c fetch.fsck.zeroPaddedFilemode=ignore \
    -c receive.fsck.zeroPaddedFilemode=ignore \
    --depth=1 --branch "master" "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$ZSH/zsh-syntax-highlighting" || {
    fmt_error "git clone of zsh-users syntax highlighting repo failed"
    exit 1
  }

  echo
}

setup_shell() {
  # If this user's login shell is already "zsh", do not attempt to switch.
  if [ "$(basename -- "$SHELL")" = "zsh" ]; then
    return
  fi

  # If this platform doesn't provide a "chsh" command, bail out.
  if ! command_exists chsh; then
    cat <<EOF
I can't change your shell automatically because this system does not have chsh.
${BLUE}Please manually change your default shell to zsh${RESET}
EOF
    return
  fi

  echo "${BLUE}Time to change your default shell to zsh:${RESET}"

  # Prompt for user choice on changing the default login shell
  printf '%sDo you want to change your default shell to zsh? [Y/n]%s ' \
    "$YELLOW" "$RESET"
  read -r opt
  case $opt in
    y*|Y*|"") echo "Changing the shell..." ;;
    n*|N*) echo "Shell change skipped."; return ;;
    *) echo "Invalid choice. Shell change skipped."; return ;;
  esac

  # We're going to change the default shell, so back up the current one
  if [ -n "$SHELL" ]; then
    echo "$SHELL" > ~/.shell.old-profile
  else
    grep "^$USERNAME:" /etc/passwd | awk -F: '{print $7}' > ~/.shell.old-profile
  fi

  # Actually change the default shell to zsh
  if ! chsh -s "$zsh"; then
    fmt_error "chsh command unsuccessful. Change your default shell manually."
  else
    export SHELL="$zsh"
    echo "${GREEN}Shell successfully changed to '$zsh'.${RESET}"
  fi

  echo
}

main() {
  setup_color

  if ! command_exists zsh; then
    echo "${YELLOW}Zsh is not installed.${RESET} Please install zsh first."
    exit 1
  fi

  if [ -d "$ZSH" ]; then
    echo "${YELLOW}The \$ZSH folder already exists ($ZSH).${RESET}"
    exit 1
  fi

  setup_git_repos
  setup_shell

  printf %s "${GREEN}Sucess!!"
  printf %s "$RESET"

  exec zsh -l
}

main "$@"