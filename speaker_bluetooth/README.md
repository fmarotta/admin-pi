# Speaker bluetooth

## Background

ALSA is a set of drivers for audio devices in Linux. PulseAudio is a 
"sound server", that is, applications interact with PulseAudio, which 
then interacts with ALSA. At a higher level, there are clients that 
decode audio streams (e.g. vlc), which interact with PulseAudio.

In our case, we want that PulseAudio send the audio stream to a speaker 
through bluetooth. On Linux, the package bluez manages bluetooth.

###### References

https://archlinuxarm.org/forum/viewtopic.php?f=65&t=11413 (main)
https://wiki.archlinux.org/index.php/bluetooth
https://wiki.archlinux.org/index.php/Bluetooth_headset
https://wiki.archlinux.org/index.php/PulseAudio
https://wiki.archlinux.org/index.php/PulseAudio/Troubleshooting
https://wiki.archlinux.org/index.php/PulseAudio/Examples
http://www.lightofdawn.org/blog/?viewDetailed=00031

## Installation

First of all, we need to add our user to the group *lp*, with the 
command `usermod -aG lp jon`. Then, we **do not** enbale uart, contrary 
to what is written on the guide, since last time this resulted in an 
unbootable Pi.

We now have to install two AUR packages, so we will move to our 
`/usr/local/builds` directory and perform the manual build. When not 
specified, we must use our unprivileged user. First, let us clone the 
repository of the package `hciattach-rpi3` with the command `git clone 
https://aur.archlinux.org/hciattach-rpi3.git`; this has the advantage 
over wgetting the package that any update will be as simple as a `git 
pull`. Then cd into hciattach-rpi and run the command `makepkg -s`, 
afterwhich run `sudo pacman -U hciattach-rpi3-5.38-1-armv7h.pkg.tar.xz`. 
Do the same for AUR package `pi-bluetooth`.

Now enable the bluetooth driver service with `sudo systemctl enable 
brcm43438.service`. Install bluetooth, alsa and pulseaudio related 
packages `sudo pacman -S pulseaudio-alsa pulseaudio-bluetooth bluez 
bluez-libs bluez-utils bluez-firmware alsa-lib alsa-utils`.

Also install sox, which is a powerful command-line tool used to play and 
record sounds. To play mp3 files, sox will need a little help from three 
libraries, which have to be installed alongside it: libmad, libid3tag 
and twolame.

We are nearly done. Load btusb with modprobe, then sudo systemctl enable 
bluetooth and sysetmctl --user enable pulseaudio and pulseaudio.socket. 
Then shutdown, unplug and plug the raspberry (do not simply reboot).

## Speaker initialisation

```
sudo bluetoothctl
power on
agent on
default-agent
scan on
pair XX:XX:XX:XX:XX:XX
connect XX:XX:XX:XX:XX:XX
scan off
exit
```

## Configuration

### Automatic connection

This will ensure that the bluetooth will always be up and scanning, and 
that the speaker will automatically connect to it, so that you will just 
need to start your speaker and it will work. Add the line 
`AutoEnable=true` in `/etc/bluetooth/main.conf` at the bottom of the 
[Policy] section, which will auto power-on the bluetooth.

Now, configure auto connection. Add the line `load-module 
module-switch-on-connect` and comment `#load-module 
module-suspend-on-idle` in `/etc/pulse/default.pa`. Run again 
bluetoothctl and insert `trust XX:XX:XX:XX:XX:XX`.

### Enable headset features

In order to use the speaker as a headset, add the line 
`Enable=Source,Sink,Media,Socket` to `/etc/bluetooth/audio.conf` under 
the [General] section (create the file if not present).

### Card profile

If your device does not work, it may be due to a wrong profile 
associated to it. Run `pacmd ls`, which lists all sinks (output), 
sources (input) and cards (devices) are available. Look for the index of 
the card of your device and give the command `pacmd set-card-profile 
<index> <profile>`, for instance `pacmd set-card-profile 1 a2dp_sink`.

### Set default output source

You can optionally set the default output source, but we did not do it.
