#!/bin/bash

# The script is pretty straightforward. It defines an array of tools to install, updates the package lists, and then installs the tools. 
# Make the script executable: 
# chmod +x install_tools.sh
# 
# Run the script: 
# ./install_tools.sh

# List of tools to install
tools_to_install=(
	vim
	git
	curl
    jq
	htop
	# Add any other tools you want to install
)

# Update package lists
sudo apt update

# Install the tools
sudo apt install -y "${tools_to_install[@]}"
 
# Aliases to add to .bashrc
declare -A aliases_to_add=(
    [zulu]="date -u '+%Y-%m-%dT%H:%M:%SZ'"
    [update]="sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y"
    # Add more aliases here in the format [alias_name]="command"
)

# Function to add an alias if it doesn't already exist
add_alias_if_not_exists() {
    local alias_name="$1"
    local command="$2"
    if ! grep -q "alias $alias_name=" ~/.bashrc; then
        echo "alias $alias_name='$command'" >> ~/.bashrc
        echo "Added alias $alias_name to .bashrc"
    else
        echo "Alias $alias_name already exists in .bashrc"
    fi
}

# Loop through and add each alias
for alias_name in "${!aliases_to_add[@]}"; do
    add_alias_if_not_exists "$alias_name" "${aliases_to_add[$alias_name]}"
done

# Reload .bashrc to apply changes
source ~/.bashrc