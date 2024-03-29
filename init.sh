#! /usr/bin/env bash

# Add the cryfs secret to the login keychain `security add-generic-password -s "cryfs-ssh" -a "ashwoods" -w`
# curl https://dot.shashi.to/init.sh | bash -s 

# Enable xtrace if the DEBUG environment variable is set
if [[ ${DEBUG-} =~ ^1|yes|true$ ]]; then
    set -o xtrace # Trace the execution of the script (debug)
fi

# Only enable these shell behaviours if we're not being sourced
# Approach via: https://stackoverflow.com/a/28776166/8787985
if ! (return 0 2>/dev/null); then
    # A better class of script...
    set -o errexit  # Exit on most errors (see the manual)
    set -o nounset  # Disallow expansion of unset variables
    set -o pipefail # Use last non-zero exit code in a pipeline
fi

# Enable errtrace or the error trap handler will not work as expected
set -o errtrace # Ensure the error trap handler is inherited

function install_homebrew() {
  # install homebrew if it's missing
  if ! command -v brew >/dev/null 2>&1; then
    echo "Installing homebrew"
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  # always recommended to have a recent gcc
  eval "$(/opt/homebrew/bin/brew shellenv)"
  brew install gcc
  brew install mas
  brew install yadm
}

function install_cryfs() {
  export CRYFS_FRONTEND=noninteractive
  eval "$(/opt/homebrew/bin/brew shellenv)"
  SECRET=$(security find-generic-password -s "cryfs-ssh" -a "ashwoods" -w)
  brew install --cask macfuse
  brew install cryfs/tap/cryfs
  echo "$SECRET" | cryfs ~/Documents/Sync/ssh ~/.ssh
}

function install_dotfiles {
  yadm clone git@github.com:ashwoods/dotfiles.git
}

function main() {
    if [ $# -eq 0 ]; then
      install_homebrew
      install_cryfs
      install_dotfiles
    else
      set -ex
      "$@"
    fi
}

# Invoke main with args if not sourced
# Approach via: https://stackoverflow.com/a/28776166/8787985
if ! (return 0 2>/dev/null); then
    main "$@"
fi
