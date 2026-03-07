#!/usr/bin/env bash

install_profile_go() {
  log "Installing Go profile..."
  install_go_prereqs

  if command_exists go; then
    go install golang.org/x/tools/gopls@latest
    go install github.com/air-verse/air@latest
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
    ensure_zshrc_line "export PATH=\$PATH:\$(go env GOPATH)/bin"
  else
    warn "Go is not available after package installation."
  fi

  log "Go profile complete."
}
