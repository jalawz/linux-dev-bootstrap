#!/bin/bash

set -e

configurar_git_global() {
    local git_name="${GIT_USER_NAME:-}"
    local git_email="${GIT_USER_EMAIL:-}"

    if [ -z "$git_name" ]; then
        read -rp "Git user.name (deixe vazio para pular): " git_name
    fi

    if [ -z "$git_email" ]; then
        read -rp "Git user.email (deixe vazio para pular): " git_email
    fi

    if [ -n "$git_name" ] && [ -n "$git_email" ]; then
        git config --global user.name "$git_name"
        git config --global user.email "$git_email"
        git config --global init.defaultBranch main
        echo "✅ Identidade Git global configurada!"
    else
        echo "ℹ️ Configuração de Git ignorada."
    fi
}

# Verifica se é Arch/Manjaro
if ! grep -qi "arch\|manjaro" /etc/os-release; then
    echo "🚫 Este script é exclusivo para Arch Linux/Manjaro."
    exit 1
fi

# Funções de instalação individuais
atualizar_sistema() {
    echo "🔄 Atualizando sistema..."
    sudo pacman -Syu --noconfirm
    echo "✅ Sistema atualizado!"
}

instalar_pacotes_base() {
    echo "📦 Instalando pacotes base (git, wget, curl, etc)..."
    sudo pacman -S --noconfirm zsh git wget curl python-pip base-devel
    configurar_git_global
    echo "✅ Pacotes base instalados!"
}

instalar_brave() {
    echo "🦁 Instalando Brave Browser..."
    yay -S --noconfirm brave-browser
    echo "✅ Brave instalado!"
}

instalar_chrome() {
    echo "🌐 Instalando Google Chrome..."
    yay -S --noconfirm google-chrome
    echo "✅ Chrome instalado!"
}

instalar_vscode() {
    echo "💻 Instalando VS Code..."
    yay -S --noconfirm visual-studio-code-bin
    echo "✅ VS Code instalado!"
}

instalar_ohmyzsh() {
    echo "🐚 Instalando Oh My Zsh..."
    if [ "$SHELL" != "/bin/zsh" ]; then
        chsh -s /bin/zsh
    fi
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        echo "⚠️ Reinicie o terminal ou rode 'zsh' para aplicar o Zsh."
    else
        echo "ℹ️ Oh My Zsh já está instalado."
    fi
    echo "✅ Oh My Zsh configurado!"
}

instalar_docker() {
    echo "🐳 Instalando Docker..."
    sudo pacman -S --noconfirm docker
    sudo systemctl enable --now docker
    sudo usermod -aG docker "$USER"
    echo "⚠️ Adicionado '$USER' ao grupo docker. Reinicie a sessão para aplicar."
    echo "✅ Docker instalado!"
}

instalar_java() {
    echo "☕ Instalando SDKMAN e Java 21 Azul Zulu..."
    if [ ! -d "$HOME/.sdkman" ]; then
        curl -s "https://get.sdkman.io" | bash
        source "$HOME/.sdkman/bin/sdkman-init.sh"
    else
        source "$HOME/.sdkman/bin/sdkman-init.sh"
    fi
    sdk install java 21.0.6-zulu
    echo "✅ Java instalado via SDKMAN!"
}

instalar_node() {
    echo "🟢 Instalando NVM e Node.js LTS..."
    if [ ! -d "$HOME/.nvm" ]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    fi
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
    echo "✅ Node.js instalado via NVM!"
}

instalar_virtualenvwrapper() {
    echo "🐍 Instalando virtualenvwrapper..."
    pip install --user virtualenvwrapper
    
    echo "📝 Configurando virtualenvwrapper no .zshrc..."
    VENV_CONFIG="
# Virtualenvwrapper config
export WORKON_HOME=\$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
source \$HOME/.local/bin/virtualenvwrapper.sh
"
    if ! grep -q "virtualenvwrapper.sh" ~/.zshrc; then
        echo "$VENV_CONFIG" >> ~/.zshrc
    fi
    echo "✅ virtualenvwrapper instalado e configurado!"
}

instalar_flatpak_apps() {
    echo "📦 Instalando Flatpak e repositório Flathub..."
    sudo pacman -S --noconfirm flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    # Lista de aplicativos Flatpak
    local apps=(
        "io.github.getnf.embellish"
        "com.rtosta.zapzap"
        "com.obsproject.Studio"
        "org.duckstation.DuckStation"
        "org.ppsspp.PPSSPP"
        "com.heroicgameslauncher.hgl"
        "net.lutris.Lutris"
        "net.pcsx2.PCSX2"
        "com.discordapp.Discord"
        "org.telegram.desktop"
        "com.getpostman.Postman"
        "io.dbeaver.DBeaverCommunity"
        "org.gnome.meld"
        "io.httpie.Httpie"
    )

    echo "🔄 Instalando apps via Flatpak (um por um)..."
    for app in "${apps[@]}"; do
        echo -e "\n🔍 Instalando $app..."
        if flatpak install -y flathub "$app"; then
            echo "✅ $app instalado com sucesso!"
        else
            echo "⚠️ Falha ao instalar $app"
        fi
    done

    echo -e "\n✅ Todos os apps Flatpak foram processados!"
}

