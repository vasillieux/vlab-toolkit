#!/bin/bash
# diagnostics module. checks installed tools and sandbox status.

set -e
# inherits variables and functions from vlab.sh

module_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "$module_dir/../definitions/$vlab_os.sh"

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

verify_sandbox() {
    clear; 
    print_info "verifying sandbox configuration...";
    print_info "requiring a bunch of tools... will install them";
    sleep 1
    if ! command -v arp-scan &>/dev/null; then pkg_install "arp-scan" "nmap"; fi

    # network checks
    print_info "network checks..."
    gateway=$(ip r | grep default | awk '{print $3}' | head -n 1)
    printf "  %-25s" "internet egress:"; if ping -c 1 8.8.8.8 &>/dev/null; then print_success "[ok]"; else print_error "[failed]"; fi
    printf "  %-25s" "lan discovery:"; if [ "$(arp-scan --localnet --quiet --ignoredups | wc -l)" -gt 2 ]; then print_warning "[lan visible]"; else print_success "[isolated]"; fi

    sleep 1

    # note: if it detects no virtualization (bare metal), exits with code 1
    # therefore removing redirect & set -e may kill the functionality of this script
    virt_type=$(systemd-detect-virt 2>/dev/null || echo "none")
    print_info "recommendations for '$virt_type'..."
    case "$virt_type" in
        kvm|qemu|oracle|vmware) echo "  - use nat networking, disable shared folders.";;
        docker|lxc) echo "  - avoid --net=host and privileged flags. use docker volumes, not bind mounts.";;
        none) echo "  - enable ufw firewall, deny incoming traffic.";;
    esac
    read -n 1 -s -r -p "press any key to return..."
}

case "$1" in
    check) check_installed ;;
    verify) verify_sandbox ;;
    *) print_error "invalid diagnostic mode." ; exit 1 ;;
esac