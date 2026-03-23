#!/usr/bin/env bash

install_profile_rust() {
  local rustup_installer

  log "Installing Rust profile..."
  install_rust_prereqs

  if [ ! -d "$HOME/.cargo" ]; then
    rustup_installer="$(mktemp)"
    if ! curl -sSf https://sh.rustup.rs -o "$rustup_installer"; then
      rm -f "$rustup_installer"
      error "Failed to download rustup installer."
      return 1
    fi
    if ! sh "$rustup_installer" -y; then
      rm -f "$rustup_installer"
      error "Failed to run rustup installer."
      return 1
    fi
    rm -f "$rustup_installer"
  fi

  # shellcheck disable=SC1090,SC1091
  source "$HOME/.cargo/env"
  rustup default stable
  rustup component add clippy rustfmt

  log "Rust profile complete."
}
