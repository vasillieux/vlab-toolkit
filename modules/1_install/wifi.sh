#!/bin/bash
# META_NAME="wifi auditing tools"
# META_DESC="installs aircrack-ng, wifite, and hcxtools. requires a wireless adapter capable of monitor mode and packet injection."

set -e
source "$(dirname "${BASH_SOURCE[0]}")/../../definitions/$vlab_os.sh"

main() {
    pkg_install "${wifi_pkgs[@]}"
}
main