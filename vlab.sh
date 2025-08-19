#!/bin/bash
# vlab controller. detects os, defines installers, runs menu.

: '
Thoughts about design:
Start typing index to highightor send the letters
Search work in subcatalogues also. All is indexed. 

Menu transition 
| 0. Tools |                         | 1. Cracking|
    |                                      | -- 0. Back 
    | -- 1. Recon                          | -- 2. Core  
    | -- 2. Wifi       --->                | -- 3. Cloud   
    | -- 3. Cracking 

or 
vlab toolkin // os: arch
use arrow keys to navigate, enter to select, 'q' to go back/quit.

 > Install
   Diagnostics

------>

> Pkg1
> Pkg2
> ...


Highlighting works like:

1 version               or  2 version:
| -- 1. Recon               | -- 1. Recon                 
| -- 2. Wifi                | -- 2. Wifi
-------------------         | -- (s) 3. Cracking 
| -- 3. Cracking |          | -- 4. Something else
-------------------
| -- 4. Something else
'

# --- core setup
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
export source_dir="$script_dir/definitions"
export modules_dir="$script_dir/modules"

# --- persistent user directories
export config_dir="/usr/share/vlab"
export cache_dir="/usr/share/vlab/modules"
export repo_conf="$config_dir/repos.conf"
# script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
# source_dir="$script_dir/definitions"
# modules_dir="$script_dir/modules"

# export config_dir="/usr/share/vlab"
# export cache_dir="/usr/share/vlab/modules"
# export repo_conf="$config_dir/repos.conf"
# export definition_dir="$config_dir/definitions"

# --- color definitions
export C_RESET='\033[0m'; export C_RED='\033[0;31m'; export C_GREEN='\033[0;32m'
export C_BLUE='\033[0;34m'; export C_YELLOW='\033[1;33m'; export C_CYAN='\033[0;36m'

# --- helper functions
print_info() { echo -e "${C_BLUE}[*] $1${C_RESET}"; }
print_success() { echo -e "${C_GREEN}[+] $1${C_RESET}"; }
print_warning() { echo -e "${C_YELLOW}[!] $1${C_RESET}"; }
print_error() { echo -e "${C_RED}[-] $1${C_RESET}" >&2; }
export -f print_info print_success print_warning print_error

# --- prerequisite checks
if [[ $EUID -ne 0 ]]; then print_error "must be run as root."; exit 1; fi
export original_user=${SUDO_USER:-$(logname)}
export user_home=$(getent passwd "$original_user" | cut -d: -f6)

# --- os detection & definition sourcing
vlab_os=""
if [ -f /etc/os-release ]; then vlab_os=$(grep -E '^ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"'); fi
export vlab_os

case "$vlab_os" in
    ubuntu|arch)
        print_info "detected os: $vlab_os"
        if [ -f "$source_dir/$vlab_os.sh" ]; then source "$source_dir/$vlab_os.sh"; else print_error "definition file missing for $vlab_os"; exit 1; fi
        ;;
    *)
        print_error "unsupported os: '$vlab_os'. this toolkit supports ubuntu, arch, and nixos."
        exit 1
        ;;
esac

init_dirs() { mkdir -p "$config_dir" "$cache_dir"; if [ ! -f "$repo_conf" ]; then echo "# add git repo urls here, one per line" > "$repo_conf"; fi; }

update_hashes_for_repo() {
    local repo_path="$1"
    local db_file="$repo_path/.hashes.db"
    print_info "generating trusted hashes for $(basename "$repo_path")"
    # find all .sh files, calculate sha256, and store in the db
    find "$repo_path" -type f -name "*.sh" -exec sha256sum {} + > "$db_file"
}

