# linux-dev-bootstrap

Language: English | [Português (BR)](README.pt-BR.md)

Modular and interactive script to prepare a Linux developer environment (Arch/Manjaro, Fedora, Ubuntu/Mint).

Goal: help people migrating to Linux install dev tools quickly, without memorizing dozens of commands.

Portuguese version: `README.pt-BR.md`

## What this project does

- Auto-detects your distro
- Shows an interactive installation menu
- Lets you install only what you need (for example: Python + Docker)
- Also supports direct mode with `--profile`

## Available profiles

- `core`: base tools (`git`, `curl`, `jq`, `ripgrep`, `fzf`, `zsh`, etc.)
- `zsh`: Zsh + Oh My Zsh
- `docker`: Docker Engine + Compose
- `python`: `pip`, `virtualenv`, `virtualenvwrapper`, `pipx`, `poetry`, `ruff`, `black`, `pytest`
- `java`: SDKMAN + Java + Maven + Gradle
- `node`: NVM + Node LTS + Corepack + pnpm
- `go`: Go + `gopls` + `air` + `golangci-lint`
- `ruby`: Ruby + Bundler + Rails
- `rust`: rustup + `clippy` + `rustfmt`
- `dotnet`: .NET SDK (default channel: `LTS`)

## Quick start (beginner friendly)

### 1) Clone this repository

```bash
git clone git@github.com:jalawz/linux-dev-bootstrap.git
cd linux-dev-bootstrap
```

### 2) Run interactive mode

```bash
bash bootstrap.sh
```

You do not need to pass any file as a parameter in the normal flow.

### 3) Pick from the menu

- Single profile: type one number (example: `4` for Python)
- Multiple profiles: comma-separated values (example: `1,3,4`)
- Install everything: option `11`

### 4) Re-login when needed

Some tools require logout/login to apply shell or group changes (for example Docker group and Zsh default shell).

## Optional direct mode (without menu)

```bash
bash bootstrap.sh --profile python
```

Non-interactive examples:

```bash
bash bootstrap.sh --non-interactive --profile docker
bash bootstrap.sh --yes
```

Other examples:

```bash
bash bootstrap.sh --profile docker
bash bootstrap.sh --profile dotnet
bash bootstrap.sh --profile all
```

## Optional environment variables

- `GIT_USER_NAME`: sets `git config --global user.name`
- `GIT_USER_EMAIL`: sets `git config --global user.email`
- `JAVA_SDKMAN_CANDIDATE`: Java SDKMAN candidate (default `21.0.6-zulu`)
- `DOTNET_CHANNEL`: .NET install channel (default `LTS`)
- `DEBUG`: set to `1` to enable debug logs

Example:

```bash
export GIT_USER_NAME="Your Name"
export GIT_USER_EMAIL="you@example.com"
export DOTNET_CHANNEL="LTS"
export DEBUG="1"
bash bootstrap.sh --profile dotnet
```

## Project structure

- `bootstrap.sh`: main entrypoint (menu + execution)
- `lib/common.sh`: shared helpers
- `adapters/`: distro-specific package commands (`apt`, `dnf`, `pacman`)
- `modules/`: profile-specific installation logic

## Migration tips (new Linux users)

- Start with `core`, then `docker`, then your main language stack
- Do not install everything at once unless you really need it
- Prefer reproducible environments with Docker for projects
- Keep your system updated before big install sessions

## Important notes

- The script uses `sudo`
- Some steps use official external installers (SDKMAN, NVM, rustup, Oh My Zsh, dotnet-install)
- Recommended for personal development machines

## Validation (project maintenance)

```bash
bash -n bootstrap.sh lib/common.sh adapters/*.sh modules/*.sh
```
