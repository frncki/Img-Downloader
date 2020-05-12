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

        curl "$urlbase$img" -o ./$filename -s
        echo "$urlbase$img"

    fi
done

rm .site