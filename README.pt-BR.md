# linux-dev-bootstrap

Idioma: Português (BR) | [English](README.md)

Script modular e interativo para preparar ambiente de desenvolvimento no Linux (Arch/Manjaro, Fedora, Ubuntu/Mint).

Objetivo: ajudar quem esta migrando para Linux a instalar ferramentas de dev de forma simples, sem precisar decorar dezenas de comandos.

English version: `README.md`

## O que este projeto faz

- Detecta automaticamente sua distro
- Mostra um menu interativo com perfis de instalacao
- Permite instalar so o que voce quer (ex.: Python + Docker)
- Tambem funciona em modo direto por parametro (`--profile`)

## Perfis disponiveis

- `core`: ferramentas base (`git`, `curl`, `jq`, `ripgrep`, `fzf`, `zsh`, etc.)
- `zsh`: Zsh + Oh My Zsh
- `docker`: Docker Engine + Compose
- `python`: `pip`, `virtualenv`, `virtualenvwrapper`, `pipx`, `poetry`, `ruff`, `black`, `pytest`
- `java`: SDKMAN + Java + Maven + Gradle
- `node`: NVM + Node LTS + Corepack + pnpm
- `go`: Go + `gopls` + `air` + `golangci-lint`
- `ruby`: Ruby + Bundler + Rails
- `rust`: rustup + `clippy` + `rustfmt`
- `dotnet`: .NET SDK (canal `LTS` por padrao)

## Tutorial rapido (iniciante)

### 1) Clone o repositorio

```bash
git clone git@github.com:jalawz/linux-dev-bootstrap.git
cd linux-dev-bootstrap
```

### 2) Rode em modo interativo

```bash
bash bootstrap.sh
```

Voce nao precisa passar arquivo nenhum como parametro no fluxo normal.

### 3) Escolha no menu

- Para escolher um perfil: digite um numero (ex.: `4` para Python)
- Para escolher varios: use virgula (ex.: `1,3,4`)
- Para instalar tudo: opcao `11`

### 4) Reinicie sessao quando necessario

Algumas ferramentas exigem logout/login para aplicar permissao ou shell padrao (ex.: grupo do Docker e Zsh).

## Uso por parametro (opcional)

```bash
bash bootstrap.sh --profile python
```

Outros exemplos:

```bash
bash bootstrap.sh --profile docker
bash bootstrap.sh --profile dotnet
bash bootstrap.sh --profile all
```

## Variaveis opcionais

- `GIT_USER_NAME`: define `git config --global user.name`
- `GIT_USER_EMAIL`: define `git config --global user.email`
- `JAVA_SDKMAN_CANDIDATE`: versao/candidate do Java no SDKMAN (padrao `21.0.6-zulu`)
- `DOTNET_CHANNEL`: canal de instalacao do .NET (padrao `LTS`)

Exemplo:

```bash
export GIT_USER_NAME="Seu Nome"
export GIT_USER_EMAIL="seu@email.com"
export DOTNET_CHANNEL="LTS"
bash bootstrap.sh --profile dotnet
```

## Estrutura do projeto

- `bootstrap.sh`: entrada principal (menu + execucao)
- `lib/common.sh`: funcoes compartilhadas
- `adapters/`: comandos especificos por distro (`apt`, `dnf`, `pacman`)
- `modules/`: logica de cada perfil (python, java, node, etc.)

## Dicas para quem esta migrando para Linux

- Comece por `core`, depois `docker`, depois sua stack principal
- Nao precisa instalar tudo de uma vez
- Prefira ambientes reproduziveis com Docker para projetos
- Atualize o sistema antes de grandes instalacoes

## Observacoes importantes

- O script usa `sudo`
- Alguns passos usam instaladores oficiais externos (SDKMAN, NVM, rustup, Oh My Zsh, dotnet-install)
- Recomendado para maquina de desenvolvimento pessoal

## Validacao (desenvolvimento do script)

```bash
bash -n bootstrap.sh lib/common.sh adapters/*.sh modules/*.sh
```
