#!/usr/bin/env bash

set -euo pipefail

log() {
  printf '[%s] [INFO] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

warn() {
  printf '[%s] [WARN] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

error() {
  printf '[%s] [ERROR] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >&2
}

debug() {
  if [ "${DEBUG:-0}" = "1" ]; then
    printf '[%s] [DEBUG] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
  fi
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

is_interactive() {
  [ -t 0 ] && [ -t 1 ]
}

require_sudo() {
  if ! command_exists sudo; then
    error "sudo is required."
    exit 1
  fi

  if ! sudo -v; then
    error "Could not validate sudo credentials."
    exit 1
  fi
}

detect_distro() {
  if [ ! -f /etc/os-release ]; then
    error "Cannot detect distro: /etc/os-release not found."
    exit 1
  fi

  local os_release
  os_release="$(tr '[:upper:]' '[:lower:]' </etc/os-release)"

  if grep -q 'id=manjaro' <<<"$os_release"; then
    # shellcheck disable=SC2034
    DISTRO_FAMILY="arch"
    # shellcheck disable=SC2034
    DISTRO_NAME="manjaro"
  elif grep -q 'id=arch' <<<"$os_release"; then
    # shellcheck disable=SC2034
    DISTRO_FAMILY="arch"
    # shellcheck disable=SC2034
    DISTRO_NAME="arch"
  elif grep -q 'id=fedora' <<<"$os_release"; then
    # shellcheck disable=SC2034
    DISTRO_FAMILY="fedora"
    # shellcheck disable=SC2034
    DISTRO_NAME="fedora"
  elif grep -Eq 'id=ubuntu|id=linuxmint|id_like=.*ubuntu' <<<"$os_release"; then
    # shellcheck disable=SC2034
    DISTRO_FAMILY="ubuntu"
    # shellcheck disable=SC2034
    DISTRO_NAME="ubuntu"
  else
    error "Unsupported distro. Supported: Arch/Manjaro, Fedora, Ubuntu/Mint."
    exit 1
  fi
}

append_line_if_missing() {
  local line="$1"
  local file="$2"

  mkdir -p "$(dirname "$file")"
  touch "$file"

  if ! grep -Fqx "$line" "$file"; then
    printf '%s\n' "$line" >>"$file"
  fi
}

configure_git_identity() {
  local git_name="${GIT_USER_NAME:-}"
  local git_email="${GIT_USER_EMAIL:-}"

  if [ "${NON_INTERACTIVE:-0}" = "1" ] && { [ -z "$git_name" ] || [ -z "$git_email" ]; }; then
    warn "NON_INTERACTIVE=1 and git identity env vars missing; skipping git identity setup."
    return 0
  fi

  if [ -z "$git_name" ] && is_interactive; then
    read -rp "Git user.name (leave empty to skip): " git_name
  fi

  if [ -z "$git_email" ] && is_interactive; then
    read -rp "Git user.email (leave empty to skip): " git_email
  fi

  if [ -n "$git_name" ] && [ -n "$git_email" ]; then
    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    git config --global init.defaultBranch main
    log "Git identity configured."
  else
    warn "Git identity skipped."
  fi
}

ensure_zshrc_line() {
  local line="$1"
  append_line_if_missing "$line" "$HOME/.zshrc"
}
