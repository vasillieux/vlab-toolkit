#!/bin/bash
# nixos definitions. non-idiomatic imperative installation.

update_system() { print_info "syncing nix channels..."; nix-channel --update > /dev/null; }

os_pkg_install() {
    print_info "nix-env: installing $@";
    nix-env -iA "$@" > /dev/null;
}

# --- package lists
core_deps=("nixpkgs.curl" "nixpkgs.wget" "nixpkgs.git" "nixpkgs.python3" "nixpkgs.unzip" "nixpkgs.nmap" "nixpkgs.arp-scan")
recon_pkgs=("nixpkgs.dirb" "nixpkgs.dnsrecon" "nixpkgs.ffuf" "nixpkgs.gobuster" "nixpkgs.masscan" "nixpkgs.sublist3r" "nixpkgs.whatweb" "nixpkgs.whois" "nixpkgs.go")
recon_pip=("knockpy")
recon_go=(
    ["amass"]="github.com/owasp-amass/amass/v4/cmd/amass@master"
    ["subfinder"]="github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
)
wifi_pkgs=("nixpkgs.aircrack-ng" "nixpkgs.hcxtools" "nixpkgs.reaver" "nixpkgs.wifite")
general_pkgs=("nixpkgs.hashcat" "nixpkgs.hydra" "nixpkgs.john" "nixpkgs.inetutils" "nixpkgs.nikto" "nixpkgs.sqlmap" "nixpkgs.tcpdump" "nixpkgs.wireshark" "nixpkgs.yersinia")
general_pip=("mitmproxy")
evm_pkgs=("nixpkgs.nodejs" "nixpkgs.nodePackages.npm")
evm_pip=("slither-analyzer")

# --- complex installers
install_theharvester() { os_pkg_install "nixpkgs.theharvester"; }
install_metasploit() { os_pkg_install "nixpkgs.metasploit"; }
install_node_lts() { os_pkg_install "nixpkgs.nodejs"; }
install_foundry() { print_warning "foundry on nixos requires declarative setup. skipping."; }
setup_docker() { print_warning "docker on nixos must be enabled declaratively in configuration.nix. skipping."; }