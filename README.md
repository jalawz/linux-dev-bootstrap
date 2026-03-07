# new_shell

Interactive Linux post-install scripts for Arch/Manjaro, Fedora, and Ubuntu/Mint.

## Scripts

- `setup_arch.sh`: interactive setup for Arch Linux and Manjaro.
- `setup_fedora.sh`: interactive setup for Fedora.
- `setup_ubuntu.sh`: interactive setup for Ubuntu and Linux Mint.
- `setup_god.sh`: one-shot cross-distro setup that auto-detects distro and runs all steps.

## What gets installed

Depending on the selected options/script:

- Base tools: `zsh`, `git`, `wget`, `curl`, `pip`
- Browsers: Brave, Google Chrome
- Editor: Visual Studio Code
- Shell tools: Oh My Zsh, optional Powerlevel10k
- Dev tools: Docker, SDKMAN + Java, NVM + Node.js LTS, virtualenvwrapper
- Desktop tools: Flatpak + Flathub apps, GNOME tweaks/extensions
- (in `setup_god.sh`) JetBrains Toolbox

## Usage

Run any script with Bash:

```bash
bash setup_ubuntu.sh
```

Or make it executable first:

```bash
chmod +x setup_ubuntu.sh
./setup_ubuntu.sh
```

## Git identity setup

Scripts no longer hardcode Git identity. During base package installation, you can:

- provide values interactively, or
- set env vars before running:

```bash
export GIT_USER_NAME="Your Name"
export GIT_USER_EMAIL="you@example.com"
bash setup_fedora.sh
```

If either value is empty, Git global config is skipped.

## Important notes

- These scripts are intended for personal machine bootstrap.
- They run privileged package operations (`sudo`) and may change shell defaults (`chsh`).
- Docker group membership requires logging out/in after installation.
- Several steps rely on external install scripts (`curl | sh`) and third-party repositories.
- Menu text is currently in Portuguese.

## Validation

Basic syntax check:

```bash
bash -n setup_arch.sh setup_fedora.sh setup_ubuntu.sh setup_god.sh
```
