#!/usr/bin/env bash

install_profile_rust() {
  log "Installing Rust profile..."
  install_rust_prereqs

  if [ ! -d "$HOME/.cargo" ]; then
    curl https://sh.rustup.rs -sSf | sh -s -- -y
  fi

  # shellcheck disable=SC1090
  source "$HOME/.cargo/env"
  rustup default stable
  rustup component add clippy rustfmt

  log "Rust profile complete."
}
