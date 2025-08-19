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
# --- color definitions & helpers
export C_RESET='\033[0m'; export C_RED='\033[0;31m'; export C_GREEN='\033[0;32m'
export C_BLUE='\033[0;34m'; export C_YELLOW='\033[1;33m';
print_info() { echo -e "${C_BLUE}[*] $1${C_RESET}"; }
print_error() { echo -e "${C_RED}[-] $1${C_RESET}" >&2; }
export -f print_info print_error

# --- prerequisite checks & os detection
if [[ $EUID -ne 0 ]]; then print_error "must be run as root."; exit 1; fi
export original_user=${SUDO_USER:-$(logname)}
export user_home=$(getent passwd "$original_user" | cut -d: -f6)
export vlab_os=""
if [ -f /etc/os-release ]; then vlab_os=$(grep -E '^ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"'); fi
if [ ! -f "$source_dir/$vlab_os.sh" ]; then print_error "unsupported os: '$vlab_os'"; exit 1; fi
source "$source_dir/$vlab_os.sh"

# --- interactive menu renderer
render_menu() {
    local title="$1"
    local -n _options=$3
    local -n _descriptions=$4
    local current_selection=0
    tput civis; trap "tput cnorm; exit" SIGINT
    while true; do
        clear; echo -e "${C_GREEN}$title${C_RESET}\nuse arrows, enter to select, 'q' to go back/quit.\n"
        for i in "${!_options[@]}"; do
            if [ "$i" -eq "$current_selection" ]; then echo -e " > ${C_YELLOW}${_options[$i]}${C_RESET}"; else echo "   ${_options[$i]}"; fi
        done
        echo -e "\n${C_BLUE}description:${C_RESET}"; printf "%s\n" "${_descriptions[$current_selection]}" | fold -s -w 80
        read -rsn1 key < /dev/tty
        case "$key" in
            $'\x1b') read -rsn2 key < /dev/tty; if [[ $key == "[A" ]]; then current_selection=$(( (current_selection - 1 + ${#_options[@]}) % ${#_options[@]} )); elif [[ $key == "[B" ]]; then current_selection=$(( (current_selection + 1) % ${#_options[@]} )); fi ;;
            "") tput cnorm; return $current_selection ;;
            q|Q) tput cnorm; return 255 ;;
        esac
    done
}

# --- high-order install functions 
pkg_install() {  
    os_pkg_install "$@"; 
}
pip_install() { print_info "pip: installing $@"; python3 -m pip install --no-cache-dir "$@"; }
go_install() { print_info "go: installing $1"; su - "$original_user" -c "go install -v $2"; }
export -f pkg_install pip_install go_install

# --- catalogue management & integrity
init_dirs() { mkdir -p "$config_dir" "$cache_dir"; if [ ! -f "$repo_conf" ]; then echo "# add git repo urls here, one per line" > "$repo_conf"; fi; }
update_hashes_for_repo() { local repo_path="$1"; local db_file="$repo_path/.hashes.db"; print_info "generating trusted hashes for $(basename "$repo_path")"; find "$repo_path" -type f -name "*.sh" -exec sha256sum {} + > "$db_file"; }
sync_repos() { clear; print_info "syncing remote module repositories..."; while IFS= read -r repo_url || [[ -n "$repo_url" ]]; do if [[ -z "$repo_url" || "$repo_url" == \#* ]]; then continue; fi; repo_name=$(basename "$repo_url" .git); target_dir="$cache_dir/$repo_name"; echo "---"; print_info "processing repo: $repo_name"; if [ -d "$target_dir" ]; then (cd "$target_dir" && git pull --ff-only) && update_hashes_for_repo "$target_dir"; else git clone --depth 1 "$repo_url" "$target_dir" && update_hashes_for_repo "$target_dir"; fi; done < "$repo_conf"; echo "---"; print_info "sync complete."; read -rsn1 key < /dev/tty; }
rehash_all_repos() { clear; print_info "re-calculating trusted hashes..."; find "$cache_dir" -mindepth 1 -maxdepth 1 -type d -exec bash -c 'update_hashes_for_repo "$0"' {} \;; print_info "re-hashing complete."; read -rsn1 key < /dev/tty; }
add_repo() { clear; read -p "enter git repository url: " new_repo_url; if [[ -n "$new_repo_url" ]]; then echo "$new_repo_url" >> "$repo_conf"; print_info "repository added."; fi; sleep 1; }
manage_catalogue() { while true; do options=("sync remote repos" "add new repo source" "re-hash all trusted modules" "edit repo file manually"); descs=("pull latest modules and update trusted hashes." "add a new git repository url to your list." "accepts all local changes to modules as the new trusted version." "open $repo_conf in your default editor."); render_menu "catalogue management" "" options descs; choice=$?; case $choice in 0) sync_repos ;; 1) add_repo ;; 2) rehash_all_repos ;; 3) ${EDITOR:-vi} "$repo_conf" < /dev/tty ;; 255) return ;; esac; done; }

# --- main logic
prepare_system() { print_info "syncing packages and installing core tools..."; update_system; os_pkg_install "${core_deps[@]}"; }
init_dirs; prepare_system

while true; do
    mapfile -t categories < <(find "$modules_dir" "$cache_dir" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" 2>/dev/null | sort -u)
    category_names=(); for cat in "${categories[@]}"; do category_names+=("$(tr '_' ' ' <<< "${cat//[0-9_]/ }" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1')"); done
    category_names+=("remote modules (catalogue)")

    render_menu "vlab toolkit // os: $vlab_os" "select a category" category_names categories
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

        # --- integrity check & hash display logic ---
        if [[ "$file" == "$cache_dir"* ]]; then
            current_hash=$(sha256sum "$file" | cut -c1-8)
            final_name="${final_name} [${current_hash}]"
            repo_path=$(dirname "$(dirname "$file")"); db_file="$repo_path/.hashes.db"
            if [ -f "$db_file" ]; then
                trusted_hash=$(grep -F "  $file" "$db_file" | awk '{print $1}')
                if [[ -n "$trusted_hash" && "$(sha256sum "$file" | awk '{print $1}')" != "$trusted_hash" ]]; then
                    final_name="${C_RED}[MODIFIED] ${final_name}${C_RESET}"; final_desc="${C_RED}WARNING: file has been modified. ${C_RESET}${final_desc}"
                fi
            fi
        fi
        module_names+=("$final_name"); module_descs+=("$final_desc")
    done

    render_menu "${category_names[$main_choice]}" "select a module" module_names module_descs
    sub_choice=$?

    if [ $sub_choice -eq 255 ]; then continue; fi
    selected_module="${module_files[$sub_choice]}"
    
    while true; do
        action_options=("run" "view" "edit")
        action_descs=("execute this module." "view the source code of this module (read-only)." "edit the source code of this module in your default editor." "return to the previous menu.")
        clean_name=$(echo -e "${module_names[$sub_choice]}" | sed -r 's/\x1b\[[0-9;]*m?//g' | sed -r 's/ \[.{8}\]$//')
        
        render_menu "action for: $clean_name" "" action_options action_descs
        action_choice=$?

        case $action_choice in
            0) # run
                clear; print_info "executing: $clean_name"
                echo "---"; bash "$selected_module"; echo "---"
                print_info "module finished. press any key to return to main menu."; read -rsn1 key < /dev/tty;
                break 2 # break out of both the action menu and module list loop
                ;;
            1) # view
                less "$selected_module" < /dev/tty
                ;;
            2) # edit
                ${EDITOR:-vi} "$selected_module" < /dev/tty
                ;;
        esac
    done
done