sync_repos() {
    clear; print_info "syncing remote module repositories..."
    while IFS= read -r repo_url || [[ -n "$repo_url" ]]; do
        if [[ -z "$repo_url" || "$repo_url" == \#* ]]; then continue; fi
        repo_name=$(basename "$repo_url" .git)
        target_dir="$cache_dir/$repo_name"
        echo "---"; print_info "processing repo: $repo_name"
        if [ -d "$target_dir" ]; then
            (cd "$target_dir" && git pull --ff-only) && update_hashes_for_repo "$target_dir"
        else
            git clone --depth 1 "$repo_url" "$target_dir" && update_hashes_for_repo "$target_dir"
        fi
    done < "$repo_conf"
    echo "---"; print_info "sync complete. press any key to continue."; read -rsn1;
}

rehash_all_repos() {
    clear; print_info "re-calculating trusted hashes for all cached modules..."
    find "$cache_dir" -mindepth 1 -maxdepth 1 -type d -exec bash -c 'update_hashes_for_repo "$0"' {} \;
    print_info "re-hashing complete. current versions are now trusted. press any key."; read -rsn1;
}

add_repo() { clear; read -p "enter the full git repository url to add: " new_repo_url; if [[ -n "$new_repo_url" ]]; then echo "$new_repo_url" >> "$repo_conf"; print_info "repository added."; fi; sleep 1; }

manage_catalogue() {
    while true; do
        options=("sync remote repos" "add new repo source" "re-hash all trusted modules" "edit repo file manually")
        descs=("pull the latest modules and update trusted hashes." "add a new git repository url to your list." "accepts all current local changes to modules as the new 'trusted' version." "open $repo_conf in your default editor for advanced changes.")
        render_menu "catalogue management" "" options descs
        choice=$?; case $choice in 0) sync_repos ;; 1) add_repo ;; 2) rehash_all_repos ;; 3) ${EDITOR:-vi} "$repo_conf" ;; 255) return ;; esac
    done
}


# --- high-order install functions
pkg_install() {  
    os_pkg_install "$@"; 
}
pip_install() { print_info "pip: installing $@"; python3 -m pip install --no-cache-dir "$@"; }
go_install() { print_info "go: installing $1"; su - "$original_user" -c "go install -v $2"; }
export -f pkg_install pip_install go_install

# --- system preparation (now os-agnostic)
prepare_system() {
    print_info "syncing package lists and installing core dependencies..."
    update_system 
    # os_pkg_install "${core_deps[@]}"
    print_success "system updated and core dependencies are present."
}

# --- interactive menu renderer
# args: 1. title, 2. prompt, 3. options array, 4. descriptions array
# render_menu() {
#     local title="$1"
#     local prompt="$2"
#     local -n options=$3
#     local -n descriptions=$4
#     local current_selection=0

#     # hide cursor
#     tput civis
#     # trap ctrl-c and restore cursor
#     trap "tput cnorm; exit" SIGINT

#     while true; do
#         clear
#         echo -e "${C_GREEN}$title${C_RESET}"
#         echo "use arrow keys to navigate, enter to select, 'q' to go back/quit."
#         echo ""

#         for i in "${!options[@]}"; do
#             if [ "$i" -eq "$current_selection" ]; then
#                 echo -e " > ${C_YELLOW}${options[$i]}${C_RESET}"
#             else
#                 echo "   ${options[$i]}"
#             fi
#         done

#         echo -e "\n${C_BLUE}description:${C_RESET}"
#         # print description in a fixed-size box
#         printf "%s\n" "${descriptions[$current_selection]}" | fold -s -w 80

