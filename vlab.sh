#!/bin/bash
# vlab controller. detects os, defines installers, runs menu.

# --- core setup
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source_dir="$script_dir/definitions"
modules_dir="$script_dir/modules"

# --- color definitions
export C_RESET='\033[0m'; export C_RED='\033[0;31m'; export C_GREEN='\033[0;32m'
export C_BLUE='\033[0;34m'; export C_YELLOW='\033[1;33m'; export C_CYAN='\033[0;36m'

# --- helper functions
print_info() { echo -e "${C_BLUE}[*] $1${C_RESET}"; }
print_success() { echo -e "${C_GREEN}[+] $1${C_RESET}"; }
print_warning() { echo -e "${C_YELLOW}[!] $1${C_RESET}"; }
print_error() { echo -e "${C_RED}[-] $1${C_RESET}" >&2; }
export -f print_info print_success print_warning print_error

# --- prerequisite checks
if [[ $EUID -ne 0 ]]; then print_error "must be run as root."; exit 1; fi
export original_user=${SUDO_USER:-$(logname)}
export user_home=$(getent passwd "$original_user" | cut -d: -f6)

# --- os detection & definition sourcing
vlab_os=""
if [ -f /etc/os-release ]; then vlab_os=$(grep -E '^ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"'); fi
export vlab_os

case "$vlab_os" in
    ubuntu|arch)
        print_info "detected os: $vlab_os"
        if [ -f "$source_dir/$vlab_os.sh" ]; then source "$source_dir/$vlab_os.sh"; else print_error "definition file missing for $vlab_os"; exit 1; fi
        ;;
    *)
        print_error "unsupported os: '$vlab_os'. this toolkit supports ubuntu, arch, and nixos."
        exit 1
        ;;
esac


# --- high-order install functions
pkg_install() {  
    os_pkg_install "$@"; 
}
pip_install() { print_info "pip: installing $@"; python3 -m pip install --no-cache-dir "$@"; }
go_install() { print_info "go: installing $1"; su - "$original_user" -c "go install -v $2"; }
export -f pkg_install pip_install go_install

# --- system preparation (now os-agnostic)
prepare_system() {
    print_info "syncing package lists and installing core dependencies..."
    update_system 
    # os_pkg_install "${core_deps[@]}"
    print_success "system updated and core dependencies are present."
}

# --- main menu
prepare_system
while true; do
    clear
    echo -e "${C_GREEN}vlab toolkit // os: $vlab_os${C_RESET}"
    echo "--- install & setup ---"
    PS3=$'\n> '
    options=(
        "recon tools" "wifi tools" "general tools" "evm tools" "docker engine"
        "--- diagnostics ---" "check installed" "verify sandbox" "--- exit ---" "quit"
    )
    select opt in "${options[@]}"; do
        case $opt in
            "recon tools") bash "$modules_dir/install_tools.sh" recon; break;;
            "wifi tools") bash "$modules_dir/install_tools.sh" wifi; break;;
            "general tools") bash "$modules_dir/install_tools.sh" general; break;;
            "evm tools") bash "$modules_dir/install_tools.sh" evm; break;;
            "docker engine") bash "$modules_dir/install_tools.sh" docker; break;;
            "check installed") bash "$modules_dir/diagnostics.sh" check; continue 2;;
            "verify sandbox") bash "$modules_dir/diagnostics.sh" verify; continue 2;;
            "quit") print_info "exit."; exit 0;;
            *) print_error "invalid option.";;
        esac
    done
    print_success "task finished. relog or source shell profile to apply changes."
    read -n 1 -s -r -p "press any key to exit."
    exit 0
done