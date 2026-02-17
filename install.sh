#!/usr/bin/env bash

# Sabhi interactive prompts aur purple chart ko bypass karne ke liye
export DEBIAN_FRONTEND=noninteractive

# ---------- COLORS ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

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
echo -e "${GREEN}         DEBIAN 11/12/13 RDP INSTALLER (FINAL FIX)${NC}"
echo "======================================================="
}

# ---------- HELPERS ----------
success_msg() {
    echo -e "\n${GREEN}✔ $1 Process Completed!${NC}"
    echo -e "${YELLOW}Press Enter to return to Menu...${NC}"
    read -r
}

# ---------- OPTION 1: RDP SETUP (FIXED) ----------
install_rdp_full() {
    echo -e "${YELLOW}Starting Debian Full RDP Setup (XRDP + XFCE)...${NC}"
    apt-get update -y
    apt-get install -y sudo
    # 'force-confdef' aur 'force-confold' us purple screen ko skip karte hain
    apt-get install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -yq xfce4 xfce4-goodies xrdp
    echo "xfce4-session" > ~/.xsession
    systemctl enable xrdp --now
    if getent group ssl-cert; then adduser xrdp ssl-cert; fi
    systemctl restart xrdp
    success_msg "RDP Setup"
}

# ---------- OPTION 2: BROWSERS ----------
browsers_menu() {
    banner
    echo -e "${CYAN}--- WEB BROWSERS ---${NC}"
    echo -e "1. Google Chrome"
    echo -e "2. Firefox ESR"
    echo -e "3. Brave Browser"
    echo -e "0. Back"
    echo -ne "${CYAN}Select: ${NC}"
    read -r b
    case $b in
        1) apt-get install -y wget && wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && apt-get install -y ./google-chrome*.deb && rm -f google-chrome*.deb; success_msg "Chrome" ;;
        2) apt-get install -y firefox-esr; success_msg "Firefox ESR" ;;
        3) apt-get install -y curl gpg && curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg && echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list && apt-get update -y && apt-get install -y brave-browser; success_msg "Brave" ;;
        0) return ;;
    esac
}

# ---------- MAIN MENU ----------
while true; do
    banner
    echo -e "${YELLOW}1.${NC} INSTALL FULL RDP SETUP (XRDP + XFCE)"
    echo -e "${YELLOW}2.${NC} Web Browsers"
    echo -e "${YELLOW}3.${NC} Install Tailscale"
    echo -e "${YELLOW}4.${NC} System Clean & Update"
    echo -e "${RED}0. Exit${NC}"
    echo "-------------------------------------------------------"
    echo -ne "${CYAN}Choose Option: ${NC}"
    read -r m

    case $m in
        1) install_rdp_full ;;
        2) browsers_menu ;;
        3) echo -e "${YELLOW}Installing Tailscale...${NC}" && curl -fsSL https://tailscale.com/install.sh | sh && success_msg "Tailscale" ;;
        4) echo -e "${YELLOW}Cleaning System...${NC}" && apt-get update -y && apt-get upgrade -yq && apt-get autoremove -y; success_msg "System Clean" ;;
        0) exit 0 ;;
        *) echo -e "${RED}Invalid Option!${NC}"; sleep 1 ;;
    esac
done
