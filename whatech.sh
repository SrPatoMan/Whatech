#!/bin/bash

## COLOURS ##
NEGRO='\033[0;30m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'


RESET_COLOR='\033[0m'

## FUNCTIONS ##
banner () {

echo -e "$GREEN"
echo -e "

 #     #               #######                      
 #  #  # #    #   ##      #    ######  ####  #    # 
 #  #  # #    #  #  #     #    #      #    # #    # 
 #  #  # ###### #    #    #    #####  #      ###### 
 #  #  # #    # ######    #    #      #      #    # 
 #  #  # #    # #    #    #    #      #    # #    # 
  ## ##  #    # #    #    #    ######  ####  #    #
"
echo -e "$RESET_COLOR"
echo -e "$BLUE"
echo -e "----------------- BY SRPATOMAN ----------------------------"
echo -e "$RESET_COLOR"
}

usage () {
echo -e "
${BLUE}[+] This tool needs whatweb to work, if you don't have whatweb, you can install it with:

sudo apt install whatweb (Ubuntu, Kali, Parrot, etc...)
sudo pacman -S whatweb (Arch linux)
${RESET_COLOR}
${GREEN}
############################################

Use: ./whatech <subdomain wordlist>

Ex: ./whatech subdomains.txt
${RESET_COLOR}
"
}


## START ##

banner

if [ $# != 1 ];then
    echo -e "${RED}[+] ERROR: YOU MUST PROVIDE ONE ARGUMENT${RESET_COLOR}\n\n"
    usage
    exit
fi

whatweb_install=$(which whatweb)

if [ $? == 1 ];then
    echo -e "${RED}[+] ERROR: YOU DON'T HAVE INSTALL WHATWEB${RESET_COLOR}\n\n"
    usage
    exit
fi

echo -e "${BLUE}[+] ESCANEANDO SUBDOMINIOS...\n\n\n${RESET_COLOR}"
subdomain_list=$1

while IFS=' ' read -r subdomain;do
    whatweb https://$subdomain/ | tee -a .whatech_subdomains.txt
    echo -e "\n\n"
    echo -e "*" | tee -a ".whatech_subdomains.txt"
done < $subdomain_list

## output ##
mkdir -p whatech
mkdir -p whatech/server
mkdir -p whatech/cms