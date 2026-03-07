#!/usr/bin/env bash

pkg_update() {
  sudo dnf upgrade -y
}

pkg_install() {
  sudo dnf install -y "$@"
}

install_base_cli_packages() {
  pkg_install ca-certificates curl wget git unzip zip jq ripgrep fd-find bat fzf zsh dnf-plugins-core
}

install_python_prereqs() {
  pkg_install python3 python3-pip python3-devel pipx
}

install_java_prereqs() {
  pkg_install zip unzip curl
}

install_node_prereqs() {
  pkg_install curl
}

install_go_prereqs() {
  pkg_install golang
}

install_ruby_prereqs() {
  pkg_install ruby ruby-devel gcc make openssl-devel readline-devel zlib-devel libyaml-devel libffi-devel
}

install_rust_prereqs() {
  pkg_install gcc gcc-c++ make curl
}

install_dotnet_prereqs() {
  pkg_install curl ca-certificates
}

install_docker_engine() {
  pkg_install dnf-plugins-core
  sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
  pkg_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo systemctl enable --now docker
  sudo usermod -aG docker "$USER"
}
