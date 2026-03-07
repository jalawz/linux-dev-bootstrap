#!/usr/bin/env bash

pkg_update() {
  sudo pacman -Syu --noconfirm
}

pkg_install() {
  sudo pacman -S --noconfirm --needed "$@"
}

install_base_cli_packages() {
  pkg_install ca-certificates curl wget git unzip zip jq ripgrep fd bat fzf zsh base-devel
}

install_python_prereqs() {
  pkg_install python python-pip pipx
}

install_java_prereqs() {
  pkg_install zip unzip curl
}

install_node_prereqs() {
  pkg_install curl
}

install_go_prereqs() {
  pkg_install go
}

install_ruby_prereqs() {
  pkg_install ruby base-devel openssl readline zlib libyaml libffi
}

install_rust_prereqs() {
  pkg_install base-devel curl
}

install_dotnet_prereqs() {
  pkg_install curl ca-certificates
}

install_docker_engine() {
  pkg_install docker docker-compose
  sudo systemctl enable --now docker
  sudo usermod -aG docker "$USER"
}
