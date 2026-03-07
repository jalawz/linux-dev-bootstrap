#!/usr/bin/env bash

install_profile_ruby() {
  log "Installing Ruby/Rails profile..."
  install_ruby_prereqs

  if command_exists gem; then
    gem install --user-install bundler
    gem install --user-install rails
    ensure_zshrc_line "export PATH=\$HOME/.local/share/gem/ruby/\$(ruby -e 'print RbConfig::CONFIG[\"ruby_version\"]')/bin:\$PATH"
  else
    warn "RubyGems command not available."
  fi

  log "Ruby/Rails profile complete."
}
