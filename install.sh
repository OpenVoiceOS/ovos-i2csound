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

# Pulseaudio configuration
pulse_config() {
    echo "Installing pulseaudio config files..."
    local system_pa_dir=/etc/pulse/system.pa.d
    local default_pa_dir=/etc/pulse/default.pa.d
    local pulse_daemon_dir=/etc/pulse/daemon.conf.d
    local profile_dir=/usr/share/pulseaudio/alsa-mixer/profile-sets

    if [[ ! -d $system_pa_dir ]]; then
        mkdir -p $system_pa_dir
    fi
    if [[ ! -d $default_pa_dir ]]; then
        mkdir -p $default_pa_dir
    fi
    if [[ ! -d $pulse_daemon_dir ]]; then
        mkdir -p $pulse_daemon_dir
    fi
    if [[ ! -d $profile_dir ]]; then
        mkdir -p $profile_dir
    fi
    echo "Installing default pulseaudio config"
    copy_file "$PWD/pulseaudio/pulseaudio-system.pa" "$system_pa_dir/pulseaudio-system.pa"
    copy_file "$PWD/pulseaudio/pulseaudio-daemon.conf" "$pulse_daemon_dir/pulseaudio-daemon.conf"

    echo "Installing Seeed-Voicecard config"
    copy_file "$PWD/pulseaudio/seeed-voicecard-4mic-default.pa" "$default_pa_dir/seeed-voicecard-4mic-default.pa"
    copy_file "$PWD/pulseaudio/seeed-voicecard-4mic-daemon.conf" "$pulse_daemon_dir/seeed-voicecard-4mic-daemon.conf"
    copy_file "$PWD/pulseaudio/seeed-voicecard-4mic.conf" "$profile_dir/seeed-voicecard-4mic.conf"

    copy_file "$PWD/pulseaudio/seeed-voicecard-8mic-default.pa" "$default_pa_dir/seeed-voicecard-8mic-default.pa"
    copy_file "$PWD/pulseaudio/seeed-voicecard-8mic-daemon.conf" "$pulse_daemon_dir/seeed-voicecard-8mic-daemon.conf"
    copy_file "$PWD/pulseaudio/seeed-voicecard-8mic.conf" "$profile_dir/seeed-voicecard-8mic.conf"

    echo "Installing sj201 config"
    copy_file "$PWD/pulseaudio/sj201-default.pa" "$default_pa_dir/sj201-default.pa"
    copy_file "$PWD/pulseaudio/sj201-daemon.conf" "$pulse_daemon_dir/sj201-daemon.conf"
    copy_file "$PWD/pulseaudio/xvf3510.conf" "$profile_dir/xvf3510.conf"

    echo "Done with pulseaudio configuration"
}

# Hardware rules
install_rules() {
    echo "Installing udev rules"
    local rules_dir=/usr/lib/udev/rules.d
    copy_file "$PWD/udev/99-i2c.rules" "$rules_dir/99-i2c.rules"
    copy_file "$PWD/udev/91-vocalfusion.rules" "$rules_dir/91-vocalfusion.rules"
    copy_file "$PWD/udev/91-seeedvoicecard.rules" "$rules_dir/91-seeedvoicecard.rules"
    echo "Done installing udev rules"
}

# Main installation function
main() {
    echo "Starting installation process..."
    install_package i2c-tools
    local mod_dir=/etc/modules-load.d
    local service_dir=/etc/systemd/system
    local script_dir=/usr/libexec
    copy_file "$PWD/i2c.conf" "$mod_dir/i2c.conf"
    copy_file "$PWD/i2csound.service" "$service_dir/i2csound.service"
    copy_file "$PWD/ovos-i2csound" "$script_dir/ovos-i2csound"
    chmod +x "${script_dir}/ovos-i2csound"
    install_rules
    echo "Installation complete. Please reboot your system to apply changes."
    }

# Check for root privileges
[[ $EUID -ne 0 ]] && bail "This script must be run as root."

# Handle user confirmation for installation
confirm_installation() {
    read -p "This script will install several files to your system. Continue? [y/N] " response
    if [[ "$response" =~ ^[Yy] ]]; then
        read -p "Is PulseAudio being used? [y/N] " pulse_response
        main
        install_rules
        if [[ "$pulse_response" =~ ^[Yy] ]]; then
            pulse_config
        fi
    else
        bail "Installation aborted by the user."
    fi
    }

if [ -z "$*" ]; then
    confirm_installation
else
    optspec=":aph"
    while getopts "$optspec" optchar; do
        case "${optchar}" in
            a)
                main
                ;;
            p)
                pulse_config
                ;;
            \?|h)
                echo "Usage: sudo ./install.sh <option>"
                echo ""
                echo "  Options:"
                echo ""
                echo "    -a  Install automatically no prompts"
                echo "    -p  Include pulseaudio files"
                echo "    -h  Show this dialog"
                echo ""
                exit 1
                ;;
        esac
    done
fi

