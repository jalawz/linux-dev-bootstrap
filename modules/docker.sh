#!/usr/bin/env bash

install_profile_docker() {
  log "Installing Docker..."
  install_docker_engine
  warn "User '$USER' added to docker group. Log out and back in to use Docker without sudo."
  log "Docker profile complete."
}
