# Setting up the SD card

Since this is one of the first things one has to do when she buys a 
Raspberry Pi, a brief introduction is needed. Then we will explain how 
to install the OS.

###### Index of the directory

```
card_setup
|
|--card_setup.sh		Script to automatically set up the SD card with 
|						Arch Linux ARM. Depends on `raspi.fdisk` and 
|						`raspi.fstab`.
|
|--raspi.fdisk			Partition table for a 16 GiB SunDisk card.
|
`--raspi.fstab			Filesystem table for this setup.
```

## Why a Raspberry Pi?

A [Raspberry Pi](https://www.raspberrypi.org/) is a very small and 
inexpensive computer, which can be used for a variety of interesting 
projects. Basically, we thought that our real lives did not take enough 
of our time already, and we were eager to learn new things about linux 
and programming. We have a **Raspberry Pi 3 model B** that we informally 
call "raspi" -- which is not the plural of raspus.

## Which OS to chose?

We wanted a lightweight, yet functional operating system, so, as we did 
not even need a GUI, we opted for [Arch Linux 
ARM](https://archlinuxarm.org), a port of Arch Linux for ARM computers. 
Raspbian, the default OS, would have been just a waste.

## Which SD card to use?

We have chosen a 16 GB SanDisk microSD, which was a good compromise 
between price, reliability and storage capacity. Since SD cards are 
relatively fragile memory devices, we think that if you plan to use a 
lot of space, you had better buy an external hard disk and maintain on 
the SD card only what is necessary for the system, rather than buying a 
more capable SD.

## How to set up the card (manual version)

We will now explain the recipe we followed to install Arch Linux ARM, 
for which we used a Raspberry Pi, an SD card and another computer 
running Ubuntu. Also, an internet connection is required.

### Partitioning and formatting

First of all, we need to get rid of whatever is in the SD and nicely 
partition and format it according to our needs. Partitioning a storage 
device means to separate it into independent sections, and it has 
several advantages (see for instance [this wikipedia 
page](https://en.wikipedia.org/wiki/Disk_partitioning)). It certainly 
has disadvantages as well, but remember, we have bought raspi to 
experiment and learn, so when there is a chance to complicate our lives, 
we take it.

We are adopting the following scheme, which has extensively proved 
worthy over the time:

| Partition		| Size			| Filesystem type	|
|---------------|--------------:|:-----------------:|
| `/boot`		| 100 MiB		| vfat				|
| `/`			| 8 GiB			| ext4				|
| `/usr/local`	| 1 GiB			| ext4				|
| `/var`		| 3 GiB			| ext4				|
| `/home`		| 1.8 GiB		| ext4				|
| `swap`		| 1 GiB			| swap				|

`/boot` *must* be in the first partition of the disk, separated from `/` 
and all the rest, in order for the raspberry to work; `/var` contains 
log files and caches that can take up a lot of space, thus we think it 
is safer to isolate this directory in its own partition; `/usr/local` is 
often used for locally installed programs, while `/home` for the users' 
files (such files will be protected if we wanted install another OS). 
Finally, there is a swap partition, i.e. a space in the SD card which 
can be used as a kind of RAM when the computer experiences a bad time.
Everything is formatted with ext4 filesystem, except `/boot`, which 
*must* be FAT32, and swap, which has its own kind. To create and format 
the partitions we used fdisk, mkfs, mkswap and swapon as described 
[here](https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-3), 
[here](https://wiki.archlinux.org/index.php/Partitioning) and 
[here](https://wiki.archlinux.org/index.php/Swap).

### Installing Arch Linux ARM

Finally, we downloaded the .tar.gz archive of the OS, extracted the 
files and moved them in their respective partition, following [this 
guide](https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-3). 
We also had to make a few changes to the `/etc/fstab` which came with 
the default installation, otherwise our beautiful partitions would not 
have even been mounted. We provide here the fstab we used, but read 
[this](https://wiki.archlinux.org/index.php/fstab) if you want to know 
more.

## How to set up the card (automated version)

We made a little script, which exploits previously generated partition 
table and fstab, to automate the process we have just described, but 
before using it you should understand what it does, especially because 
it was not written with compatibility in mind... However, if you read it 
you could at least get an idea of the passages that are involved and 
then adapt the commands to your needs. Any comment on the script will be 
appreciated.

## Static IP

We can now insert the SD inside the Pi, plug the power supply and log in 
using the following credentials:

user:		alarm  
password:	alarm

Once logged in, you can become root with the `su` command, entering the 
password "root". As we do not have monitor and keyboard to attach the 
Raspberry to, we will be able to log in only through ssh. We therefore 
open the administration page of our router, an ASUS DSL-N12E, and look 
for the LAN IP of the device, expecting something like 192.168.1.xxx. 
However, it is convenient to configure a DHCP static IP so that when we 
log in from the LAN the IP will always be the same. To do so, we went to 
the `Network->LAN->DHCP static IP` section in the router administration 
page. Next, we can add a line to the `/etc/hosts` of our laptops, so 
that "raspi" will be associated to the static IP we chose; google this 
file if you want to know how it works.

## Uncorking

Well, we hope you now have your raspberry up and working, so it is time 
to celebrate. Let us know if you found this guide useful or wrong!
