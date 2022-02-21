#!/bin/bash 

boot_partition=$1
efi_partition=$2
root_partition=$3
username=$4
hostname=$5
password=$6
root_password=$7
dual_boot=$8

function error () {
    echo "ERROR: $1" 1>&2
}

check_net_availability() {
    echo "Checking if internet is available" 

    rcvd_packets=$(ping -c 3 google.com | grep packet | cut -d ' ' -f 4)

    if [ $rcvd_packets -eq 0 ]
    then
        error "No internet connection. Exiting script."
        exit
    fi
}

# Patition the disk manually with cfdisk since there might be 
# risk overwriting existing partitions. TODO: Automate this step

#partition_disk() {
#    cfdisk $1
#
#    echo "Enter EFI partition:"
#    read efi_partition
#    echo "Enter boot partition:"
#    read boot_partition
#    echo "Enter root partition:"
#    read root_partition
#}

encrypt_partitions() {
    echo "Loading kernel modules"
    modprobe dm-crypt
    modprobe dm-mod

    echo "Encrypting root partition"

    cryptsetup luksFormat -v -s 512 -h sha512 $root_partition 
    echo "Opening the encrypted partition" 
    cryptsetup open $root_partition luks_root 
}

format_partitions() {
    if [ ! "$1" ]
    then
        echo "Formatting the EFI System Partition"
        mkfs.vfat -n "EFI" $efi_partition
    fi

	echo "Formatting the boot Partition"
	mkfs.ext4 -L boot $boot_partition

	echo "Formatting the root Partition"
	mkfs.ext4 -L root /dev/mapper/luks_root
}

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

create_swap() {
	echo "Creating swap"
	dd if=/dev/zero of=swap bs=1M count=1024
	mkswap swap
	swapon swap

	echo "Changing swap file permissions to 0600"
	chmod 0600 swap
}

#Get choice if formatting, encrypting, mounting and creating swap is needed
#get_choice() {
#    echo "Encrypt and mount partitions? (Y/N):"
#    while [ true ]
#    do
#        read choice
#        case $choice in
#            Y|y|N|n)
#                break
#                ;;
#            *)
#                echo "Error: Please enter Y/y or N/n:"
#                ;;
#        esac
#    done
#}

install_base() {
    pacstrap /mnt base base-devel efibootmgr grub networkmanager linux linux-firmware 

    genfstab -U /mnt > /mnt/etc/fstab

    echo "Setting password for root"
    #arch-chroot /mnt passwd root
    arch-chroot /mnt /bin/bash << END
echo -e "$root_password\n$root_password" | passwd root
END
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

add_admin_user() {
    echo "Adding admin user $username and setting password..."

    arch-chroot /mnt useradd -m $username
    arch-chroot /mnt /bin/bash << END
echo -e "$password\n$password" | passwd $username
END

    echo "Moving pkg.list inside chroot"
    cp $HOME/configs/pkg.list /mnt/tmp/
}

enable_services() {
    echo "Enabling services"
    arch-chroot /mnt /bin/bash -x << END
echo "Enabling NetworkManager"
systemctl enable NetworkManager
END
}

change_permissions() {
    echo "Give permissions directory /home/$username to $username"
    arch-chroot /mnt chown -R $username:$username /home/$username
}

check_net_availability
#get_choice
#[[ $choice =~ [Yy] ]] && encrypt_partitions && format_partitions && mount_partitions && create_swap
encrypt_partitions && format_partitions $dual_boot && mount_partitions && create_swap
install_base
add_admin_user
enable_services
change_permissions

echo "Base linux installation finished"
