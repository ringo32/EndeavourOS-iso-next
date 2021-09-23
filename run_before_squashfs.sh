#!/usr/bin/env bash

# Made by Fernando "maroto"
# Run anything in the filesystem right before being "mksquashed"
# ISO-NEXT specific cleanup removals and additions (08-2021) @killajoe and @manuel

script_path=$(readlink -f ${0%/*})
work_dir=work

# Adapted from AIS. An excellent bit of code!
arch_chroot(){
    arch-chroot $script_path/${work_dir}/x86_64/airootfs /bin/bash -c "${1}"
}

do_merge(){

arch_chroot "

# prepare livesession settings and user
sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
usermod -s /usr/bin/bash root
cp -aT /etc/skel/ /root/
rm /root/xed.dconf
chmod 700 /root
useradd -m -p \"\" -g users -G 'sys,rfkill,wheel' -s /bin/bash liveuser

# insert special desktop settings for installer livesession
# placing needed config files for user tools
# set permissions
git clone https://github.com/endeavouros-team/liveuser-desktop-settings.git
cd liveuser-desktop-settings
rm -R /home/liveuser/.config
cp -R .config /home/liveuser/
chown -R liveuser:liveuser /home/liveuser/.config
cp .xinitrc .xprofile .Xauthority /home/liveuser/
chown liveuser:liveuser /home/liveuser/.xinitrc
chown liveuser:liveuser /home/liveuser/.xprofile
chown liveuser:liveuser /home/liveuser/.Xauthority
cp user_pkglist.txt /home/liveuser/
chown liveuser:liveuser /home/liveuser/user_pkglist.txt
cp user_commands.bash /home/liveuser/
chown liveuser:liveuser /home/liveuser/user_commands.bash
rm /home/liveuser/.bashrc
cp .bashrc /home/liveuser/
chown liveuser:liveuser /home/liveuser/.bashrc
cp LICENSE /home/liveuser/
dbus-launch dconf load / < dconf/xed.dconf
sudo -H -u liveuser bash -c 'dbus-launch dconf load / < dconf/xed.dconf'
cd ..
rm -R liveuser-desktop-settings
chmod -R 700 /root
chown root:root -R /root
chown root:root -R /etc/skel
chmod 644 /usr/share/endeavouros/*.png
rm -rf /usr/share/backgrounds/xfce/xfce-verticals.png
ln -s /usr/share/endeavouros/backgrounds/endeavouros-wallpaper.png /usr/share/backgrounds/xfce/xfce-verticals.png
chsh -s /bin/bash

# fixing permission on other file paths
chmod 755 /etc/sudoers.d
mkdir -p /media
chmod 755 /media
chmod 440 /etc/sudoers.d/g_wheel
chown 0 /etc/sudoers.d
chown 0 /etc/sudoers.d/g_wheel
chown root:root /etc/sudoers.d
chown root:root /etc/sudoers.d/g_wheel
chmod 755 /etc

# fix configurations
sed -i 's/#\(PermitRootLogin \).\+/\1yes/' /etc/ssh/sshd_config
# sed -i 's/#Server/Server/g' /etc/pacman.d/mirrorlist
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf
sed -i 's/#\(HandleSuspendKey=\)suspend/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleHibernateKey=\)hibernate/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleLidSwitch=\)suspend/\1ignore/' /etc/systemd/logind.conf

# enable systemd services
systemctl enable NetworkManager.service vboxservice.service vmtoolsd.service vmware-vmblock-fuse.service systemd-timesyncd
systemctl set-default multi-user.target

# revert from arch-iso preset to default preset
cp -rf /usr/share/mkinitcpio/hook.preset /etc/mkinitcpio.d/linux.preset
sed -i 's?%PKGBASE%?linux?' /etc/mkinitcpio.d/linux.preset

# fetch fallback mirrorlist for offline installs:
wget https://raw.githubusercontent.com/endeavouros-team/EndeavourOS-iso-next/main/mirrorlist
cp mirrorlist /etc/pacman.d/
rm mirrorlist

# set EndeavourOS specific grub config
#sed -i 's|^GRUB_CMDLINE_LINUX_DEFAULT=\"\(.*\)\"$|GRUB_CMDLINE_LINUX_DEFAULT=\"\1 nowatchdog\"|' /etc/default/grub
#sed -i 's?GRUB_DISTRIBUTOR=.*?GRUB_DISTRIBUTOR=\"EndeavourOS\"?' /etc/default/grub
#sed -i 's?\#GRUB_THEME=.*?GRUB_THEME=\/boot\/grub\/themes\/EndeavourOS\/theme.txt?g' /etc/default/grub
#sed -i 's?\#GRUB_DISABLE_SUBMENU=y?GRUB_DISABLE_SUBMENU=y?g' /etc/default/grub
#echo 'GRUB_DISABLE_OS_PROBER=false' >> /etc/default/grub
# patching the same now:
patch -u /etc/default/grub -i /root/grub.patch
rm /root/grub.patch

# get default mkinitcpio.conf (possible patching it here)
wget https://raw.githubusercontent.com/archlinux/mkinitcpio/master/mkinitcpio.conf
patch -u mkinitcpio.conf -i /root/mkinitcpio.patch
cp mkinitcpio.conf /etc/
rm mkinitcpio.conf /root/mkinitcpio.patch

# remove unneeded grub stuff from /boot
# rm /boot/grub/grub.cfg #archiso does not create it anymore
rm -R /boot/syslinux
rm -R /boot/memtest86+
rm /boot/amd-ucode.img
rm /boot/initramfs-linux.img
rm /boot/intel-ucode.img
rm /boot/vmlinuz-linux

# to install locally builded packages on ISO:
#pacman -U --noconfirm /root/calamares_current-3.2.42-10-any.pkg.tar.zst
#rm /root/calamares_current-3.2.42-10-any.pkg.tar.zst
#pacman -U --noconfirm /root/calamares_config_next-2.3-8-any.pkg.tar.zst
#rm /root/calamares_config_next-2.3-8-any.pkg.tar.zst
#rm /var/log/pacman.log

# custom fixes currently needed

# fix for r8169 module
sed -i /usr/lib/modprobe.d/r8168.conf -e 's|r8169|r8168|'
"
}

#################################
########## STARTS HERE ##########
#################################

do_merge
