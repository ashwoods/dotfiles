#! /usr/bin/env bash

# Two stage recursive init script
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

system_type=$(uname -s)

function install_homebrew() {
  # install homebrew if it's missing
  if ! command -v brew >/dev/null 2>&1; then
    echo "Installing homebrew"
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ "$system_type" = "Linux" ]; then
       grep -qxF 'brew' "${HOME}/.profile" || echo 'eval "$($(which brew) shellenv)' >> "${HOME}/.profile"
       eval "$("$(which brew)" shellenv)"
    fi
  fi
    # always recommended to have a recent gcc
  brew install gcc
  brew install mas
  brew install yadm
}

function install_cryfs() {
  brew install --cask macfuse
  brew install cryfs/tap/cryfs
  cryfs ~/Documents/.sync/ssh ~/.ssh
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
