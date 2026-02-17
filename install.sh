#!/usr/bin/env bash

# =======================================
#   AUTHOR    : SDGAMER (Enhanced)
#   TOOL      : DEBIAN 11/12/13 RDP INSTALLER
# =======================================

# ---------- COLORS ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# ---------- ROOT CHECK ----------
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: This script must be run as root! Use 'sudo -i' or 'sudo su'.${NC}"
   exit 1
fi

# ---------- OS DETECTION ----------
detect_debian() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$ID" != "debian" ]; then
            echo -e "${RED}Error: Your OS is $ID. This script is ONLY for Debian!${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Error: OS detection failed!${NC}"
        exit 1
    fi
}

# ---------- BANNER ----------
banner() {
clear
echo -e "${CYAN}"
cat <<'EOF'
 ██████╗██████╗  ██████╗  █████╗ ███╗   ███╗███████╗██████╗ 
██╔════╝██╔══██╗██╔════╝ ██╔══██╗████╗ ████║██╔════╝██╔══██╗
╚█████╗ ██║  ██║██║  ███╗███████║██╔████╔██║█████╗  ██████╔╝
 ╚════██║██║  ██║██║   ██║██╔══██║██║╚██╔╝██║██╔══╝  ██╔══██╗
██████╔╝██████╔╝╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗██║  ██║
╚═════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝
EOF
echo -e "${GREEN}         DEBIAN 11/12/13 RDP INSTALLER${NC}"
echo "======================================="
}

# ---------- HELPERS ----------
success_msg() {
    echo -e "\n${GREEN}✔ $1 Process Completed Successfully!${NC}"
    echo -e "${YELLOW}Press Enter to return to Menu...${NC}"
    read -r < /dev/tty
}

# Fix for browsers running as root
fix_root_browsers() {
    echo -e "${YELLOW}Applying Root Sandbox Fix for Browsers...${NC}"
    [ -f /usr/bin/google-chrome ] && sed -i 's/exec -a "$0" "$HERE\/chrome" "$@"/exec -a "$0" "$HERE\/chrome" "$@" --no-sandbox/g' /usr/bin/google-chrome
    [ -f /usr/bin/brave-browser ] && sed -i 's/exec -a "$0" "$HERE\/brave" "$@"/exec -a "$0" "$HERE\/brave" "$@" --no-sandbox/g' /usr/bin/brave-browser
    [ -f /usr/bin/opera ] && sed -i 's/exec opera "$@"/exec opera "$@" --no-sandbox/g' /usr/bin/opera
}

# ---------- FULL RDP SETUP ----------
install_rdp_full() {
    banner
    echo -e "${YELLOW}Starting Debian Full RDP Setup (XRDP + XFCE)...${NC}"
    
    echo -e "${CYAN}Set a password for 'root' user (This will be your RDP Login):${NC}"
    passwd root

    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get install -y debconf-utils

    echo "keyboard-configuration keyboard-configuration/layout select English (US)" | debconf-set-selections
    echo "keyboard-configuration keyboard-configuration/layoutcode string us" | debconf-set-selections
    echo "keyboard-configuration keyboard-configuration/modelcode string pc105" | debconf-set-selections

    echo -e "${YELLOW}Installing XFCE4 and XRDP...${NC}"
    apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" xfce4 xfce4-goodies xrdp

    sudo systemctl enable xrdp --now
    echo "xfce4-session" > ~/.xsession
    sudo adduser xrdp ssl-cert
    
    sudo sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config
    
    # Fix Color Management Popups
    cat <<EOF > /etc/polkit-1/localauthority/50-network-manager.d/45-allow-colord.pkla
[Allow Colord]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF

    sudo systemctl restart xrdp
    unset DEBIAN_FRONTEND
    
    success_msg "Debian RDP Setup"
}

