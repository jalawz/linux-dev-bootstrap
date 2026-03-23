#!/usr/bin/env bash

install_sdkman_if_needed() {
  local sdkman_installer

  if [ ! -d "$HOME/.sdkman" ]; then
    sdkman_installer="$(mktemp)"
    if ! curl -fsSL https://get.sdkman.io -o "$sdkman_installer"; then
      rm -f "$sdkman_installer"
      error "Failed to download SDKMAN installer."
      return 1
    fi
    if ! bash "$sdkman_installer"; then
      rm -f "$sdkman_installer"
      error "Failed to run SDKMAN installer."
      return 1
    fi
    rm -f "$sdkman_installer"
  fi

  # shellcheck disable=SC1090,SC1091
  source "$HOME/.sdkman/bin/sdkman-init.sh"
}

install_profile_java() {
  local java_candidate="${JAVA_SDKMAN_CANDIDATE:-21.0.6-zulu}"

  log "Installing Java profile with SDKMAN..."
  install_java_prereqs
  install_sdkman_if_needed

  sdk install java "$java_candidate" || warn "Could not install java candidate '$java_candidate'. Set JAVA_SDKMAN_CANDIDATE and retry."
  if ! sdk install maven; then
    warn "Could not install Maven with SDKMAN."
  fi
  if ! sdk install gradle; then
    warn "Could not install Gradle with SDKMAN."
  fi

  log "Java profile complete."
}
