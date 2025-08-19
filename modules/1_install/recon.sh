#!/bin/bash
# META_NAME="reconnaissance tools"
# META_DESC="installs a suite of tools for network, web, and subdomain reconnaissance, including nmap, gobuster, amass, and theharvester."

set -e
source "$(dirname "${BASH_SOURCE[0]}")/../../definitions/$vlab_os.sh"

main() {
    pkg_install "${recon_pkgs[@]}"
    pip_install "${recon_pip[@]}"
    for pkg_name in "${!recon_go[@]}"; do go_install "$pkg_name" "${recon_go[$pkg_name]}"; done
    install_theharvester
}
main