#!/bin/bash

history_path="${BASH_HISTORY_PATH:-"$HOME/.bash_history"}"

if [ ! -f "$history_path" ]; then
    echo "The path: "$history_path" couldn't be found. Set the correct path using: \`BASH_HISTORY_PATH=/path/to/your/history_file ./check-installs.sh\`"
    exit 1
fi

declare -A managers_install=(
    [pacman]='-S'
    [yay]='-S'
    [paru]='-S'
    [apt]='install'
    [dnf]='install'
    [zypper]='install'
    [brew]='install'
    [snap]='install'
)

declare -A managers_remove=(
    [pacman]='-R'
    [yay]='-R'
    [paru]='-R'
    [apt]='remove'
    [dnf]='remove'
    [zypper]='remove'
    [brew]='uninstall'
    [snap]='remove'
)

if [ -n "$1" ]; then
    IFS=',' read -r -a user_managers <<<"$1"

    # Validate user-specified managers
    for manager in "${user_managers[@]}"; do
        if [[ ! -v managers_install[$manager] ]]; then
            echo "Error: Invalid package manager '$manager'. Valid managers are: ${!managers_install[@]}"
            exit 1
        fi
    done
else
    user_managers=("${!managers_install[@]}")
fi

declare -A installed_by
declare -A removed_pkgs

for mgr in "${user_managers[@]}"; do
    install_flag=${managers_install[$mgr]}
    remove_flag=${managers_remove[$mgr]}

    install_lines=$(grep -E "^\s*(sudo\s+)?$mgr\s+$install_flag[^ ]*" "$history_path" | sed 's/^\s*//' | sort | uniq)
    remove_lines=$(grep -E "^\s*(sudo\s+)?$mgr\s+$remove_flag[^ ]*" "$history_path" | sed 's/^\s*//' | sort | uniq)

    while read -r line; do
        pkgs=$(echo "$line" | sed -E "s/^.*$install_flag[^ ]* //")
        for pkg in $pkgs; do
            [[ "$pkg" =~ ^- ]] && continue
            installed_by["$pkg"]="$mgr"
        done
    done <<<"$install_lines"

    while read -r line; do
        pkgs=$(echo "$line" | sed -E "s/^.*$remove_flag[^ ]* //")
        for pkg in $pkgs; do
            [[ "$pkg" =~ ^- ]] && continue
            removed_pkgs["$pkg"]=1
        done
    done <<<"$remove_lines"
done

declare -A grouped
for pkg in "${!installed_by[@]}"; do
    if [[ -z "${removed_pkgs[$pkg]}" ]]; then
        mgr="${installed_by[$pkg]}"
        grouped["$mgr"]+="$pkg"$'\n'
    fi
done

for mgr in "${user_managers[@]}"; do
    if [[ -n "${grouped[$mgr]}" ]]; then
        echo "=== \"$mgr\" installs ==="
        echo "Amount: $(echo -n "${grouped[$mgr]}" | grep -c '^')"
        echo "${grouped[$mgr]}" | sort
        echo
    fi
done
