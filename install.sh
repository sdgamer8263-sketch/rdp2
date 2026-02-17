#!/usr/bin/env bash

# =======================================
#   AUTHOR    : SDGAMER
#   TOOL      : DEBIAN 11/12/13 RDP INSTALLER (SILENT FIX)
# =======================================

# ---------- COLORS ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# ---------- OS DETECTION ----------
detect_debian() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$ID" != "debian" ]; then
            echo -e "${RED}Error: Your OS is $ID. This script is ONLY for Debian 11, 12, or 13!${NC}"
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
    echo -e "${YELLOW}Press Enter to return...${NC}"
    read -r < /dev/tty
}

# ---------- FULL RDP SETUP (SILENT KEYBOARD FIX) ----------
install_rdp_full() {
    banner
    echo -e "${YELLOW}Starting Debian Full RDP Setup (XRDP + XFCE)...${NC}"
    
    # 1. Password Setup (Type and press Enter)
    echo -e "${CYAN}Set a password for 'root' user (RDP Login Password):${NC}"
    passwd root

    # 2. THE KEYBOARD FIX (Pre-selecting English US)
    echo -e "${YELLOW}Setting Default Keyboard to English (US)...${NC}"
    export DEBIAN_FRONTEND=noninteractive
    
    # Ye commands blue screen ko bypass kar dengi
    apt-get update -y
    apt-get install -y debconf-utils
    echo "keyboard-configuration keyboard-configuration/layout select English (US)" | debconf-set-selections
    echo "keyboard-configuration keyboard-configuration/layoutcode string us" | debconf-set-selections

    # 3. Installing Desktop and RDP silently
    echo -e "${YELLOW}Installing Desktop Environment (Please wait)...${NC}"
    apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" xfce4 xfce4-goodies xrdp

    # 4. XRDP Config
    sudo systemctl enable xrdp --now
    echo "xfce4-session" > ~/.xsession
    sudo adduser xrdp ssl-cert
    
    # Permit Root login
    sudo sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config
    
    sudo systemctl restart xrdp
    
    unset DEBIAN_FRONTEND
    
    echo -e "\n${GREEN}✔ DONE! Use Username 'root' and your password to login.${NC}"
    success_msg "Debian RDP Setup"
}

# ---------- BROWSERS MENU ----------
browsers_menu() {
    banner
    echo -e "${CYAN}--- [2] WEB BROWSERS ---${NC}"
    echo -e "${YELLOW}1.${NC} Google Chrome"
    echo -e "${YELLOW}2.${NC} Firefox ESR"
    echo -e "${YELLOW}3.${NC} Brave Browser"
    echo -e "${YELLOW}0.${NC} Back"
    echo -ne "${CYAN}Select: ${NC}"
    read -r b < /dev/tty
    case $b in
        1) 
           apt update -y && apt install -y wget
           wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
           apt install -y ./google-chrome*.deb
           rm -f google-chrome*.deb; success_msg "Chrome" ;;
        2) 
           apt update -y && apt install -y firefox-esr; success_msg "Firefox ESR" ;;
        3) 
           apt update -y && apt install -y curl gpg
           curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
           echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list
           apt update -y && apt install -y brave-browser; success_msg "Brave" ;;
        0) main_menu ;;
        *) browsers_menu ;;
    esac
    browsers_menu
}

# ---------- MAIN MENU ----------
main_menu() {
    banner
    echo -e "${YELLOW}OS:${NC} Debian $VERSION_ID | ${YELLOW}Verified:${NC} Yes"
    echo "---------------------------------------"
    echo -e "${CYAN}1.${NC} INSTALL FULL RDP SETUP (XRDP + XFCE)"
    echo -e "${CYAN}2.${NC} Web Browsers"
    echo -e "${CYAN}3.${NC} Install Tailscale"
    echo -e "${CYAN}4.${NC} System Clean & Update"
    echo -e "${RED}0. Exit${NC}"
    echo "---------------------------------------"
    echo -ne "${CYAN}Choose: ${NC}"
    read -r m < /dev/tty

    case $m in
        1) install_rdp_full ;;
        2) browsers_menu ;;
        3) apt update -y && curl -fsSL https://tailscale.com/install.sh | sh && tailscale up; success_msg "Tailscale" ;;
        4) apt update -y && apt upgrade -y && apt autoremove -y; success_msg "System Clean" ;;
        0) exit 0 ;;
        *) main_menu ;;
    esac
    main_menu
}

# --- START ---
detect_debian
main_menu
