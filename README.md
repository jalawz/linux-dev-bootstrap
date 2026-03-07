# linux-dev-bootstrap

Modular and interactive Linux developer bootstrap for Arch/Manjaro, Fedora, and Ubuntu/Mint.

Former repository name: `new_shell`.

## Highlights

- Single entrypoint with interactive menu (`bootstrap.sh`)
- Modular architecture for easier maintenance
- Distro adapters (`apt`, `dnf`, `pacman`) behind common functions
- Language/tool profiles you can install independently
- Optional non-interactive mode using `--profile`

## Project structure

- `bootstrap.sh`: entrypoint and menu flow
- `lib/common.sh`: shared helpers (distro detection, sudo check, git identity)
- `adapters/`: distro-specific package/install implementations
  - `adapters/ubuntu.sh`
  - `adapters/fedora.sh`
  - `adapters/arch.sh`
- `modules/`: install profiles
  - `modules/core.sh`
  - `modules/docker.sh`
  - `modules/python.sh`
  - `modules/java.sh`
  - `modules/node.sh`
  - `modules/go.sh`
  - `modules/ruby.sh`
- `modules/rust.sh`
- `modules/dotnet.sh`

## Profiles

- `core`: core CLI tools (`git`, `curl`, `jq`, `ripgrep`, `fzf`, `zsh`, etc.)
- `zsh`: Zsh + Oh My Zsh
- `docker`: Docker Engine + Compose plugin/package
- `python`: `pip`, `virtualenv`, `virtualenvwrapper`, `pipx`, `poetry`, `ruff`, `black`, `pytest`
- `java`: SDKMAN + JDK + Maven + Gradle
- `node`: NVM + Node.js LTS + Corepack + pnpm
- `go`: Go + `gopls` + `air` + `golangci-lint`
- `ruby`: Ruby + Bundler + Rails
- `rust`: rustup + `clippy` + `rustfmt`
- `dotnet`: .NET SDK (LTS channel by default) via official installer

## Usage

Interactive mode:

```bash
bash bootstrap.sh
```

In interactive mode, you can select multiple profiles at once, for example: `1,4,6,10`.

Single profile mode:

```bash
bash bootstrap.sh --profile python
```

Install all profiles:

```bash
bash bootstrap.sh --profile all
```

## Optional environment variables

- `GIT_USER_NAME`: sets global git `user.name`
- `GIT_USER_EMAIL`: sets global git `user.email`
- `JAVA_SDKMAN_CANDIDATE`: SDKMAN Java candidate (default: `21.0.6-zulu`)
- `DOTNET_CHANNEL`: .NET install channel (default: `LTS`)

Example:

```bash
export GIT_USER_NAME="Your Name"
export GIT_USER_EMAIL="you@example.com"
export JAVA_SDKMAN_CANDIDATE="21.0.6-zulu"
bash bootstrap.sh --profile java
```

## Important notes

- The scripts require `sudo` privileges.
- Docker group changes require logout/login.
- Some steps use external installers (for example SDKMAN, NVM, rustup, Oh My Zsh).
- Use this on personal/dev machines.

## Legacy scripts

The previous distro-specific scripts are still available:

- `setup_arch.sh`
- `setup_fedora.sh`
- `setup_ubuntu.sh`
- `setup_god.sh`

## Validation

Basic syntax check:

```bash
bash -n bootstrap.sh lib/common.sh adapters/*.sh modules/*.sh setup_arch.sh setup_fedora.sh setup_ubuntu.sh setup_god.sh
```
