#!/usr/bin/env bash

install_profile_node() {
  log "Installing Node.js profile..."
  install_node_prereqs

  if [ ! -d "$HOME/.nvm" ]; then
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  fi

  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1090
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

  if ! command_exists nvm; then
    error "nvm is not available in this shell. Re-run the script in a new shell."
    return 1
  fi

  nvm install --lts
  nvm use --lts

  if command_exists corepack; then
    corepack enable
    corepack prepare pnpm@latest --activate
  fi

  log "Node.js profile complete."
}
