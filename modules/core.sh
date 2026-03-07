#!/usr/bin/env bash

install_profile_core_tools() {
  log "Installing core CLI tools..."
  pkg_update
  install_base_cli_packages
  configure_git_identity
  log "Core CLI tools installed."
}

install_profile_zsh_ohmyzsh() {
  log "Installing Zsh + Oh My Zsh..."

  if [ "${SHELL:-}" != "$(command -v zsh)" ]; then
    chsh -s "$(command -v zsh)"
    warn "Default shell changed to zsh. Log out and back in to apply globally."
  fi

  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  else
    log "Oh My Zsh already installed."
  fi

  log "Zsh profile complete."
}
