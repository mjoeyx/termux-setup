#!/bin/bash

# By Mjoeyx | TG : [ @mj0ey ]

red="\033[1;31m"
white="\033[0m"
green="\033[1;32m"
defaults=0


start() {
    # Setup Storage Permissions
    ! [[ -w /sdcard && -r /sdcard ]] && termux-setup-storage

    clear

    local menu="${green}Main Menu:${white}"

    local options="
  1. Install Beberapa Paket Penting.
  2. Kustomisasi Termux.
  3. Install 1 & 2 (Menggunakan preset untuk kustomisasi)
  4. Setup Debian di Termux.
  5. Keluar
"
    all() {
        export defaults=1
        package_setup
        customize
    }

    export start_options=(
        [1]="package_setup"
        [2]="customize"
        [3]="all"
        [4]="setup_debian"
        [5]="exit_"
    )

    ask "${options}" "${menu}" "start_options"
}


customize() {
    clear
    local menu="${green}Customisation Menu:${white}"

    customize_all() {
        echo -e "${green}Customising All.${white}"
        export defaults=1
        setup_apm
        setup_aria2
        setup_ytdlp
        setup_prettify
        setup_rxfetch
        change_cursor
        change_ui
        sleep 2
        clear
        rxfetch
    }

    [[ $defaults -eq 1 ]] && customize_all && return 0

    export option_dict=(
            [1]="setup_apm"
            [2]="setup_aria2"
            [3]="setup_ytdlp"
            [4]="setup_prettify"
            [5]="setup_rxfetch"
            [6]="change_cursor"
            [7]="change_ui"
            [8]="customize_all"
            [9]="start"
            [10]="exit_"
        )

    local options="
  1. Pengaturan Android Package Manager by Mjoeyx.
  2. Pengaturan Aria2 Shortcut.
  3. Aktifkan pengunduhan atau tautan yang didukung YT-DLP ke Termux.
  4. Pengaturan 'prettify' Bunch of py formatting tools.
  5. Pengaturan Rxfetch.
  6. Ubah Gaya Kursor.
  7. Ubah Warna dan Font.
  8. Install Semua yang ada di atas. ( Menggunakan Presets )
  9. Kembali ke Menu Sebelumnya.
  10. Keluar
"

    ask "${options}" "${menu}" "option_dict"

}


ask() {
    local header="Apa yang ingin Anda Pilih?"
    local option_text="$1"
    local menu="$2"
    local dict_name=$3

    echo -e "${menu}\n${header}${option_text}"

    while true; do

        read -r -p "> " choice

        if [ -z "${choice}" ]; then
            clear
            echo -e "${menu}\n${header}${red}\n Pilih Opsi.${white}${option_text}"

        elif [[ -v ${dict_name}[$choice] ]]; then
            eval "\${${dict_name}[$choice]}"
            break

        else
            clear
            echo -e "${menu}\n${header}${red}\n Invalid Input: ${white}${choice}${option_text}"
        fi

    done
}


package_setup() {
    # Update Termux Package Repository
    termux-change-repo

    yes | pkg upgrade
    apt update -y && apt upgrade -y

    # Install necessary packages
    apt install -y \
        aria2 \
        curl \
        ffmpeg \
        git \
        gh \
        openssh \
        python \
        python-pip \
        tmux \
        tsu \
        wget

    # Update and Install pip packages
    pip install -U \
        wheel \
        setuptools \
        yt-dlp \
        black \
        isort \
        autoflake
}


setup_debian() {
    apt update
    apt install -y root-repo x11-repo
    apt install -y \
        proot \
        proot-distro \
        termux-x11-nightly \
        pulseaudio

    proot-distro install debian

    clear

    local options="
1. Install xfce4
2. Install KDE
3. Exit
"
    wm=""
    wm_cmd=""

    export wm_dict=(
        [1]="export wm=xfce4 wm_cmd=startxfce4"
        [2]="export wm=kde-standard wm_cmd=startplasma-x11"
        [3]="exit_"
    )

    ask "${options}" "Window Manager Menu:" "wm_dict"

    proot-distro login debian --termux-home --shared-tmp -- bash -c "
        apt update -y

        apt install -y \
            firefox-esr \
            ${wm} \
            xfce4-goodies \
            locales \
            fonts-noto-cjk 

        ln -sf /usr/share/zoneinfo/Asia/Calcutta /etc/localtime

        echo en_US.UTF-8 UTF-8 >> /etc/locale.gen

        locale-gen

        echo 'LANG=en_US.UTF-8' > /etc/locale.conf 
        "

    curl -s -O --output-dir "${HOME}" \
        https://raw.githubusercontent.com/anonymousx97/termux-setup/main/scripts/debian.sh

    sed -i "s/wm_start_cmd/${wm_cmd}/" "${HOME}/debian.sh"

    echo '
alias dcli="proot-distro login debian --termux-home --shared-tmp -- bash"
alias dgui="bash debian.sh"
'>> "${HOME}/.bashrc"

    echo '[[ "$(whoami)" == "root" ]] && export HISTFILE=~/.debian_history' >> "${HOME}/.bashrc"

    echo "Done."

    echo -e "You can now use '${green}dcli${white}' for debian cli and '${green}dgui${white}' for GUI (Termux x11 app required)."

}


