#!/usr/bin/env bash

pkg_update() {
  sudo apt update
}

pkg_install() {
  sudo apt install -y "$@"
}

install_base_cli_packages() {
  pkg_install ca-certificates curl wget git unzip zip jq ripgrep fd-find bat fzf zsh
}

install_python_prereqs() {
  pkg_install python3 python3-pip python3-venv python3-dev pipx
}

install_java_prereqs() {
  pkg_install zip unzip curl
}

install_node_prereqs() {
  pkg_install curl
}

install_go_prereqs() {
  pkg_install golang-go
}

install_ruby_prereqs() {
  pkg_install ruby-full build-essential libssl-dev libreadline-dev zlib1g-dev libyaml-dev libffi-dev
}

install_rust_prereqs() {
  pkg_install build-essential curl
}

install_dotnet_prereqs() {
  pkg_install curl ca-certificates
}

install_docker_engine() {
  pkg_install ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  printf 'deb [arch=%s signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu %s stable\n' \
    "$(dpkg --print-architecture)" "$(. /etc/os-release && printf '%s' "$VERSION_CODENAME")" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  pkg_update
  pkg_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo systemctl enable --now docker
  sudo usermod -aG docker "$USER"
}
