# ovos-i2csound

ovos-i2csound detects and configures i2c sound HATs on a Raspberry Pi. It runs at boot, finds the attached card, and sets up ALSA for that card.

**The scripts in this repo need sudo access to run and install.**

## Install

The install script works on apt-based systems only.

1. Clone this repository: `git clone https://github.com/OpenVoiceOS/ovos-i2csound`
2. Change into the `ovos-i2csound` directory: `cd ovos-i2csound`
3. Run the install script: `sudo ./install.sh`
4. Reboot for the changes to take effect.

### What the install script does

The `install.sh` script installs `ovos-i2csound`. It checks for the required apt packages and installs any that are missing. It then copies the rest of the scripts to the required directories on the host system. After installation, you can delete this directory.

### Manual install

Instead of running `install.sh`, you can place these files by hand and reboot:

| File | Target |
| --- | --- |
| `i2c.conf` | `/etc/modules-load.d/i2c.conf` |
| `bcm2835-alsa.conf` | `/etc/modules-load.d/bcm2835-alsa.conf` |
| `i2csound.service` | `/etc/systemd/system/i2csound.service` |
| `ovos-i2csound` | `/usr/libexec/ovos-i2csound` |
| `99-i2c.rules` | `/usr/lib/udev/rules.d/99-i2c.rules` |

Also create the directory ovos-i2csound uses to store a variable: `sudo mkdir /etc/OpenVoiceOS`

## Usage

Once installed and enabled, ovos-i2csound runs at boot and tries to detect the attached card, if any. If it detects a supported card, it sets up ALSA with the correct values for that card. The `ovos-i2csound` script lists the supported devices and the devices planned for support. [Pull requests are welcome](https://github.com/OpenVoiceOS/ovos-i2csound/pulls/) to add more devices.

When ovos-i2csound detects a card, it also creates `/etc/OpenVoiceOS/i2c_platform`. This file holds a single line with the name of the detected card. Plugins, or any other program, can read this file to check which card is present. If the file does not exist, ovos-i2csound ran but did not find a supported card.

Report issues [here](https://github.com/OpenVoiceOS/ovos-i2csound/issues/).

## Related projects

- [OpenVoiceOS/ovos-PHAL-plugin-dotstar](https://github.com/OpenVoiceOS/ovos-PHAL-plugin-dotstar) — PHAL plugin for DotStar LED rings on Raspberry Pi devices.
- [OpenVoiceOS/ovos-PHAL-plugin-mk2-v6-fan-control](https://github.com/OpenVoiceOS/ovos-PHAL-plugin-mk2-v6-fan-control) — PHAL plugin for fan control on Mark 2 v6 hardware.
- [OpenVoiceOS/ovos-tools](https://github.com/OpenVoiceOS/ovos-tools) — command-line tools for OVOS devices.

## License

See [LICENSE](LICENSE).
