#!/bin/bash
# META_NAME="verify sandbox configuration"
# META_DESC="analyzes the running environment (vm, container, bare metal) to find common isolation weaknesses and provides hardening advice."

set -e
source "$source_dir/$vlab_os.sh"


main() {
    if ! command -v arp-scan &>/dev/null; then pkg_install "arp-scan" "nmap"; fi

    echo -e "${C_BLUE}network checks...${C_RESET}"
    gateway=$(ip r | grep default | awk '{print $3}' | head -n 1)
    printf "  %-25s" "internet egress:"; if ping -c 1 8.8.8.8 &>/dev/null; then echo "ok"; else echo "failed"; fi
    printf "  %-25s" "lan discovery:"; if [ "$(arp-scan --localnet --quiet --ignoredups 2>/dev/null | wc -l)" -gt 2 ]; then echo "lan visible"; else echo "isolated"; fi

    virt_type=$( (systemd-detect-virt 2>/dev/null) | xargs )
    print_info "detected environment: $virt_type"

    print_info "recommendations for '$virt_type'..."
    echo -e "\n${C_BLUE}recommendations for '$virt_type' environment...${C_RESET}"
    case "$virt_type" in
        kvm|qemu|oracle|vmware) echo "  - use nat networking, disable shared folders.";;
        docker|lxc) echo "  - avoid --net=host and --privileged. use volumes, not bind mounts.";;
        none) echo "  - enable ufw firewall, deny incoming traffic by default.";;
    esac
}
main