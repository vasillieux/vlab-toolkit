#!/bin/bash
# META_NAME="blockchain evm"
# META_DESC="""

set -e
source "$source_dir/$vlab_os.sh"


main() {
    pkg_install "${evm_pkgs[@]}"
    install_node_lts
    npm install -g solc > /dev/null
    pip_install "${evm_pip[@]}"
    install_foundry
}
main