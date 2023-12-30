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
    echo "Installing i2c.conf to /etc/modules-load.d"
    cp $PWD/i2c.conf /etc/modules-load.d/i2c.conf
    echo "Installing udev rules for i2c"
    cp $PWD/99-i2c.rules /usr/lib/udev/rules.d/99-i2c.rules
    echo "Installing i2csound.service"
    cp $PWD/i2csound.service /etc/systemd/system/i2csound.service
    echo "Installing ovos-i2csound script"
    cp $PWD/ovos-i2csound /usr/libexec/ovos-i2csound
    # Make sure its executable
    chmod +x /usr/libexec/ovos-i2csound
    echo
    echo "Done installing ovos-i2csound"
    echo "Reboot to start using"
}

if [[ "$1" == "--auto" ]]; then
    main
else
    echo "This script will install several files to your system"
    read -p "Would you like to continue? [y/N]" continue

    if [[ ! "$continue" == [Yy]* ]]; then
        main
    fi
fi

exit
