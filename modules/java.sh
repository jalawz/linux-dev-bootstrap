#!/usr/bin/env bash

install_sdkman_if_needed() {
  if [ ! -d "$HOME/.sdkman" ]; then
    curl -fsSL https://get.sdkman.io | bash
  fi

  # shellcheck disable=SC1090
  source "$HOME/.sdkman/bin/sdkman-init.sh"
}

install_profile_java() {
  local java_candidate="${JAVA_SDKMAN_CANDIDATE:-21.0.6-zulu}"

  log "Installing Java profile with SDKMAN..."
  install_java_prereqs
  install_sdkman_if_needed

  sdk install java "$java_candidate" || warn "Could not install java candidate '$java_candidate'. Set JAVA_SDKMAN_CANDIDATE and retry."
  sdk install maven || true
  sdk install gradle || true

  log "Java profile complete."
}
