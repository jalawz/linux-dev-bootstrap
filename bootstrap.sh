#!/usr/bin/env bash

set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1091
source "$ROOT_DIR/lib/common.sh"

NON_INTERACTIVE=0
ASSUME_YES=0

on_error() {
  local exit_code="$?"
  error "Execution failed (exit=$exit_code) near line ${BASH_LINENO[0]}: ${BASH_COMMAND}"
  exit "$exit_code"
}

on_interrupt() {
  warn "Execution interrupted by user."
  exit 130
}

trap on_error ERR
trap on_interrupt INT TERM

load_adapter() {
  detect_distro

  case "$DISTRO_FAMILY" in
    ubuntu)
      # shellcheck disable=SC1091
      source "$ROOT_DIR/adapters/ubuntu.sh"
      ;;
    fedora)
      # shellcheck disable=SC1091
      source "$ROOT_DIR/adapters/fedora.sh"
      ;;
    arch)
      # shellcheck disable=SC1091
      source "$ROOT_DIR/adapters/arch.sh"
      ;;
    *)
      error "Unsupported distro family: $DISTRO_FAMILY"
      exit 1
      ;;
  esac

  log "Detected distro: $DISTRO_NAME ($DISTRO_FAMILY)"
}

load_modules() {
  # shellcheck disable=SC1091
  source "$ROOT_DIR/modules/core.sh"
  # shellcheck disable=SC1091
  source "$ROOT_DIR/modules/docker.sh"
  # shellcheck disable=SC1091
  source "$ROOT_DIR/modules/python.sh"
  # shellcheck disable=SC1091
  source "$ROOT_DIR/modules/java.sh"
  # shellcheck disable=SC1091
  source "$ROOT_DIR/modules/node.sh"
  # shellcheck disable=SC1091
  source "$ROOT_DIR/modules/go.sh"
  # shellcheck disable=SC1091
  source "$ROOT_DIR/modules/ruby.sh"
  # shellcheck disable=SC1091
  source "$ROOT_DIR/modules/rust.sh"
  # shellcheck disable=SC1091
  source "$ROOT_DIR/modules/dotnet.sh"
}

run_profile() {
  local profile="$1"

  case "$profile" in
    core)
      install_profile_core_tools
      ;;
    zsh)
      install_profile_zsh_ohmyzsh
      ;;
    docker)
      install_profile_docker
      ;;
    python)
      install_profile_python
      ;;
    java)
      install_profile_java
      ;;
    node)
      install_profile_node
      ;;
    go)
      install_profile_go
      ;;
    ruby)
      install_profile_ruby
      ;;
    rust)
      install_profile_rust
      ;;
    dotnet)
      install_profile_dotnet
      ;;
    all)
      run_profile core
      run_profile zsh
      run_profile docker
      run_profile python
      run_profile java
      run_profile node
      run_profile go
      run_profile ruby
      run_profile rust
      run_profile dotnet
      ;;
    *)
      error "Unknown profile: $profile"
      return 1
      ;;
  esac
}

print_menu() {
  cat <<'EOF'

=== Linux Dev Bootstrap ===
1) Core CLI tools (git, curl, jq, fzf, etc.)
2) Zsh + Oh My Zsh
3) Docker Engine + Compose
4) Python (pip, virtualenv, pipx, poetry, ruff, black, pytest)
5) Java (SDKMAN + JDK + Maven + Gradle)
6) Node.js (NVM + Node LTS + pnpm)
7) Go (Go + gopls + linters)
8) Ruby (Ruby + Bundler + Rails)
9) Rust (rustup + cargo tools)
10) .NET (dotnet SDK via dotnet-install script)
11) Install all profiles
0) Exit
EOF
}

parse_single_menu_choice() {
  local choice="$1"

  case "$choice" in
    1) printf '%s\n' core ;;
    2) printf '%s\n' zsh ;;
    3) printf '%s\n' docker ;;
    4) printf '%s\n' python ;;
    5) printf '%s\n' java ;;
    6) printf '%s\n' node ;;
    7) printf '%s\n' go ;;
    8) printf '%s\n' ruby ;;
    9) printf '%s\n' rust ;;
    10) printf '%s\n' dotnet ;;
    11) printf '%s\n' all ;;
    0) printf '%s\n' exit ;;
    *) printf '%s\n' invalid ;;
  esac
}

