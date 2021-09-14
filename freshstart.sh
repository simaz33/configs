#!/bin/bash 

username=funy
hostname=funy

# Helping functions
install_polybar_aur () {
    arch-chroot /mnt /bin/bash -x << END
git clone https://aur.archlinux.org/polybar.git
chown -R $username:$username polybar
su funy
cd polybar
makepkg -s -i --noconfirm
cd ..
exit

git clone https://aur.archlinux.org/ttf-unifont.git
chown -R $username:$username ttf-unifont
su funy
cd ttf-unifont
makepkg -s -i --noconfirm
cd ..
exit

git clone https://aur.archlinux.org/siji-git.git
chown -R $username:$username siji-git
su funy
cd siji-git
makepkg -s -i --noconfirm
cd ..
exit
END
}

install_i3lock_color_aur() {
    arch-chroot /mnt /bin/bash -x << END
git clone https://aur.archlinux.org/i3lock-color.git
chown -R $username:$username i3lock-color
su funy
cd i3lock-color
makepkg -s -i --noconfirm
cd ..
exit
END
}

install_vim_plug () {
arch-chroot /mnt /bin/bash -x << END
curl -fLo /home/$username/.vim/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
END
}
# Check if there is internet connection by pinging google.com 
# and checking if there are any received packets
check_net_availability() {
    echo "Checking if internet is available" 

    rcvd_packets=$(ping -c 3 google.com | grep packet | cut -d ' ' -f 4)

    if [ $rcvd_packets -eq 0 ]
    then
        echo "ERROR: No internet connection. Exiting script."
        exit
    fi
}

# Patition the disk manually with cfdisk since there might be 
# risk overwriting existing partitions. TODO: Automate this step

partition_disk() {
    cfdisk $1

    echo "Enter EFI partition:"
    read efi_partition
    echo "Enter boot partition:"
    read boot_partition
    echo "Enter root partition:"
    read root_partition
}

#Configure LUKS Encryption on the Disk
encrypt_partitions() {
    echo "Loading kernel modules"
    modprobe dm-crypt
    modprobe dm-mod

    echo "Encrypting root partition"

    cryptsetup luksFormat -v -s 512 -h sha512 $root_partition 
    echo "Opening the encrypted partition" 
    cryptsetup open $root_partition luks_root 
}

#Foramtting partitions
format_partitions() {
	echo "Formatting the EFI System Partition"
	mkfs.vfat -n "EFI" $efi_partition

	echo "Formatting the boot Partition"
	mkfs.ext4 -L boot $boot_partition

	echo "Formatting the root Partition"
	mkfs.ext4 -L root /dev/mapper/luks_root
}

#Mounting partitions
mount_partitions() {
	echo "Mounting the root partition"
	mount /dev/mapper/luks_root /mnt
	cd /mnt
	mkdir boot

	echo "Mounting the boot partition"
	mount $boot_partition boot

	echo "Mounting the efi partition"
	mkdir boot/efi
	mount $efi_partition boot/efi
}

#Create swap
create_swap() {
	echo "Creating swap"
	dd if=/dev/zero of=swap bs=1M count=1024
	mkswap swap
	swapon swap

	echo "Changing swap file permissions to 0600"
	chmod 0600 swap
}

#Get choice if formatting, encrypting, mounting and creating swap is needed
get_choice() {
    echo "Encrypt and mount partitions? (Y/N):"
    while [ true ]
    do
        read choice
        case $choice in
            Y|y|N|n)
                break
                ;;
            *)
                echo "Error: Please enter Y/y or N/n:"
                ;;
        esac
    done

    return $choice
}

#Installing Arch Linux
install_base() {
    pacstrap /mnt base base-devel efibootmgr grub networkmanager linux linux-firmware 

    genfstab -U /mnt > /mnt/etc/fstab

    echo "Set password for root: "
    arch-chroot /mnt passwd root
    echo "Password for root was set"

    arch-chroot /mnt /bin/bash -x << END

locale="en_US.UTF-8 UTF-8"
echo "Selecting locale - \$locale" 
echo "Executing sed -i 's/#\$locale/\$locale/g' /etc/locale.gen"
sed -i "s/#\$locale/\$locale/g" /etc/locale.gen
locale-gen

lang="en_US.UTF-8"
echo LANG=\$lang > /etc/locale.conf
export LANG=\$lang

echo "Setting time zone"
ln -sf /usr/share/zoneinfo/Europe/Vilnius /etc/localtime

echo "Setting hardware clock"
hwclock --systohc --utc

echo "Setting hostname"
echo $hostname > /etc/hostname

cat << EOF >> /etc/hosts 
127.0.0.1    localhost $hostname
::1          localhost $hostname
EOF

echo "Editing grub config to use encrypted partition"
sed -i "s|GRUB_CMDLINE_LINUX=\"\"|GRUB_CMDLINE_LINUX=\"cryptdevice=$root_partition:luks_root\"|g" /etc/default/grub
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub

echo "Editing hooks"
sed -i 's/block/block encrypt/g' /etc/mkinitcpio.conf
mkinitcpio -p linux

echo "Installing GRUB"
grub-install --boot-directory=/boot --efi-directory=/boot/efi $boot_partition
grub-mkconfig -o /boot/grub/grub.cfg
grub-mkconfig -o /boot/efi/EFI/arch/grub.cfg
END

    echo "Base installation finished, proceeding with customizations"
}

#Adding another admin user 
add_admin_user() {
    echo "Adding admin user $username and setting password:"

    arch-chroot /mnt useradd -m $username
    arch-chroot /mnt passwd $username

    echo "Moving pkg.list inside chroot"
    cp $HOME/configs/pkg.list /mnt/home/$username/
}

install_customizations() {
    echo "Adding customizations"
    arch-chroot /mnt /bin/bash -x << END
echo "Adding $username to sudoers"
sed -i "s/root ALL=(ALL) ALL/root ALL=(ALL) ALL\n$username ALL=(ALL) ALL/g" /etc/sudoers

echo "Installing packages"
pacman -S --needed --noconfirm - < /home/$username/pkg.list 
END

}

install_custom_packages() {
    echo "Installing AUR and other custom packages"
    install_polybar_aur
    install_i3lock_color_aur
    install_vim_plug
}

move_dotfiles() {
    echo "Moving dotfiles"
    mv $HOME/configs/dotfiles/.* /mnt/home/$username/

    echo "Moving configuration files in .config"
    [ -d /mnt/home/$username/.config ] || mkdir /mnt/home/$username/.config

    mv $HOME/configs/config/* /mnt/home/$username/.config
}

enable_services() {
    echo "Enabling services"
    arch-chroot /mnt /bin/bash -x << END
echo "Enabling NetworkManager"
systemctl enable NetworkManager

echo "Enabling sddm"
systemctl enable sddm
END
}

#Give permissions to the main user created in earlier steps
change_permissions() {
    echo "Give permission to /home/$username to $username"
    arch-chroot /mnt chown -R $username:$username /home/$username
}

check_net_availability
partition_disk
choice=get_choice
[[ $choice =~ [Yy] ]] && encrypt_partitions && format_partitions && mount_partitions && create_swap
install_base
add_admin_user
install_customizations
install_custom_packages
move_dotfiles
enable_services
change_permissions

echo "Installation finished"
echo "Rebooting.."
reboot
