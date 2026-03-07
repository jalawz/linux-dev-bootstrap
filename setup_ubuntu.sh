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

# Verifica se é Ubuntu/Mint
if ! grep -qi "ubuntu\|mint" /etc/os-release; then
    echo "🚫 Este script é exclusivo para Ubuntu/Linux Mint."
    exit 1
fi

# Funções de instalação individuais
atualizar_sistema() {
    echo "🔄 Atualizando sistema..."
    sudo apt update && sudo apt upgrade -y
    echo "✅ Sistema atualizado!"
}

instalar_pacotes_base() {
    echo "📦 Instalando pacotes base (git, wget, curl, etc)..."
    sudo apt install -y zsh git wget curl python3-pip software-properties-common fonts-powerline
    configurar_git_global
    echo "✅ Pacotes base instalados!"
}

instalar_brave() {
    echo "🦁 Instalando Brave Browser..."
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt update
    sudo apt install -y brave-browser
    echo "✅ Brave instalado!"
}

instalar_chrome() {
    echo "🌐 Instalando Google Chrome..."
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb
    sudo apt --fix-broken install -y
    echo "✅ Chrome instalado!"
}

instalar_vscode() {
    echo "💻 Instalando VS Code..."
    sudo apt-get install -y wget gpg
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
    sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
    sudo apt update
    sudo apt install -y code
    echo "✅ VS Code instalado!"
}

configurar_p10k_automatico() {
    # Verifica se o Oh My Zsh está instalado
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "❌ Oh My Zsh não está instalado. Por favor, instale primeiro usando a opção 5."
        read -rp "Pressione Enter para voltar ao menu..."
        return 1
    fi

    echo "🎨 Configurando Powerlevel10k automaticamente..."
    
    # Instala o Powerlevel10k
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    fi

    # Configura o tema
    sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

    # Cria configuração automática
    cat > ~/.p10k.zsh << 'EOL'
# Desativa o wizard
typeset -g POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

# Configuração estilo Manjaro
if [[ -o interactive ]]; then
    source ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme

    # Estilo do prompt
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

    # Instala fontes Meslo Nerd Font
    echo "📖 Instalando fontes Meslo Nerd Font..."
    mkdir -p ~/.local/share/fonts
    cd ~/.local/share/fonts
    curl -fsSL -O "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
    curl -fsSL -O "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf"
    curl -fsSL -O "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf"
    curl -fsSL -O "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf"
    fc-cache -f -v > /dev/null

    echo "✅ Powerlevel10k configurado automaticamente!"
    echo "⚠️ Reinicie o terminal ou execute 'zsh' para aplicar as mudanças."
    read -rp "Pressione Enter para voltar ao menu..."
}

instalar_ohmyzsh() {
    echo "🐚 Instalando Oh My Zsh..."
    
    # Pergunta se deseja instalar o Powerlevel10k
    read -rp "Deseja instalar e configurar o Powerlevel10k automaticamente? [s/N]: " instalar_p10k
    
    if [ "$SHELL" != "/bin/zsh" ]; then
        chsh -s /bin/zsh
    fi
    
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        # Instalação não interativa do Oh My Zsh
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        
        # Configura o Powerlevel10k se escolhido
        if [[ "$instalar_p10k" =~ ^[sS]$ ]]; then
            configurar_p10k_automatico
        else
            echo "ℹ️ Powerlevel10k não foi configurado. Você pode configurá-lo depois com a opção 12."
        fi
        
        echo "⚠️ Reinicie o terminal ou rode 'zsh' para aplicar as mudanças."
    else
        echo "ℹ️ Oh My Zsh já está instalado."
        if [[ "$instalar_p10k" =~ ^[sS]$ ]]; then
            configurar_p10k_automatico
        fi
    fi
    
    echo "✅ Oh My Zsh configurado!"
    read -rp "Pressione Enter para voltar ao menu..."
}

instalar_docker() {
    echo "🐳 Instalando Docker..."
    sudo apt install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker "$USER"
    echo "⚠️ Adicionado '$USER' ao grupo docker. Reinicie a sessão para aplicar."
    echo "✅ Docker instalado!"
    read -rp "Pressione Enter para voltar ao menu..."
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
    read -rp "Pressione Enter para voltar ao menu..."
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
    read -rp "Pressione Enter para voltar ao menu..."
}

instalar_virtualenvwrapper() {
    echo "🐍 Instalando virtualenvwrapper..."
    pip3 install --user virtualenvwrapper
    
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
    read -rp "Pressione Enter para voltar ao menu..."
}

instalar_flatpak_apps() {
    echo "📦 Instalando Flatpak e repositório Flathub..."
    sudo apt install -y flatpak
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

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
    read -rp "Pressione Enter para voltar ao menu..."
}

instalar_gnome_tweaks() {
    echo "🎨 Instalando GNOME Tweaks..."
    sudo apt install -y gnome-tweaks gnome-shell-extensions
    echo "✅ GNOME Tweaks instalado!"
    read -rp "Pressione Enter para voltar ao menu..."
}

# Menu interativo completo
while true; do
    clear
    echo -e "\n===== MENU DE INSTALAÇÃO (UBUNTU/MINT) ====="
    echo "1) Atualizar sistema"
    echo "2) Instalar pacotes base (git, wget, curl, etc)"
    echo "3) Instalar navegadores"
    echo "4) Instalar VS Code"
    echo "5) Instalar Oh My Zsh (com opção de Powerlevel10k)"
    echo "6) Instalar Docker"
    echo "7) Instalar Java (via SDKMAN)"
    echo "8) Instalar Node.js (via NVM)"
    echo "9) Instalar Python virtualenvwrapper"
    echo "10) Instalar Flatpak e apps"
    echo "11) Instalar GNOME Tweaks"
    echo "12) Configurar Powerlevel10k (requer Oh My Zsh)"
    echo "13) Instalar TUDO (exceto Powerlevel10k)"
    echo "0) Sair"
    echo "--------------------------------------"
    read -rp "Escolha uma opção (0-13): " opcao

    case $opcao in
        1) atualizar_sistema ;;
        2) instalar_pacotes_base ;;
        3) 
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
        4) instalar_vscode ;;
        5) instalar_ohmyzsh ;;
        6) instalar_docker ;;
        7) instalar_java ;;
        8) instalar_node ;;
        9) instalar_virtualenvwrapper ;;
        10) instalar_flatpak_apps ;;
        11) instalar_gnome_tweaks ;;
        12) configurar_p10k_automatico ;;
        13)
            echo "⚠️ Instalando TODOS os componentes (exceto Powerlevel10k)..."
            atualizar_sistema
            instalar_pacotes_base
            instalar_brave
            instalar_chrome
            instalar_vscode
            instalar_ohmyzsh  # O usuário será perguntado sobre o Powerlevel10k aqui
            instalar_docker
            instalar_java
            instalar_node
            instalar_virtualenvwrapper
            instalar_flatpak_apps
            instalar_gnome_tweaks
            echo "✅ TODOS os componentes instalados!"
            read -rp "Pressione Enter para voltar ao menu..."
            ;;
        0) echo "Saindo..."; exit 0 ;;
        *) 
            echo "Opção inválida. Tente novamente."
            read -rp "Pressione Enter para continuar..."
            ;;
    esac
done
