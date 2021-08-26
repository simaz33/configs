#!/bin/bash -x

# Check if there is internet connection by pinging google.com 
# and checking if there are any received packets
echo "Checking if internet is available" 

rcvd_packets=$(ping -c 3 google.com | grep packet | cut -d ' ' -f 4)

if [ $rcvd_packets -eq 0 ]
then
    echo "ERROR: No internet connection. Exiting script."
    exit
fi

# Install "jq" tool
echo "Installing jq" 

pacman -Sy && pacman -S jq --noconfirm

# Patition the disk manually with cfdisk since there might be 
# risk overwriting existing partitions. TODO: Automate this step

cfdisk /dev/sda

echo "Enter EFI partition:"
read efi_partition
echo "Enter boot partition:"
read boot_partition
echo "Enter root partition:"
read root_partition

#Configure LUKS Encryption on the Disk
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

if [[ $choice =~ [Yy] ]]
then
	echo "Loading kernel modules"
	modprobe dm-crypt
	modprobe dm-mod

	echo "Encrypting root partition"

	cryptsetup luksFormat -v -s 512 -h sha512 $root_partition 
	echo "Opening the encrypted partition" 
	cryptsetup open $root_partition luks_root 

	#Foramtting and Mounting the Partitions
	echo "Formatting the EFI System Partition"
	mkfs.vfat -n "EFI" $efi_partition

	echo "Formatting the boot Partition"
	mkfs.ext4 -L boot $boot_partition

	echo "Formatting the root Partition"
	mkfs.ext4 -L root /dev/mapper/luks_root

	echo "Mounting the root partition"
	mount /dev/mapper/luks_root /mnt
	cd /mnt
	mkdir boot

	echo "Mounting the boot partition"
	mount $boot_partition boot

	echo "Mounting the efi partition"
	mkdir boot/efi
	mount $efi_partition boot/efi

	echo "Creating swap"
	dd if=/dev/zero of=swap bs=1M count=1024
	mkswap swap
	swapon swap

	echo "Changing swap file permissions to 0600"
	chmod 0600 swap
fi

#Installing Arch Linux
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
echo funy > /etc/hostname

cat << EOF >> /etc/hosts 
127.0.0.1    localhost funy
::1          localhost funy
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

#Adding another admin user and customizations
username=funy
echo "Adding admin user $username and setting password:"

arch-chroot /mnt useradd -m $username
arch-chroot /mnt passwd $username

echo "Moving pkg.list inside chroot"
cp $HOME/configs/pkg.list /mnt/home/$username/

echo "Adding customizations"
arch-chroot /mnt /bin/bash -x << END
echo "Adding $username to sudoers"
sed -i "s/root ALL=(ALL) ALL/root ALL=(ALL) ALL\n$username ALL=(ALL) ALL/g" /etc/sudoers

echo "Installing packages"
pacman -S --needed --noconfirm - < /home/$username/pkg.list 
END

echo "Installing custom packages"
install_polybar_aur
install_YouCompleteMe
install_vim_plug

echo "Moving dotfiles"
mv $HOME/configs/dotfiles/.* /mnt/home/$username/

echo "Moving configuration files in .config"
arch-chroot /mnt /bin/bash -x << END
[ -d /home/$username/.config ] || mkdir /home/$username/.config
END

mv $HOME/configs/config/* /mnt/home/$username/.config


echo "Enabling services"
arch-chroot /mnt /bin/bash -x << END
echo "Enabling NetworkManager"
systemctl enable NetworkManager

echo "Enabling sddm"
systemctl enable sddm
END

echo "Give permission to /home/$username to $username"
arch-chroot /mnt chown -R $username:$username /home/$username

echo "Installation finished"
echo "Rebooting.."
reboot

# Helping functions
install_polybar_aur () {
arch-chroot /mnt /bin/bash -x << END
git clone https://aur.archlinux.org/polybar.git
cd polybar
makepkg -s -i --noconfirm
cd ..

git clone https://aur.archlinux.org/ttf-unifont.git
cd ttf-unifont
makepkg -s -i --noconfirm
cd ..

git clone https://aur.archlinux.org/siji-git.git
cd siji-git
makepkg -s -i --noconfirm
cd ..
END
}

install_YouCompleteMe () {
arch-chroot /mnt /bin/bash -x << END
git clone https://github.com/ycm-core/YouCompleteMe.git
cd YouCompleteMe 
python3 install.py --all
END
}

install_vim_plug () {
arch-chroot /mnt /bin/bash -x << END
curl -fLo /home/$username/.vim/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
END
}
