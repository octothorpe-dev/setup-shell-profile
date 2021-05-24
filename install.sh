#!/bin/sh
#
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/octothorpe-dev/zsh-profile/main/install.sh)"
set -e

# Default settings
ZSH=${ZSH:-~/.personal-shell}
REPO=${REPO:-octothorpe-dev/setup-shell-profile}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
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
    --depth=1 --branch "$BRANCH" "$REMOTE" "$ZSH" || {
    fmt_error "git clone of set-shell-profile repo failed"
    exit 1
  }

  echo
}

setup_zshrc() {
  # Keep most recent old .zshrc at .zshrc.old-profile, and older ones
  # with datestamp of installation that moved them aside, so we never actually
  # destroy a user's original zshrc
  echo "${BLUE}Looking for an existing zsh config...${RESET}"

  # Must use this exact name so uninstall.sh can find it
  OLD_ZSHRC=~/.zshrc.old-profile
  if [ -f ~/.zshrc ] || [ -h ~/.zshrc ]; then
    if [ -e "$OLD_ZSHRC" ]; then
      OLD_OLD_ZSHRC="${OLD_ZSHRC}-$(date +%Y-%m-%d_%H-%M-%S)"
      if [ -e "$OLD_OLD_ZSHRC" ]; then
        fmt_error "$OLD_OLD_ZSHRC exists. Can't back up ${OLD_ZSHRC}"
        fmt_error "re-run the installer again in a couple of seconds"
        exit 1
      fi
      mv "$OLD_ZSHRC" "${OLD_OLD_ZSHRC}"

      echo "${YELLOW}Found old ~/.zshrc.old-profile." \
        "${GREEN}Backing up to ${OLD_OLD_ZSHRC}${RESET}"
    fi
    echo "${YELLOW}Found ~/.zshrc.${RESET} ${GREEN}Backing up to ${OLD_ZSHRC}${RESET}"
    mv ~/.zshrc "$OLD_ZSHRC"
  fi

  echo "${GREEN}Using the Oh My Zsh template file and adding it to ~/.zshrc.${RESET}"

  cp -f --remove-destination $ZSH/zshrc ~/.zshrc

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

  # Check if we're running on Termux
  case "$PREFIX" in
    *com.termux*) termux=true; zsh=zsh ;;
    *) termux=false ;;
  esac

  if [ "$termux" != true ]; then
    # Test for the right location of the "shells" file
    if [ -f /etc/shells ]; then
      shells_file=/etc/shells
    elif [ -f /usr/share/defaults/etc/shells ]; then # Solus OS
      shells_file=/usr/share/defaults/etc/shells
    else
      fmt_error "could not find /etc/shells file. Change your default shell manually."
      return
    fi

    # Get the path to the right zsh binary
    # 1. Use the most preceding one based on $PATH, then check that it's in the shells file
    # 2. If that fails, get a zsh path from the shells file, then check it actually exists
    if ! zsh=$(command -v zsh) || ! grep -qx "$zsh" "$shells_file"; then
      if ! zsh=$(grep '^/.*/zsh$' "$shells_file" | tail -1) || [ ! -f "$zsh" ]; then
        fmt_error "no zsh binary found or not present in '$shells_file'"
        fmt_error "change your default shell manually."
        return
      fi
    fi
  fi

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
  setup_zshrc
  setup_shell

  printf %s "${GREEN}Sucess!!"
  printf %s "$RESET"

  if [ $RUNZSH = no ]; then
    echo "${YELLOW}Run zsh to try it out.${RESET}"
    exit
  fi

  exec zsh -l
}

main "$@"