setup_apm() {
    echo -e "\n1. Downloading Android Package Manager By Mjoeyx."

    curl -s -O --output-dir "${PATH}" \
        https://raw.githubusercontent.com/mjoeyx/termux-setup/main/bin/apm

    chmod +x "${PATH}/apm"

    echo -e "${green}Done.${white} use 'apm' to call it."
}


setup_aria2() {
    echo -e "\n2. Downloading Aria2 shortcut"

    curl -s -O --output-dir "${PATH}" \
        https://raw.githubusercontent.com/anonymousx97/termux-setup/main/bin/arc

    chmod +x "${PATH}/arc"

    echo -e "${green}Done.${white}"
}


setup_ytdlp() {
    echo -e "\n3. Mengunduh files dan menyiapkan Magent & YT-DLP"

    mkdir -p "${HOME}/bin"

    curl -s -O --output-dir "${HOME}/bin" \
        https://raw.githubusercontent.com/anonymousx97/termux-setup/main/bin/termux-url-opener

    echo -e "${green}Done.${white}"
}


setup_prettify() {
    echo -e "\n4. Mengunduh dan Menyiapkan Prettify script."

    curl -s -O --output-dir "${PATH}" \
        https://raw.githubusercontent.com/anonymousx97/termux-setup/main/bin/prettify

    chmod +x "${PATH}/prettify"

    echo -e "${green}Done.${white}"
}


setup_rxfetch() {
    echo -e "\n5. Mengunduh dan Menyiapkan Rxfetch"

    curl -s -O --output-dir "${PATH}" \
        https://raw.githubusercontent.com/anonymousx97/termux-setup/main/bin/rxfetch

    chmod +x "${PATH}/rxfetch"

    local motd="#!$SHELL\nbash rxfetch"

    if [[ -f ~/.termux/motd.sh && $defaults -eq 0 ]]; then
        echo -e "${red}A custom start script exists in the path ${HOME}/.termux/motd.sh${white}"
        echo -e "  Tulis 1 untuk menimpa file saat ini.\n  Tekan Enter untuk Lewati."

        read -r -p "> " prompt

        if [[ ! "${prompt}" || ! "${prompt}" == 1 ]]; then
            echo -e "${green}Melewatkan modifikasi MOTD.${white}"

        else
            echo -e "${red}Menimpa MOTD.${white}"
            echo -e "${motd}" > ~/.termux/motd.sh
        fi

    else
        echo -e "${motd}" > ~/.termux/motd.sh
    fi

    echo -e "${green}Selesai.${white}"
}


change_cursor() {
    echo -e "\n6. Mengubah Kursor"

    if [[ $defaults -eq 0 ]]; then
        clear

        local menu="Kursor Menu:"

        local options="
  1. Ubah ke ${green}|${white} (bar)
  2. Ubah ke ${green}_${white} (underscore)
  3. Ubah ke Default Block style.
  4. Keluar
"
        export cursor_dict=(
            [1]="eval printf '\e[6 q' && export style=bar"
            [2]="eval printf '\e[4 q' && export style=underline"
            [3]="eval printf '\e[1 q' && export style=block"
            [4]="exit_"
        )

        ask "${options}" "${menu}" "cursor_dict"

    else
        printf '\e[6 q'
        style=bar
    fi

    # Set the style in termux properties
    sed -i "s/.*terminal-cursor-style.*/terminal-cursor-style = ${style}/" "${HOME}/.termux/termux.properties"

    # Change Blink Rate
    sed -i "s/.*terminal-cursor-blink-rate.*/terminal-cursor-blink-rate = 600/" "${HOME}/.termux/termux.properties"

    echo -e "${green}Selesai.${white}"
}


change_ui() {
    echo -e "\n7. Mengubah Warna dan Font."

    local colors="colors.properties.dark_blue"

    if [[ $defaults -eq 0 ]]; then

        local ui_options="\n1. Set Dark Blue\n2. Set Light Blue"

        export ui_dict=(
            [1]="export colors=colors.properties.dark_blue"
            [2]="export colors=colors.properties.light_blue"
        )

        clear
        ask "${ui_options}" "${green}UI Menu${white}" "ui_dict"
    fi

    curl -s -o "${HOME}/.termux/colors.properties" \
        https://raw.githubusercontent.com/anonymousx97/termux-setup/main/.termux/"${colors}"

    wget -q -O "${HOME}/.termux/font.ttf" \
        https://raw.githubusercontent.com/anonymousx97/termux-setup/main/.termux/MesloLGS_NF_Bold.ttf

    echo -e "\n${green}Menerapkan Perubahan.${white}"

    termux-reload-settings

    echo -e "${green}Selesai.${white}"
}


exit_() {
    echo -e "${green}Keluar...${white}"
    exit
}


save_setup_sh() {
    [[ -f "${PATH}/setup-termux" ]] && return 0

    echo -e "\nMenyimpan setup.sh untuk digunakan kapan saja."

    echo -e \
            '#!/bin/bash\nbash -c "$(curl -fsSL https://raw.githubusercontent.com/anonymousx97/termux-setup/main/setup.sh)"' \
            > "${PATH}/setup-termux"

    chmod +x "${PATH}/setup-termux"

    echo -e "${green}Selesai\n${white}Sekarang Silahkan Ketik${green}'setup-termux'${white}untuk kembali ke menu saat ini."

}

start
save_setup_sh
