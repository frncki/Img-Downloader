## Jak uruchomić skrypt
1. Skrypt działa w bashowym terminalu
2. Należy upewnić się, że ma się zainstalowanego [`curla`](https://curl.haxx.se/download.html "Pobierz curl!")
3. W folderze, w którym znajduje się plik ze skryptem `downloadPicsFrom.sh` należy w terminalu wpisać komendę: `$ chmod 755 downloadPicsFrom.sh`, która nadaje odpowiednie uprawnienia do zapisu, odczytu i wykonania

```bash
#!/bin/bash
#Franciszek Mirecki

url=$1 #set first argument as our URL
curl $url -o ./.website -s  #download website source using curl
                            #-o flag denotes the filename (in this case temporary file named ".website") of the downloaded URL
                            #-s flag puts curl in silent mode
if [ $? -ne 0 ] #if curl's exit status does not equal to 0 (success)
	then
		echo "ERROR! Invalid argument."
		exit 1 # terminate the script
elif [[ -f "./.website" ]] #if file .website exists
then
    regexGetImg="img.+src=\"[^\"]+\.(png|jpg|gif)" #gets img src elements from website source
    regexRemoveAttrName="[^\"]+\.(png|jpg|gif)" #removes img src tags, and leaves clean file link
    regexGetFileName="[^\/]+\.(png|jpg|gif)$" #gets name of downloaded file
    regexGetURLBase="^https:\/\/[^\/]+" #gets base URL of provided website

    imgUrls=$(grep -oE $regexGetImg ./.website | grep -oE $regexRemoveAttrName) #uses regexGetImg and regexRemoveAttrName for extracting clean files links

    for img in $imgUrls #iterate through every link in imgUrls
    do
    fileName="`echo $img | grep -oE $regexGetFileName`" #uses regexGetFileName for getting name of file to download
    if [[ "$img" =~ ^\/\/.+ ]] #if file link is absolute but starts with only "//" without "https:"
    then
        curl "https:$img" -o ./$fileName -s #download file from given link with added "https:"
    elif [[ "$img" =~ ^https.+ ]] #else if file link is absolute and full
    then
        curl $img -o ./$fileName -s #download file
    elif [[ "$img" =~ ^\/[^\/].+ ]] #else if file link is relative
    then
        baseURL="`echo $url | grep -oE $regexGetURLBase`" #get website URL base
        curl "$baseURL$img" -o ./$fileName -s #download file by merging website URL base and relative file link, which makes file link absolute
    fi
    done

    rm ./.website #remove the temporary file
    exit 0 # exit with status 0 (success)
fi