# EndeavourOS-iso-next 

Maintaner: <joekamprad@endeavouros.com> with the help of our beloved community

# The new ISO for EndeavourOS based on archiso sources and massive EndeavourOS scripts and changes 


## Install necessary packages
`sudo pacman -S archiso mkinitcpio-archiso git squashfs-tools --needed`

Clone:\
`git clone https://github.com/endeavouros-team/EndeavourOS-iso-next.git`

`cd EndeavourOS-iso-next`

## Run fix permissions script
`sudo ./fix_permissions.sh`

## Build
`sudo ./mkarchiso /path/to/profile` 

path is where you clone the ISO structure... 

## The iso appears at `out` folder

to install locally builded packages on ISO:
you can do so like that putting the packages inside ISO-next/airootfs/root/ and use this lines:

`pacman -U --noconfirm /root/calamares_current-3.2.41.1-5-any.pkg.tar.zst`

`rm /root/calamares_current-3.2.41.1-5-any.pkg.tar.zst`

`pacman -U --noconfirm /root/calamares_config_next-2.0-4-any.pkg.tar.zst`

`rm /root/calamares_config_next-2.0-4-any.pkg.tar.zst`
