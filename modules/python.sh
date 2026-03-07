#!/usr/bin/env bash

install_profile_python() {
  log "Installing Python profile..."
  install_python_prereqs

  python3 -m pip install --user --upgrade pip
  python3 -m pip install --user virtualenv virtualenvwrapper

  if command_exists pipx; then
    pipx ensurepath || true
    pipx install poetry --force
    pipx install ruff --force
    pipx install black --force
    pipx install pytest --force
  else
    warn "pipx not found after install; skipping pipx tools."
  fi

  ensure_zshrc_line "export WORKON_HOME=\$HOME/.virtualenvs"
  ensure_zshrc_line "export VIRTUALENVWRAPPER_PYTHON=$(command -v python3)"
  ensure_zshrc_line "source \$HOME/.local/bin/virtualenvwrapper.sh"

  log "Python profile complete."
}
