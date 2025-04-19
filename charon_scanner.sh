#!/bin/bash
# ================================
# Website Scanner by Charon
# Telegram: @aa0aaa
# Use for educational and legal purposes only.
# ================================

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ASCII Banner
echo -e "${BLUE}"
echo "   ____ _                     "
echo "  / ___| |__   __ _ _ __  _   _ "
echo " | |   | '_ \ / _\` | '_ \| | | |"
echo " | |___| | | | (_| | | | | |_| |"
echo "  \____|_| |_|\__,_|_| |_|\__,_|"
echo ""
echo "     No System is Safe - Charon"
echo -e "${NC}"

# Check for root
if [ "$EUID" -ne 0 ]; then 
  echo -e "${RED}[!] Please run as root${NC}"
  exit
fi

# Check argument
if [ -z "$1" ]; then
  echo -e "${RED}[!] Usage: $0 <target-domain>${NC}"
  exit 1
fi

TARGET=$1

# Update and install tools
echo -e "${GREEN}[*] Installing required tools (first time only)...${NC}"
apt update -y && apt install -y nmap whatweb subfinder httpx nikto dirsearch git curl wafw00f ffuf nuclei dnsenum waybackurls

# Create workspace
mkdir -p scan_results/$TARGET
cd scan_results/$TARGET || exit

# Functions
function whois_scan {
  echo -e "${GREEN}[*] Running Whois Lookup...${NC}"
  whois $TARGET > whois.txt
}

function dnsenum_scan {
  echo -e "${GREEN}[*] Running DNS Enumeration...${NC}"
  dnsenum $TARGET > dnsenum.txt
}

function subfinder_scan {
  echo -e "${GREEN}[*] Running Subfinder...${NC}"
  subfinder -d $TARGET -silent > subdomains.txt
}

function httpx_scan {
  echo -e "${GREEN}[*] Probing live subdomains...${NC}"
  httpx -l subdomains.txt -silent > live_subdomains.txt
}

function wafw00f_scan {
  echo -e "${GREEN}[*] Checking for WAF...${NC}"
  wafw00f $TARGET > waf.txt
}

function whatweb_scan {
  echo -e "${GREEN}[*] Running WhatWeb...${NC}"
  whatweb $TARGET > whatweb.txt
}

function nmap_scan {
  echo -e "${GREEN}[*] Running Nmap aggressive scan...${NC}"
  nmap -A -Pn -T4 -oN nmap.txt $TARGET
}

function nikto_scan {
  echo -e "${GREEN}[*] Running Nikto scan...${NC}"
  nikto -h $TARGET > nikto.txt
}

function dirsearch_scan {
  echo -e "${GREEN}[*] Running Dirsearch...${NC}"
  dirsearch -u http://$TARGET -e php,html,js -x 403,404 -o dirsearch.txt
}

function nuclei_scan {
  echo -e "${GREEN}[*] Running Nuclei scan...${NC}"
  nuclei -u $TARGET -t ~/nuclei-templates/ -o nuclei.txt
}

function ffuf_scan {
  echo -e "${GREEN}[*] Running Fuzzing with FFUF...${NC}"
  ffuf -w /usr/share/wordlists/dirb/common.txt -u http://$TARGET/FUZZ -o ffuf.txt
}

function waybackurls_scan {
  echo -e "${GREEN}[*] Finding past URLs...${NC}"
  waybackurls $TARGET > waybackurls.txt
}

function full_scan {
  whois_scan
  dnsenum_scan
  subfinder_scan
  httpx_scan
  wafw00f_scan
  whatweb_scan
  nmap_scan
  nikto_scan
  dirsearch_scan
  nuclei_scan
  ffuf_scan
  waybackurls_scan
}

# Menu
while true; do
  echo -e "${BLUE}\n[*] Choose scan option:${NC}"
  echo "1) Full Scan (Recommended)"
  echo "2) Whois Lookup"
  echo "3) DNS Enumeration"
  echo "4) Subdomain Discovery"
  echo "5) Live Subdomain Probing"
  echo "6) WAF Detection"
  echo "7) Technology Detection (WhatWeb)"
  echo "8) Nmap Scan"
  echo "9) Nikto Scan"
  echo "10) Dirsearch Bruteforce"
  echo "11) Nuclei Vulnerabilities"
  echo "12) FFUF Fuzzing"
  echo "13) Waybackurls Past URLs"
  echo "14) Exit"
  
  read -p "Select option: " choice

  case $choice in
    1) full_scan ;;
    2) whois_scan ;;
    3) dnsenum_scan ;;
    4) subfinder_scan ;;
    5) httpx_scan ;;
    6) wafw00f_scan ;;
    7) whatweb_scan ;;
    8) nmap_scan ;;
    9) nikto_scan ;;
    10) dirsearch_scan ;;
    11) nuclei_scan ;;
    12) ffuf_scan ;;
    13) waybackurls_scan ;;
    14) echo -e "${GREEN}[*] Exiting...${NC}"; break ;;
    *) echo -e "${RED}[!] Invalid choice. Try again.${NC}" ;;
  esac
done

# Add signature at the end of every file
for file in *.txt; do
  echo -e "\n# Scanned by Charon - Telegram: @aa0aaa" >> "$file"
done

# Final message
echo -e "${GREEN}\n[*] All results are saved in scan_results/$TARGET${NC}"
echo -e "${GREEN}[*] Thank you for using Charon Scanner!${NC}"

