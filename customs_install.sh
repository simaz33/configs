#!/bin/bash

username=$1

install_polybar_aur () {
    arch-chroot /mnt /bin/bash -x << END
su -c 'cd /home/$username && git clone https://aur.archlinux.org/polybar.git && cd polybar && makepkg -s -i --noconfirm' -s /bin/sh $username

su -c 'cd /home/$username && git clone https://aur.archlinux.org/ttf-unifont.git && cd ttf-unifont && makepkg -s -i --noconfirm' -s /bin/sh $username

su -c 'cd /home/$username && git clone https://aur.archlinux.org/siji-git.git && cd siji-git && makepkg -s -i --noconfirm' -s /bin/sh $username
END
}

install_i3lock_color_aur() {
    arch-chroot /mnt /bin/bash -x << END
su -c 'cd /home/$username && git clone https://aur.archlinux.org/i3lock-color.git && cd i3lock-color && makepkg -s -i --noconfirm' -s /bin/sh $username
END
}

install_vim_plug () {
    arch-chroot /mnt /bin/bash -x << END
su -c 'curl -fLo /home/$username/.vim/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' -s /bin/sh $username
END
}

add_user_to_sudoers() {
    arch-chroot /mnt /bin/bash -x << END
echo "Adding $username to /etc/sudoers"
sed -i "s/root ALL=(ALL:ALL) ALL/root ALL=(ALL:ALL) ALL\n$username ALL=(ALL:ALL) NOPASSWD: ALL/g" /etc/sudoers
END
}

install_custom_packages() {
    echo "Adding customizations"
    arch-chroot /mnt /bin/bash -x << END

echo "Installing packages"
pacman -S --needed --noconfirm - < /home/$username/pkg.list 
END

}

install_aur_packages() {
    echo "Installing AUR and other custom packages"
    install_polybar_aur
    install_i3lock_color_aur
    install_vim_plug
}

move_dotfiles() {
    echo "Moving dotfiles"
    mv -f $HOME/configs/dotfiles/.* /mnt/home/$username/

    echo "Moving configuration files in .config"
    [ -d /mnt/home/$username/.config ] || mkdir /mnt/home/$username/.config

    mv -f $HOME/configs/config/* /mnt/home/$username/.config/
}

enable_services() {
    echo "Enabling services"
    arch-chroot /mnt /bin/bash -x << END
echo "Enabling sddm"
systemctl enable sddm
END
}

add_user_to_sudoers
install_custom_packages
install_aur_packages
move_dotfiles
enable_services

echo "Customizations installed"
