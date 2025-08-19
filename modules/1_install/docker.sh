#!/bin/bash
# META_NAME="verify sandbox configuration"
# META_DESC="analyzes the running environment (vm, container, bare metal) to find common isolation weaknesses and provides hardening advice."

set -e
source "$(dirname "${BASH_SOURCE[0]}")/../../definitions/$vlab_os.sh"

install_docker_env() {
    print_info "Setting up Docker Engine from official Docker repo..."
    setup_docker
    # if ! command -v docker &> /dev/null; then
    #     install -m 0755 -d /etc/apt/keyrings
    #     curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    #     chmod a+r /etc/apt/keyrings/docker.gpg
    #     echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    #     apt-get update
    #     apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    #     systemctl enable --now docker
    #     usermod -aG docker "$ORIGINAL_USER"
    # else
    #     print_warning "Docker is already installed."
    # fi
}

install_docker_env