parse_menu_choices() {
  local raw_choices="$1"
  local cleaned
  local token
  local parsed
  local output=""

  cleaned="${raw_choices// /}"
  IFS=',' read -ra tokens <<<"$cleaned"

  if [ "${#tokens[@]}" -eq 0 ]; then
    printf '%s\n' invalid
    return
  fi

  for token in "${tokens[@]}"; do
    if [ -z "$token" ]; then
      continue
    fi
    parsed="$(parse_single_menu_choice "$token")"
    if [ "$parsed" = "invalid" ]; then
      printf '%s\n' invalid
      return
    fi
    if [ "$parsed" = "exit" ]; then
      printf '%s\n' exit
      return
    fi
    if [ "$parsed" = "all" ]; then
      printf '%s\n' all
      return
    fi
    case ",$output," in
      *",$parsed,"*) ;;
      *) output="${output}${output:+,}$parsed" ;;
    esac
  done

  if [ -z "$output" ]; then
    printf '%s\n' invalid
    return
  fi

  printf '%s\n' "$output"
}

show_help() {
  cat <<'EOF'
Usage:
  ./bootstrap.sh                # interactive menu
  ./bootstrap.sh --profile NAME # run single profile (core,zsh,docker,python,java,node,go,ruby,rust,dotnet,all)
  ./bootstrap.sh --yes          # non-interactive; runs all profiles

Optional env vars:
  GIT_USER_NAME                # global git user.name
  GIT_USER_EMAIL               # global git user.email
  JAVA_SDKMAN_CANDIDATE        # default: 21.0.6-zulu
  DOTNET_CHANNEL               # default: LTS
  DEBUG                        # set 1 for debug logs
EOF
}

parse_args() {
  PROFILE=""
  SHOW_HELP=0

  while [ "$#" -gt 0 ]; do
    case "$1" in
      -h|--help)
        SHOW_HELP=1
        shift
        ;;
      --profile)
        if [ -z "${2:-}" ]; then
          error "Missing profile name for --profile."
          return 1
        fi
        PROFILE="$2"
        shift 2
        ;;
      --non-interactive)
        NON_INTERACTIVE=1
        shift
        ;;
      --yes)
        ASSUME_YES=1
        NON_INTERACTIVE=1
        shift
        ;;
      *)
        error "Unknown option: $1"
        return 1
        ;;
    esac
  done

  if [ "$ASSUME_YES" = "1" ] && [ -z "$PROFILE" ]; then
    PROFILE="all"
  fi

  return 0
}

main() {
  parse_args "$@" || {
    show_help
    exit 1
  }

  if [ "$SHOW_HELP" = "1" ]; then
    show_help
    exit 0
  fi

  export NON_INTERACTIVE
  export ASSUME_YES

  if [ "$NON_INTERACTIVE" = "1" ] && [ -z "$PROFILE" ]; then
    error "Non-interactive mode requires --profile NAME (or --yes to run all)."
    show_help
    exit 1
  fi

  load_adapter
  load_modules

  require_sudo

  if [ -n "$PROFILE" ]; then
    run_profile "$PROFILE"
    log "Profile '$PROFILE' finished."
    exit 0
  fi

  while true; do
    print_menu
    read -rp "Select one or more options (e.g. 1,4,6): " option
    profile="$(parse_menu_choices "$option")"

    case "$profile" in
      exit)
        log "Bye."
        exit 0
        ;;
      invalid)
        warn "Invalid option."
        ;;
      *)
        IFS=',' read -ra selected_profiles <<<"$profile"
        for selected_profile in "${selected_profiles[@]}"; do
          run_profile "$selected_profile"
          log "Profile '$selected_profile' finished."
        done
        ;;
    esac
  done
}

main "$@"