#         read -rsn1 key
#         case "$key" in
#             # ansi escape for arrow up
#             $'\x1b')
#                 read -rsn2 key
#                 if [[ $key == "[A" ]]; then
#                     current_selection=$(( (current_selection - 1 + ${#options[@]}) % ${#options[@]} ))
#                 elif [[ $key == "[B" ]]; then
#                     current_selection=$(( (current_selection + 1) % ${#options[@]} ))
#                 fi
#                 ;;
#             # enter key
#             "")
#                 tput cnorm # restore cursor
#                 return $current_selection
#                 ;;
#             # q for quit
#             q|Q)
#                 tput cnorm
#                 return 255 # special exit code for 'back'
#                 ;;
#         esac
#     done
#}
render_menu() {
    local title="$1"
    # use prefixed internal names for namerefs to avoid collision.
    local -n _options=$3
    local -n _descriptions=$4
    local current_selection=0

    tput civis; trap "tput cnorm; exit" SIGINT
    while true; do
        clear; echo -e "${C_GREEN}$title${C_RESET}\nuse arrows, enter to select, 'q' to go back/quit.\n"
        for i in "${!_options[@]}"; do
            if [ "$i" -eq "$current_selection" ]; then
                echo -e " > ${C_YELLOW}${_options[$i]}${C_RESET}"
            else
                echo "   ${_options[$i]}"
            fi
        done
        echo -e "\n${C_BLUE}description:${C_RESET}"; printf "%s\n" "${_descriptions[$current_selection]}" | fold -s -w 80
        read -rsn1 key
        case "$key" in
            $'\x1b') read -rsn2 key; if [[ $key == "[A" ]]; then current_selection=$(( (current_selection - 1 + ${#_options[@]}) % ${#_options[@]} )); elif [[ $key == "[B" ]]; then current_selection=$(( (current_selection + 1) % ${#_options[@]} )); fi ;;
            "") tput cnorm; return $current_selection ;;
            q|Q) tput cnorm; return 255 ;;
        esac
    done
}

prepare_system() { print_info "syncing packages and installing core tools..."; update_system; os_pkg_install "${core_deps[@]}"; }
# initialization!
init_dirs;prepare_system

while true; do
    mapfile -t categories < <(find "$modules_dir" "$cache_dir" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" 2>/dev/null | sort -u)
    category_names=(); for cat in "${categories[@]}"; do category_names+=("$(tr '_' ' ' <<< "${cat//[0-9_]/ }" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1')"); done
    category_names+=("remote modules (catalogue)")

    render_menu "${C_GREEN}vlab toolkit // os: $vlab_os${C_RESET}"  "select a category" category_names categories
    main_choice=$?

    if [ $main_choice -eq 255 ]; then clear; print_info "exit."; exit 0; fi
    if [ "$main_choice" -eq $((${#category_names[@]} - 1)) ]; then manage_catalogue; continue; fi

    selected_category_name="${categories[$main_choice]}"
    mapfile -t category_paths < <(find "$modules_dir" "$cache_dir" -type d -name "$selected_category_name" 2>/dev/null)
    mapfile -t module_files < <(find "${category_paths[@]}" -maxdepth 1 -type f -name "*.sh" -printf "%p\n" 2>/dev/null | sort -u)
    
    module_names=(); module_descs=()
    for file in "${module_files[@]}"; do
        name=$(grep '^# META_NAME=' "$file" | cut -d'=' -f2 | tr -d '"'); desc=$(grep '^# META_DESC=' "$file" | cut -d'=' -f2 | tr -d '"')
        final_name="${name:-$(basename "$file")}"; final_desc="${desc:-no description.}"

        # --- integrity check logic ---
        if [[ "$file" == "$cache_dir"* ]]; then
            repo_path=$(dirname "$(dirname "$file")")
            db_file="$repo_path/.hashes.db"
            if [ -f "$db_file" ]; then
                # we ALREADY have git/curl so should have sha module, easy deal
                current_hash=$(sha256sum "$file" | awk '{print $1}')
                trusted_hash=$(grep -F "  $file" "$db_file" | awk '{print $1}')
                if [[ -n "$trusted_hash" && "$current_hash" != "$trusted_hash" ]]; then
                    final_name="${C_RED}[MODIFIED] ${final_name}${C_RESET}"
                    final_desc="${C_RED}WARNING: file has been modified since last sync. ${C_RESET}${final_desc}"
                fi
            fi
        fi
        module_names+=("$final_name"); module_descs+=("$final_desc")
    done

    render_menu "${category_names[$main_choice]}" "select a module" module_names module_descs
    sub_choice=$?

    if [ $sub_choice -eq 255 ]; then continue; fi
    selected_module="${module_files[$sub_choice]}"
    clear; print_info "executing: $(echo -e "${module_names[$sub_choice]}" | sed 's/\x1b\[[0-9;]*m//g')"
    echo "---"; bash "$selected_module"; echo "---"
    print_info "module finished. press any key to return."; read -rsn1
done

# while true; do
#     # discover main menu categories from directory names
#     mapfile -t categories < <(find "$modules_dir" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort)
#     category_names=()
#     for cat in "${categories[@]}"; do
#         # format for categories, ie : '1_install' to 'Install'
#         category_names+=("$(tr '_' ' ' <<< "${cat//[0-9_]/ }" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1')")
#     done

#     render_menu "${C_GREEN}vlab toolkit // os: $vlab_os${C_RESET}" "select a category" category_names categories
#     main_choice=$?

#     if [ $main_choice -eq 255 ]; then clear; print_info "exit."; exit 0; fi

#     # handle catalogue option
#     if [ "$main_choice" -eq $((${#category_names[@]} - 1)) ]; then
#         manage_catalogue
#         continue
#     fi

#     selected_category_dir="$modules_dir/${categories[$main_choice]}"

#     # discover modules in the selected category
#     mapfile -t module_files < <(find "$selected_category_dir" -maxdepth 1 -type f -name "*.sh" -printf "%f\n" | sort)
#     module_names=()
#     module_descs=()
#     for file in "${module_files[@]}"; do
#         # extract metadata from module files
#         name=$(grep '^# META_NAME=' "$selected_category_dir/$file" | cut -d'=' -f2 | tr -d '"')
#         desc=$(grep '^# META_DESC=' "$selected_category_dir/$file" | cut -d'=' -f2 | tr -d '"')
#         module_names+=("${name:-$file}")
#         module_descs+=("${desc:-no description available.}")
#     done

#     render_menu "${category_names[$main_choice]}" "select a module to run" module_names module_descs
#     sub_choice=$?

#     if [ $sub_choice -eq 255 ]; then
#         continue # go back to main menu
#     fi

#     selected_module="$selected_category_dir/${module_files[$sub_choice]}"
#     clear
#     print_info "executing module: ${module_names[$sub_choice]}"
#     echo "-----------------------------------------------------"
#     # execute the chosen module
#     bash "$selected_module"
#     echo "-----------------------------------------------------"
#     print_info "module finished. press any key to return to the menu."
#     read -rsn1
# done


# # --- main menu
# # prepare_system
# # while true; do
# #     clear
# #     echo -e "${C_GREEN}vlab toolkit // os: $vlab_os${C_RESET}"
# #     echo "--- install & setup ---"
# #     PS3=$'\n> '
# #     options=(
# #         "recon tools" "wifi tools" "general tools" "evm tools" "docker engine"
# #         "--- diagnostics ---" "check installed" "verify sandbox" "--- exit ---" "quit"
# #     )
# #     select opt in "${options[@]}"; do
# #         case $opt in
# #             "recon tools") bash "$modules_dir/install_tools.sh" recon; break;;
# #             "wifi tools") bash "$modules_dir/install_tools.sh" wifi; break;;
# #             "general tools") bash "$modules_dir/install_tools.sh" general; break;;
# #             "evm tools") bash "$modules_dir/install_tools.sh" evm; break;;
# #             "docker engine") bash "$modules_dir/install_tools.sh" docker; break;;
# #             "check installed") bash "$modules_dir/diagnostics.sh" check; continue 2;;
# #             "verify sandbox") bash "$modules_dir/diagnostics.sh" verify; continue 2;;
# #             "quit") print_info "exit."; exit 0;;
# #             *) print_error "invalid option.";;
# #         esac
# #     done
# #     print_success "task finished. relog or source shell profile to apply changes."
# #     read -n 1 -s -r -p "press any key to exit."
# #     exit 0
# # done