instalar_gnome_tweaks() {
    echo "🎨 Instalando GNOME Tweaks..."
    sudo pacman -S --noconfirm gnome-tweaks gnome-shell-extensions
    echo "✅ GNOME Tweaks instalado!"
}

configurar_powerlevel10k() {
    # Verifica se é Manjaro GNOME (que já vem com p10k configurado)
    if grep -qi "manjaro" /etc/os-release && [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; then
        echo "ℹ️ Manjaro GNOME detectado: Powerlevel10k já está configurado por padrão."
        return
    fi

    echo "🎨 Configurando Powerlevel10k (estilo Manjaro)..."
    
    # Instala o Powerlevel10k (via Oh My Zsh)
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    fi

    # Define o tema no .zshrc
    sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

    # Configuração automática (sem wizard)
    cat > ~/.p10k.zsh << 'EOL'
# Config pré-definida (estilo Manjaro simplificado)
if [[ -o interactive ]]; then
    source ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme

    # Prompt style (Rainbow = similar ao Manjaro)
    typeset -g POWERLEVEL9K_MODE=nerdfont-complete
    typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
    typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon dir vcs)
    typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status time)
    typeset -g POWERLEVEL9K_COLOR_SCHEME=dark
    typeset -g POWERLEVEL9K_DIR_FOREGROUND=15
    typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=red
    typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=yellow
    typeset -g POWERLEVEL9K_TIME_FORMAT="%D{%H:%M}"
fi
EOL

    # Baixa e instala a fonte Meslo Nerd Font
    echo "📖 Instalando Meslo Nerd Font..."
    mkdir -p ~/.local/share/fonts
    cd ~/.local/share/fonts
    curl -fsSL -O "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
    curl -fsSL -O "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf"
    curl -fsSL -O "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf"
    curl -fsSL -O "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf"
    fc-cache -f -v > /dev/null

    echo "✅ Powerlevel10k configurado! Reinicie o terminal."
}

# Verifica se o yay está instalado
check_yay() {
    if ! command -v yay &> /dev/null; then
        echo "🛠️ Instalando yay (AUR helper)..."
        sudo pacman -S --needed --noconfirm git base-devel
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay
        makepkg -si --noconfirm
        cd ~
        echo "✅ yay instalado!"
    fi
}

# Menu interativo completo
while true; do
    clear
    echo -e "\n===== MENU DE INSTALAÇÃO (ARCH/MANJARO) ====="
    echo "1) Atualizar sistema"
    echo "2) Instalar pacotes base (git, wget, curl, etc)"
    echo "3) Instalar navegadores"
    echo "4) Instalar VS Code"
    echo "5) Instalar Oh My Zsh"
    echo "6) Instalar Docker"
    echo "7) Instalar Java (via SDKMAN)"
    echo "8) Instalar Node.js (via NVM)"
    echo "9) Instalar Python virtualenvwrapper"
    echo "10) Instalar Flatpak e apps"
    echo "11) Instalar GNOME Tweaks (se GNOME estiver instalado)"
    echo "12) Configurar Powerlevel10k (exceto Manjaro GNOME)"
    echo "13) Instalar TUDO (executa todas as opções acima)"
    echo "0) Sair"
    echo "--------------------------------------"
    read -rp "Escolha uma opção (0-13): " opcao

    case $opcao in
        1) atualizar_sistema ;;
        2) instalar_pacotes_base ;;
        3) 
            check_yay
            echo -e "\n--- NAVEGADORES ---"
            echo "1) Brave Browser"
            echo "2) Google Chrome"
            echo "3) Ambos"
            read -rp "Escolha (1-3): " nav_opcao
            case $nav_opcao in
                1) instalar_brave ;;
                2) instalar_chrome ;;
                3) instalar_brave; instalar_chrome ;;
                *) echo "Opção inválida." ;;
            esac
            ;;
        4) 
            check_yay
            instalar_vscode 
            ;;
        5) instalar_ohmyzsh ;;
        6) instalar_docker ;;
        7) instalar_java ;;
        8) instalar_node ;;
        9) instalar_virtualenvwrapper ;;
        10) instalar_flatpak_apps ;;
        11) instalar_gnome_tweaks ;;
        12) configurar_powerlevel10k ;;
        13)
            check_yay
            echo "⚠️ Instalando TODOS os componentes..."
            atualizar_sistema
            instalar_pacotes_base
            instalar_brave
            instalar_chrome
            instalar_vscode
            instalar_ohmyzsh
            instalar_docker
            instalar_java
            instalar_node
            instalar_virtualenvwrapper
            instalar_flatpak_apps
            instalar_gnome_tweaks
            configurar_powerlevel10k
            echo "✅ TODOS os componentes instalados!"
            ;;
        0) echo "Saindo..."; exit 0 ;;
        *) echo "Opção inválida. Tente novamente." ;;
    esac
    
    read -rp "Pressione Enter para continuar..."
done
