#!/bin/bash

## COLOURS ##
BLACK='\033[0;30m'
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
    whatweb http://$subdomain/ | tee -a .whatech_subdomains.txt
    echo -e "\n\n"
    echo -e "*" | tee -a ".whatech_subdomains.txt"
done < $subdomain_list

## output ##
mkdir -p whatech/server
mkdir -p whatech/cms
mkdir -p whatech/erp
mkdir -p whatech/os
mkdir -p whatech/other

## Clean invisible characters ##
cat .whatech_subdomains.txt | sed 's/\x1b\[[0-9;]*m//g' >> .whatech_subdomains_cleaned.txt
rm .whatech_subdomains.txt

## DETECT TECHNOLOGIES FUNCTIONS ##
tech_detect() {

    tech_detected=$1
    export_file=$2
    file_path=$3


    grep "HTTPServer.*$tech_detected" .whatech_subdomains_cleaned.txt | grep -E "^(https?://)" | cut -d ' ' -f1 | tr -d '/' | cut -d ':' -f2 | cut -d '?' -f1 | sort -u >> $export_file 
    mv $export_file $file_path

}
tech_detect2() {

    tech_detected=$1
    export_file=$2
    file_path=$3


    grep "$tech_detected" .whatech_subdomains_cleaned.txt | grep -E "^(https?://)" | cut -d ' ' -f1 | tr -d '/' | cut -d ':' -f2 | cut -d '?' -f1 | sort -u >> $export_file 
    mv $export_file $file_path

}

echo -e "${BLUE}\n\n\n[+] PROCESSING OUTPUT, WAIT A MOMENT PLEASE...\n\n${RESET_COLOR}"

## Classification of results ##
server_path=whatech/server
cms_path=whatech/cms
erp_path=whatech/erp
os_path=whatech/os
other_path=whatech/other

## Servers / Proxys / CDNs detection ##
tech_detect "nginx" "nginx_subdomains.txt" "$server_path"
tech_detect "Apache" "apache_subdomains.txt" "$server_path"
tech_detect "Microsoft-IIS" "iis_subdomains.txt" "$server_path"
tech_detect "CloudFront" "cloudfront_subdomains.txt" "$server_path"
tech_detect "cloudflare" "cloudflare_subdomains.txt" "$server_path"
tech_detect2 "AzureCloud" "azure_subdomains.txt" "$server_path"
tech_detect2 "Tomcat" "tomcat_subdomains.txt" "$server_path"
tech_detect "Imgix" "imgix_subdomains.txt" "$server_path"
tech_detect "Akamai" "akamai_subdomains.txt" "$server_path"
tech_detect "BigIP" "f5bigip_subdomains.txt" "$server_path"
tech_detect "IBM-WebSphere-DataPower" "ibmdatapower_subdomains.txt" "$server_path"
tech_detect "Varnish" "varnish_subdomains.txt" "$server_path"

## CMS detection ##
tech_detect2 "WordPress" "wordpress_subdomains.txt" "$cms_path"
tech_detect2 "Moodle" "moodle_subdomains.txt" "$cms_path"
tech_detect2 "Drupal" "drupal_subdomains.txt" "$cms_path"

## ERP detection ##
tech_detect2 "SAP" "sap_subdomains.txt" "$erp_path"
tech_detect2 "Odoo" "odoo_subdomains.txt" "$erp_path"


## OS detection ##
tech_detect2 "AlmaLinux" "almalinux_subdomains.txt" "$os_path"
tech_detect2 "CentOS" "centos_subdomains.txt" "$os_path"
tech_detect2 "Almazon Linux" "amazonlinux_subdomains.txt" "$os_path"

## Other detections ##
tech_detect2 "PHP" "php_subdomains.txt" "$other_path"
tech_detect2 "OpenResty" "openresty_subdomains.txt" "$other_path"
tech_detect2 "403 Forbidden" "forbidden_subdomains.txt" "$other_path"
tech_detect2 "401 Unauthorized" "forbidden2_subdomains.txt" "$other_path"
tech_detect2 "AmazonS3" "s3buckets_subdomains.txt" "$other_path"
tech_detect2 "Citrix-NetScaler" "citrix_subdomains.txt" "$other_path"
tech_detect2 "Inxmail Server" "inxmail_subdomains.txt" "$other_path"
tech_detect2 "WebTerm 7" "webterm7_subdomains.txt" "$other_path"
tech_detect2 "ASP_NET" "aspnet_subdomains.txt" "$other_path"

## Secrets ##
tech_detect2 "Vault" "hasicorpvault_subdomains.txt" "$other_path"

## Delete empty files ##
find whatech -type f -empty -exec rm {} \;

## Final result ##
rm .whatech_subdomains_cleaned.txt
echo -e "${GREEN}\n\n[+] DONE! RESULTS EXPORTED: \n\n${RESET_COLOR}"
echo -e "${GREEN}"
tree whatech
echo -e "\n\n${RESET_COLOR}"
