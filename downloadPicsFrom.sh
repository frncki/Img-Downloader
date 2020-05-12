#!/bin/bash
# Franciszek Mirecki
#chmod 755 downloadPicsFrom.sh
#https://pl.wikipedia.org/wiki/Bizon
url=$1
curl $url -o .site -s

regexGetImg="img.+src=\"[^\"]+\.(png|jpg|gif)"
regexRemoveAttrName="[^\"]+\.(png|jpg|gif)"

imgUrls=$(grep -o -E $regexGetImg ./.site | grep -o -E $regexRemoveAttrName)

# echo ${imgUrls[@]}


