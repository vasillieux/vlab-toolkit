#!/bin/bash
# META_NAME="check installed modes"
# META_DESC=""

set -e
source "$(dirname "${BASH_SOURCE[0]}")/../../definitions/$vlab_os.sh"

check_installed() {
    print_info "checking installation status..."
    check_one() { printf "  %-25s" "$1"; if command -v "$2" &>/dev/null; then print_success "[found]"; else print_error "[missing]"; fi; }
    check_one "recon (nmap)" "nmap"
    check_one "recon (theharvester)" "theharvester"
    check_one "wifi (aircrack-ng)" "aircrack-ng"
    check_one "general (metasploit)" "msfconsole"
    check_one "evm (slither)" "slither"
    printf "  %-25s" "docker engine"
    if command -v docker &>/dev/null; then if groups "$original_user" | grep -q '\bdocker\b'; then print_success "[found & configured]"; else print_warning "[found, perms pending]"; fi; else print_error "[missing]"; fi
    read -n 1 -s -r -p "press any key to return..."
}


check_installed