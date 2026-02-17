#!/usr/bin/env bash

# =======================================
#   AUTHOR    : SDGAMER
#   TOOL      : DEBIAN 11/12/13 RDP INSTALLER (FIXED)
# =======================================

# Force non-interactive mode to skip keyboard/tzdata prompts
export DEBIAN_FRONTEND=noninteractive

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
            echo -e "${RED}Error: Your OS is $ID. This is ONLY for Debian!${NC}"
            exit 1
        fi
        VERSION_ID_CLEAN=$(echo $VERSION_ID | cut -d. -f1)
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
echo -e "${GREEN}         DEBIAN 11/12/13 RDP INSTALLER (COLAB FIX)${NC}"
echo "======================================="
echo
}

# ---------- HELPERS ----------
success_msg() {
    echo -e "\n${GREEN}✔ $1 Process Completed Successfully!${NC}"
    echo -e "${YELLOW}Press Enter to return...${NC}"
    read -r 
}

# ---------- FULL RDP SETUP (FIXED) ----------
install_rdp_full() {
    echo -e "${YELLOW}Starting Debian Full RDP Setup (XRDP + XFCE)...${NC}"
    echo -e "${CYAN}Note: Purple screen prompts will be skipped automatically.${NC}"
    
    # Update and set frontend to noninteractive
    apt-get update -y
    apt-get install -y sudo
    
    # Installing desktop environment and RDP server
    # -yq and DEBIAN_FRONTEND ensure it doesn't get stuck on keyboard layout chart
    apt-get install -yq xfce4 xfce4-goodies xrdp

    # Debian Specific XRDP Configuration
    systemctl enable xrdp --now
    
    # Session fix to avoid login loops (Very important for XFCE)
    echo "xfce4-session" > ~/.xsession
    
    # Fix permissions for the RDP user
    if getent group ssl-cert; then
        adduser xrdp ssl-cert
    fi
    
    systemctl restart xrdp
    
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
    read -r b
    case $b in
        1) 
           apt-get update -y
           apt-get install -y wget
           wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
           apt-get install -y ./google-chrome*.deb
           rm -f google-chrome*.deb; success_msg "Chrome" ;;
        2) 
           apt-get update -y
           apt-get install -y firefox-esr; success_msg "Firefox ESR" ;;
        3) 
           apt-get update -y
           apt-get install -y curl gpg
           curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
           echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list
           apt-get update -y
           apt-get install -y brave-browser; success_msg "Brave" ;;
        0) main_menu ;;
        *) browsers_menu ;;
    esac
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
    read -r m

    case $m in
        1) install_rdp_full ;;
        2) browsers_menu ;;
        3) apt-get update -y && curl -fsSL https://tailscale.com/install.sh | sh && tailscale up; success_msg "Tailscale" ;;
        4) apt-get update -y && apt-get upgrade -yq && apt-get autoremove -y; success_msg "System Clean" ;;
        0) exit 0 ;;
        *) main_menu ;;
    esac
    main_menu
}

# --- START ---
detect_debian
main_menu
