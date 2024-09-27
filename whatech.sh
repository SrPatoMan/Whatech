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

echo -e "${BLUE}[+] SCANNING SUBDOMAINS...\n\n\n${RESET_COLOR}"
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

## Clean invisible characters ##
cat .whatech_subdomains.txt | sed 's/\x1b\[[0-9;]*m//g' >> .whatech_subdomains_cleaned.txt
rm .whatech_subdomains.txt

## DETECT TECHNOLOGIES FUNCTIONS ##
tech_detect() {

    tech_detected=$1
    export_file=$2
    file_path=$3


    grep "HTTPServer.*$tech_detected" .whatech_subdomains_cleaned.txt | grep "^https://" | cut -d ' ' -f1 | tr -d '/' | cut -d ':' -f2 >> $export_file 
    mv $export_file $file_path

}


## Classification of results ##
server_path=whatech/server
cms_path=whatech/cms

## Servers ##
tech_detect "nginx" "nginx_subdomains.txt" "$server_path"
tech_detect "Apache" "apache_subdomains.txt" "$server_path"
tech_detect "CloudFront" "cloudfront_subdomains.txt" "$server_path"
tech_detect "cloudflare" "cloudflare_subdomains.txt" "$server_path"
tech_detect "Akamai" "akamai_subdomains.txt" "$server_path"

## CMS ##
tech_detect "WordPress" "wordpress_subdomains.txt" "$cms_path"
tech_detect "Moodle" "moodle_subdomains.txt" "$cms_path"
tech_detect "Drupal" "drupal_subdomains.txt" "$cms_path"
