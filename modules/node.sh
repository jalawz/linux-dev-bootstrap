#!/usr/bin/env bash

install_profile_node() {
  local nvm_installer

  log "Installing Node.js profile..."
  install_node_prereqs

  if [ ! -d "$HOME/.nvm" ]; then
    nvm_installer="$(mktemp)"
    if ! curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh -o "$nvm_installer"; then
      rm -f "$nvm_installer"
      error "Failed to download NVM installer."
      return 1
    fi
    if ! bash "$nvm_installer"; then
      rm -f "$nvm_installer"
      error "Failed to run NVM installer."
      return 1
    fi
    rm -f "$nvm_installer"
  fi

  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1090,SC1091
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
