#!/bin/bash
# Error handling function
bail() {
    echo "Error: $1" >&2
    exit 1
    }
# Function to install a package if it's not already installed
install_package() {
    local package=$1
    echo "Checking for $package..."
    if ! hash "$package" 2>/dev/null; then
        echo "Installing $package..."
        apt update && apt install -y "$package" || bail "Failed to install $package."
    else
        echo "$package is already installed."
    fi
    }
# Function to copy a file with error handling
copy_file() {
    local source=$1
    local destination=$2
    echo "Copying $source to $destination..."
    cp "$source" "$destination" || bail "Failed to copy $source to $destination."
    }
# Main installation function
main() {
    echo "Starting installation process..."
    install_package i2c-tools
    copy_file "$PWD/i2c.conf" "/etc/modules-load.d/i2c.conf"
    copy_file "$PWD/99-i2c.rules" "/usr/lib/udev/rules.d/99-i2c.rules"
    copy_file "$PWD/i2csound.service" "/etc/systemd/system/i2csound.service"
    copy_file "$PWD/ovos-i2csound" "/usr/libexec/ovos-i2csound"
    chmod +x /usr/libexec/ovos-i2csound
    echo "Installation complete. Please reboot your system to apply changes."
    }
# Check for root privileges
[[ $EUID -ne 0 ]] && bail "This script must be run as root."
# Handle user confirmation for installation
confirm_installation() {
    read -p "This script will install several files to your system. Continue? [y/N] " response
    if [[ "$response" =~ ^[Yy] ]]; then
        main
    else
        bail "Installation aborted by the user."
    fi
    }
# Handle command-line arguments
case "$1" in
    --auto)
        main
        ;;
    *)
        confirm_installation
        ;;
esac
