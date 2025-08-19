#!/bin/bash
# installation dispatcher. reads variables and executes installs.

set -e

module_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "$module_dir/../definitions/$vlab_os.sh"

install_recon() {
    pkg_install "${core_deps[@]}"
    pkg_install "${recon_pkgs[@]}"
    pip_install "${recon_pip[@]}"
    for pkg_name in "${!recon_go[@]}"; do go_install "$pkg_name" "${recon_go[$pkg_name]}"; done
    install_theharvester
}
install_wifi() { pkg_install "${wifi_pkgs[@]}"; }
install_general() {
    pkg_install "${general_pkgs[@]}"
    pip_install "${general_pip[@]}"
    install_metasploit
}
install_evm() {
    pkg_install "${evm_pkgs[@]}"
    install_node_lts
    npm install -g solc > /dev/null
    pip_install "${evm_pip[@]}"
    install_foundry
}

case "$1" in
    recon) install_recon ;;
    wifi) install_wifi ;;
    general) install_general ;;
    evm) install_evm ;;
    docker) setup_docker ;;
    *) print_error "invalid install mode." ; exit 1 ;;
esac