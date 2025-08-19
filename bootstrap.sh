#!/bin/bash
# vlab bootstrapper. installs and launches the main toolkit.

# --- configuration
readonly VLAB_REPO="https://github.com/vasillieux/vlab-toolkit.git"
readonly CORE_DIR="/usr/share/vlab/core"
readonly CONFIG_DIR="/usr/share/vlab"
readonly CACHE_DIR="/usr/share/vlab/modules"

# --- colors for setup
C_BLUE='\033[0;34m'
C_RED='\033[0;31m'
C_RESET='\033[0m'

# --- stage 1: installation check
# check if the main application is present. if not, install it.
if [ ! -f "$CORE_DIR/vlab.sh" ]; then
    echo -e "${C_BLUE}[*] vlab core toolkit not found. beginning installation...${C_RESET}"

    # 1. check for git
    if ! command -v git &> /dev/null; then
        echo -e "${C_RED}[-] git is required but not found. please install git and run this script again.${C_RESET}"
        exit 1
    fi

    # 2. create persistent directories
    echo -e "${C_BLUE}[*] creating user directories in /usr/... C_RESET}"
    mkdir -p "$CONFIG_DIR" "$CACHE_DIR"

    # 3. clone the main repository
    echo -e "${C_BLUE}[*] cloning the core toolkit from github...${C_RESET}"
    if git clone --depth 1 "$VLAB_REPO" "$CORE_DIR"; then
        echo -e "${C_BLUE}[*] installation successful.${C_RESET}"
    else
        echo -e "${C_RED}[-] failed to clone the repository. cleaning up.${C_RESET}"
        rm -rf "$CORE_DIR"
        exit 1
    fi
    echo "---"
fi

# --- stage 2: (sorry, Elliot)
exec bash "$CORE_DIR/vlab.sh"