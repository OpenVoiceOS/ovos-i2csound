# ovos-i2csound
Script for i2c HAT detection and configuration on a Raspberry Pi

**Scripts in this repo require sudo access to use and install**

## Simple Installation
*currently only apt based OS*

Clone this repository.
`git clone https://github.com/OpenVoiceOS/ovos-i2csound`
Change into the `ovos-i2csound` directory.
`cd ovos-i2csound`
Run the install script.
`sudo ./install.sh`
Reboot for the changes to take effect.

## Installation Explained
This script does several things to enable auto detection of a variety of `i2c` sound cards for the Raspberry Pi. (A list of supported devices, or soon to be supported devices can be found in the `ovos-i2csound` script) [PR's are always welcome](https://github.com/OpenVoiceOS/ovos-i2csound/pulls/) to support more devices.

### install.sh
The `install.sh` script is an auto installer for `ovos-i2csound`.  It will check for the required apt packages and install them if needed.  It then copies the rest of the scripts used to the required directories on the host system.  After installation, it is safe to delete this directory.

### Manual Installation
Place the following files in the respective directory, and reboot your system.

`i2c.conf` -> `/etc/modules-load.d/i2c.conf`
`bcm2835-alsa.conf` -> `/etc/modules-load.d/bcm2835-alsa.conf`
`i2csound.service` -> `/etc/systemd/system/i2csound.service`
`ovos-i2csound` -> `/usr/libexec/ovos-i2csound`
`99-i2c.rules` -> `/usr/lib/udev/rules.d/99-i2c.rules`

Issues can be made [here](https://github.com/OpenVoiceOS/ovos-i2csound/issues/)
