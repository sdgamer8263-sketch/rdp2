#!/usr/bin/env bash

# Purple chart aur interactive prompts ko bypass karne ke liye
export DEBIAN_FRONTEND=noninteractive

# ---------- COLORS ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# ---------- BANNER (NO CLEAR COMMAND TO PREVENT GLITCH) ----------
echo -e "${CYAN}"
cat <<'EOF'
 ██████╗██████╗  ██████╗  █████╗ ███╗   ███╗███████╗██████╗ 
██╔════╝██╔══██╗██╔════╝ ██╔══██╗████╗ ████║██╔════╝██╔══██╗
╚█████╗ ██║  ██║██║  ███╗███████║██╔████╔██║█████╗  ██████╔╝
 ╚════██║██║  ██║██║   ██║██╔══██║██║╚██╔╝██║██╔══╝  ██╔══██╗
██████╔╝██████╔╝╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗██║  ██║
╚═════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝
EOF
echo -e "${GREEN}         DEBIAN 11/12/13 RDP INSTALLER (INPUT FIX)${NC}"
echo "======================================================="

# ---------- MENU ----------
echo -e "${YELLOW}CHOOSE WHAT TO INSTALL:${NC}"
echo -e "${CYAN}1.${NC} INSTALL FULL RDP SETUP (XRDP + XFCE)"
echo -e "${CYAN}2.${NC} Web Browsers (Chrome + Firefox)"
echo -e "${CYAN}3.${NC} Install Tailscale"
echo -e "${CYAN}4.${NC} System Clean & Update"
echo -e "${RED}0.${NC} Exit"
echo "-------------------------------------------------------"

# Glitch Fix: Simple input reading
echo -n "Type number (1, 2, 3, or 4) and press Enter: "
read -r m

case "$m" in
    1)
        echo -e "${YELLOW}Installing RDP... Please wait (2-3 mins).${NC}"
        apt-get update -y
        # Force non-interactive for the purple keyboard chart
        apt-get install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -yq xfce4 xfce4-goodies xrdp
        echo "xfce4-session" > ~/.xsession
        systemctl enable xrdp --now
        if getent group ssl-cert; then adduser xrdp ssl-cert; fi
        systemctl restart xrdp
        echo -e "${GREEN}RDP Setup Complete!${NC}"
        ;;
    2)
        echo -e "${YELLOW}Installing Browsers...${NC}"
        apt-get update -y
        apt-get install -y firefox-esr wget
        wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        apt-get install -y ./google-chrome*.deb
        rm -f google-chrome*.deb
        echo -e "${GREEN}Browsers Installed!${NC}"
        ;;
    3)
        echo -e "${YELLOW}Installing Tailscale...${NC}"
        curl -fsSL https://tailscale.com/install.sh | sh
        echo -e "${GREEN}Tailscale Installed! Run 'tailscale up' to connect.${NC}"
        ;;
    4)
        echo -e "${YELLOW}Cleaning System...${NC}"
        apt-get update && apt-get upgrade -yq && apt-get autoremove -y
        echo -e "${GREEN}System Cleaned!${NC}"
        ;;
    0)
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid Selection '$m'. Run again and type a number.${NC}"
        ;;
esac
