#!/bin/bash
# arch linux definitions.

update_system() { print_info "syncing package lists..."; pacman -Sy --noconfirm > /dev/null; }

os_pkg_install() {
    print_info "pacman: installing $@";
    pacman -S --noconfirm --needed "$@" > /dev/null;
}

# --- package lists
core_deps=("curl" "wget" "git" "python-pip" "python-venv" "base-devel" "unzip" "nmap" "arp-scan")
recon_pkgs=("dirb" "dnsrecon" "ffuf" "gobuster" "masscan" "sublist3r" "whatweb" "whois" "go")
recon_pip=("knockpy")
recon_go=(
    ["amass"]="github.com/owasp-amass/amass/v4/cmd/amass@master"
    ["subfinder"]="github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
)
wifi_pkgs=("aircrack-ng" "bully" "hcxdumptool" "hcxtools" "reaver" "wifite")
general_pkgs=("hashcat" "hydra" "john" "net-tools" "nikto" "sqlmap" "tcpdump" "wireshark-qt" "yersinia")
general_pip=("mitmproxy")
evm_pkgs=("nodejs" "npm")
evm_pip=("slither-analyzer")

# --- complex installers (arch often has packages for these)
install_theharvester() { os_pkg_install "theharvester"; }
install_metasploit() { os_pkg_install "metasploit"; }
install_node_lts() { os_pkg_install "nodejs" "npm"; } # handled by core evm_pkgs
install_foundry() {
    if ! command -v paru &> /dev/null && ! command -v yay &> /dev/null; then print_warning "paru or yay not found. skipping foundry."; return; fi
    local aur_helper=$(command -v paru || command -v yay)
    su - "$original_user" -c "$aur_helper -S --noconfirm foundry-bin"
}
setup_docker() {
    os_pkg_install "docker" "docker-compose"
    systemctl enable --now docker &> /dev/null
    usermod -aG docker "$original_user"
}