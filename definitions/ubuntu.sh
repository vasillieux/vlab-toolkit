#!/bin/bash
# ubuntu definitions.

update_system() { print_info "syncing package lists..."; apt-get update -y > /dev/null; }

os_pkg_install() {
    print_info "apt: installing $@";
    apt-get install -y --no-install-recommends "$@" > /dev/null;
}

# --- package lists
core_deps=("curl" "wget" "git" "python3-pip" "python3-venv" "build-essential" "unzip" "nmap" "arp-scan")
recon_pkgs=("dirb" "dnsrecon" "ffuf" "gobuster" "masscan" "sublist3r" "whatweb" "whois" "golang-go")
recon_pip=("knockpy")
recon_go=(
    ["amass"]="github.com/owasp-amass/amass/v4/cmd/amass@master"
    ["subfinder"]="github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
)
wifi_pkgs=("aircrack-ng" "bully" "hcxdumptool" "hcxtools" "reaver" "wifite")
general_pkgs=("hashcat" "hydra" "john" "net-tools" "nikto" "sqlmap" "tcpdump" "wireshark" "yersinia")
general_pip=("mitmproxy")
evm_pkgs=("ca-certificates" "gnupg") # for nodesource
evm_pip=("slither-analyzer")

# --- complex installers
install_theharvester() {
    if [ ! -d "/opt/theHarvester" ]; then
        print_info "installing theharvester from source..."
        git clone https://github.com/laramies/theHarvester.git /opt/theHarvester > /dev/null 2>&1
        python3 -m venv /opt/theHarvester/.venv
        /opt/theHarvester/.venv/bin/pip install -r /opt/theHarvester/requirements.txt > /dev/null
        ln -sf /opt/theHarvester/theHarvester.py /usr/local/bin/theharvester
    fi
}
install_metasploit() {
    if ! command -v msfconsole &> /dev/null; then
        print_info "installing metasploit..."
        curl -s https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && \
        chmod 755 msfinstall && ./msfinstall && rm msfinstall
    fi
}
install_node_lts() {
    if ! command -v node &> /dev/null; then
        print_info "installing node.js lts..."
        mkdir -p /etc/apt/keyrings
        curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
        echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list > /dev/null
        apt-get update > /dev/null && apt-get install -y nodejs > /dev/null
    fi
}
install_foundry() { su - "$original_user" -c "curl -sL https://foundry.paradigm.xyz | bash && $user_home/.foundry/bin/foundryup"; }
setup_docker() {
    if ! command -v docker &> /dev/null; then
        print_info "installing docker engine..."
        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        chmod a+r /etc/apt/keyrings/docker.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
        apt-get update > /dev/null && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin > /dev/null
        systemctl enable --now docker &> /dev/null
        usermod -aG docker "$original_user"
    fi
}