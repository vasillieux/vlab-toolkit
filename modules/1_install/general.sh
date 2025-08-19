#!/bin/bash
# META_NAME="general pentesting tools"
# META_DESC="installs core exploitation and password cracking tools like metasploit, hashcat, john the ripper, and sqlmap."

set -e
source "$(dirname "${BASH_SOURCE[0]}")/../../definitions/$vlab_os.sh"

main() {
    pkg_install "${general_pkgs[@]}"
    pip_install "${general_pip[@]}"
    install_metasploit
}
main