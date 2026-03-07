#!/usr/bin/env bash

install_profile_dotnet() {
  local dotnet_channel="${DOTNET_CHANNEL:-LTS}"
  local install_dir="$HOME/.dotnet"
  local installer_script="/tmp/dotnet-install.sh"

  log "Installing .NET profile..."
  install_dotnet_prereqs

  curl -fsSL https://dot.net/v1/dotnet-install.sh -o "$installer_script"
  chmod +x "$installer_script"
  "$installer_script" --channel "$dotnet_channel" --install-dir "$install_dir"

  ensure_zshrc_line "export DOTNET_ROOT=\$HOME/.dotnet"
  ensure_zshrc_line "export PATH=\$HOME/.dotnet:\$HOME/.dotnet/tools:\$PATH"

  export DOTNET_ROOT="$install_dir"
  export PATH="$install_dir:$install_dir/tools:$PATH"

  if command_exists dotnet; then
    dotnet --info >/dev/null 2>&1 || true
  fi

  log ".NET profile complete."
}
