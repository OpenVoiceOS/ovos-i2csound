#!/bin/bash

# Must be run as root
if [[ $EUID > 0 ]]; then
    echo "This script must run as root"
    exit
fi

main () {
    echo "Checking for i2cdetect"
    if hash i2cdetect 2>/dev/null; then
        echo "i2cdetect is already installed"
    else
        echo "i2cdetect is not installed"
        echo "Installing now"
        apt update && apt install -y i2c-tools
    fi

    mod_dir=/etc/modules-load.d
    rules_dir=/usr/lib/udev/rules.d
    service_dir=/etc/systemd/system
    script_dir=/usr/libexec

    if [[ -f ${mod_dir}/i2c.conf ]]; then
        echo "Removing old i2c.conf file"
        rm ${mod_dir}/i2c.conf
    fi
    echo "Installing i2c.conf to /etc/modules-load.d"
    cp $PWD/i2c.conf /etc/${mod_dir}/i2c.conf

    if [[ -f ${rules_dir}/99-i2c.rules ]]; then
        echo "Removing old i2c.rules file"
        rm ${rules_dir}/99-i2c.rules
    fi
    echo "Installing udev rules for i2c"
    cp $PWD/99-i2c.rules ${rules_dir}/99-i2c.rules

    if [[ -f ${service_dir}/i2csound.service ]]; then
        echo "Removing old i2csound.service file"
        rm ${service_dir}/i2csound.service
    fi
    echo "Installing i2csound.service"
    cp $PWD/i2csound.service /etc/systemd/system/i2csound.service

    if [[ -f ${script_dir}/ovos-i2csound ]]; then
        echo "Removing old i2csound script"
        rm ${script_dir}/ovos-i2csound
    fi
    echo "Installing ovos-i2csound script"
    cp $PWD/ovos-i2csound /usr/libexec/ovos-i2csound
}

if [[ "$1" == "--auto" ]]; then
    main
else
    echo "This script will install several files to your system"
    read -p "Would you like to continue? [y/N]" continue

    if [[ "$continue" == [Yy]* ]]; then
        main
        echo
        echo "Done installing ovos-i2csound"
        echo "Reboot to start using"
    fi
fi

exit
