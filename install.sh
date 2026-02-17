#!/usr/bin/env bash

# Purple chart ko background mein handle karne ke liye
export DEBIAN_FRONTEND=noninteractive

# ---------- COLORS ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# ---------- BANNER ----------
banner() {
echo -e "${CYAN}"
cat <<'EOF'
 ██████╗██████╗  ██████╗  █████╗ ███╗   ███╗███████╗██████╗ 
██╔════╝██╔══██╗██╔════╝ ██╔══██╗████╗ ████║██╔════╝██╔══██╗
╚█████╗ ██║  ██║██║  ███╗███████║██╔████╔██║█████╗  ██████╔╝
 ╚════██║██║  ██║██║   ██║██╔══██║██║╚██╔╝██║██╔══╝  ██╔══██╗
██████╔╝██████╔╝╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗██║  ██║
╚═════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝
EOF
echo -e "${GREEN}         DEBIAN 11/12/13 RDP INSTALLER (MANUAL)${NC}"
echo "======================================================="
}

# ---------- FUNCTIONS ----------
install_rdp() {
    echo -e "${YELLOW}Installing RDP Setup...${NC}"
    apt-get update -y
    apt-get install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -yq xfce4 xfce4-goodies xrdp
    echo "xfce4-session" > ~/.xsession
    systemctl enable xrdp --now
    systemctl restart xrdp
    echo -e "${GREEN}RDP Installation Finished!${NC}"
}

install_tailscale() {
    echo -e "${YELLOW}Installing Tailscale...${NC}"
    curl -fsSL https://tailscale.com/install.sh | sh
    echo -e "${GREEN}Tailscale Installed!${NC}"
}

install_browsers() {
    echo -e "${YELLOW}Installing Browsers...${NC}"
    apt-get install -y firefox-esr wget
    wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    apt-get install -y ./google-chrome*.deb
    rm -f google-chrome*.deb
    echo -e "${GREEN}Browsers Installed!${NC}"
}

# ---------- MENU (NO GLITCH) ----------
banner
echo -e "${YELLOW}CHOOSE WHAT TO INSTALL:${NC}"
echo -e "${CYAN}1.${NC} RDP Setup (XRDP + XFCE)"
echo -e "${CYAN}2.${NC} Web Browsers (Chrome + Firefox)"
echo -e "${CYAN}3.${NC} Tailscale"
echo -e "${CYAN}4.${NC} System Clean & Update"
echo -e "${RED}0.${NC} Exit"
echo "-------------------------------------------------------"

# Glitch fix: read command without any special redirects
read -p "Enter your choice: " m

case $m in
    1) install_rdp ;;
    2) install_browsers ;;
    3) install_tailscale ;;
    4) apt-get update && apt-get upgrade -y ;;
    0) exit 0 ;;
    *) echo "Invalid choice" ;;
esac