# ---------- BROWSERS MENU ----------
browsers_menu() {
    banner
    echo -e "${CYAN}--- [2] WEB BROWSERS ---${NC}"
    echo -e "${YELLOW}1.${NC} Google Chrome"
    echo -e "${YELLOW}2.${NC} Firefox ESR"
    echo -e "${YELLOW}3.${NC} Brave Browser"
    echo -e "${YELLOW}4.${NC} Opera Browser"
    echo -e "${YELLOW}0.${NC} Back"
    echo -ne "${CYAN}Select: ${NC}"
    read -r b < /dev/tty
    case $b in
        1) 
           apt update -y && apt install -y wget
           wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
           apt install -y ./google-chrome*.deb
           rm -f google-chrome*.deb; fix_root_browsers; success_msg "Chrome" ;;
        2) 
           apt update -y && apt install -y firefox-esr; success_msg "Firefox ESR" ;;
        3) 
           apt update -y && apt install -y curl gpg
           curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
           echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list
           apt update -y && apt install -y brave-browser; fix_root_browsers; success_msg "Brave" ;;
        4)
           apt update -y && apt install -y curl gpg
           curl -fsSLo /usr/share/keyrings/opera.gpg https://deb.opera.com/archive.key
           echo "deb [signed-by=/usr/share/keyrings/opera.gpg] https://deb.opera.com/opera-stable/ stable non-free" | tee /etc/apt/sources.list.d/opera-stable.list
           apt update -y && apt install -y opera-stable; fix_root_browsers; success_msg "Opera" ;;
        0) main_menu ;;
        *) browsers_menu ;;
    esac
}

# ---------- SOCIAL & MEDIA MENU ----------
social_menu() {
    banner
    echo -e "${CYAN}--- [6] SOCIAL & MEDIA ---${NC}"
    echo -e "${YELLOW}1.${NC} WhatsApp Desktop (Walc)"
    echo -e "${YELLOW}2.${NC} YouTube Desktop (FreeTube)"
    echo -e "${YELLOW}0.${NC} Back"
    echo -ne "${CYAN}Select: ${NC}"
    read -r s < /dev/tty
    case $s in
        1)
           apt update -y && apt install -y wget
           wget -q https://github.com/WAClient/Walc/releases/download/v0.3.0/walc_0.3.0_amd64.deb
           apt install -y ./walc_0.3.0_amd64.deb; rm -f walc_0.3.0_amd64.deb; success_msg "WhatsApp" ;;
        2)
           apt update -y && apt install -y wget
           wget -q https://github.com/FreeTubeApp/FreeTube/releases/download/v0.21.1-beta/freetube_0.21.1_amd64.deb
           apt install -y ./freetube_0.21.1_amd64.deb; rm -f freetube_0.21.1_amd64.deb; success_msg "YouTube (FreeTube)" ;;
        0) main_menu ;;
        *) social_menu ;;
    esac
}

# ---------- CHECK STATUS ----------
check_status() {
    banner
    echo -e "${CYAN}--- SYSTEM STATUS ---${NC}"
    if systemctl is-active --quiet xrdp; then
        echo -e "XRDP Service: ${GREEN}RUNNING${NC}"
    else
        echo -e "XRDP Service: ${RED}STOPPED${NC}"
    fi
    echo -e "IP Address: ${YELLOW}$(hostname -I | awk '{print $1}')${NC}"
    echo "---------------------------------------"
    success_msg "Status Check"
}

# ---------- MAIN MENU ----------
main_menu() {
    banner
    echo -e "${YELLOW}OS:${NC} Debian $VERSION_ID | ${YELLOW}User:${NC} $USER"
    echo "---------------------------------------"
    echo -e "${CYAN}1.${NC} INSTALL FULL RDP SETUP (XRDP + XFCE)"
    echo -e "${CYAN}2.${NC} Web Browsers (Chrome/Firefox/Brave/Opera)"
    echo -e "${CYAN}3.${NC} Install Tailscale (VPN/Mesh)"
    echo -e "${CYAN}4.${NC} System Clean & Update"
    echo -e "${CYAN}5.${NC} Check RDP Status / IP"
    echo -e "${CYAN}6.${NC} Social & Media (WhatsApp/YouTube)"
    echo -e "${RED}0. Exit${NC}"
    echo "---------------------------------------"
    echo -ne "${CYAN}Choose: ${NC}"
    read -r m < /dev/tty

    case $m in
        1) install_rdp_full ;;
        2) browsers_menu ;;
        3) apt update -y && curl -fsSL https://tailscale.com/install.sh | sh && tailscale up; success_msg "Tailscale" ;;
        4) apt update -y && apt upgrade -y && apt autoremove -y; success_msg "System Clean" ;;
        5) check_status ;;
        6) social_menu ;;
        0) exit 0 ;;
        *) main_menu ;;
    esac
    main_menu
}

# --- START ---
detect_debian
main_menu
