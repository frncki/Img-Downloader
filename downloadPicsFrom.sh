#!/bin/bash
# Franciszek Mirecki
#chmod 755 downloadPicsFrom.sh
#https://pl.wikipedia.org/wiki/Bizon
url=$1
curl $url -o .site -s

regexGetImg="img.+src=\"[^\"]+\.(png|jpg|gif)"
regexRemoveAttrName="[^\"]+\.(png|jpg|gif)"

imgUrls=$(grep -oE $regexGetImg ./.site | grep -oE $regexRemoveAttrName)

printf "${imgUrls[@]}\n" > ./.urls

red=`tput setaf 1`
green=`tput setaf 2`
blue=`tput setaf 4`

resetColor=`tput sgr0`

for img in $imgUrls
do
    filename="`echo $img | grep -oE "[^\/]+\.(png|jpg|gif)$"`"
    if [[ "$img" =~ ^\/\/.+ ]]
    then
        curl "https:$img" -o ./$filename -s
    elif [[ "$img" =~ ^https.+ ]]
    then
        curl $img -o ./$filename -s
    elif [[ "$img" =~ ^\/[^\/].+ ]]
    then
        urlbase="`echo $url | grep -oE "^https:\/\/[^\/]+"`"
        echo "${blue}Downloading…${resetColor}"
        curl "$urlbase$img" -o ./$filename -s
        echo "${green}SUCCESS!${resetColor} Downloaded file: $filename"
    fi
done

rm .site