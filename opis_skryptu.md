## Jak uruchomić skrypt
1. Skrypt działa w bashowym terminalu
2. Należy upewnić się, że ma się zainstalowanego [`curla`](https://curl.haxx.se/download.html "Pobierz curl!")
3. W folderze, w którym znajduje się plik ze skryptem `downloadPicsFrom.sh` należy w terminalu wpisać komendę: `$ chmod 755 downloadPicsFrom.sh`, która nadaje odpowiednie uprawnienia do zapisu, odczytu i wykonania
4. Skrypt pobiera obrazy do podfolderu o nazwie images-\[aktualna data\]

```bash
#!/bin/bash
#Franciszek Mirecki

url=$1 #ustawia pierwszy parametr jako URL
curl $url -o ./.website -s  #pobiera źródło strony przy pomocy curl'a
                            #flaga -o sprawia ze plik pobierany jest do wyjsciowego pliku tymczasowego o podanej nazwie (.website)
                            #flaga -s ustawia curl'a w trybie cichym (nie zwraca logów)
if [ $? -ne 0 ] #jeśli exit status ostatniej komendy nie równa się 0 (czyli sukces)
	then
		echo "ERROR! Invalid argument."
		exit 1 # to zakoncz wykonywanie skrypu
elif [[ -f "./.website" ]] #w innym przypadku, jesli zostal utworzony plik o nazwie .website
then
    #wyrazenia regularne
    regexGetImg="img.+src=\"[^\"]+\.(png|jpg|gif)" #znajduje elementy img src w źródle strony
    regexRemoveAttrName="[^\"]+\.(png|jpg|gif)" #usuwa tagi img src itd. zostawiajac czyste linki do obrazkow
    regexGetFileName="[^\/]+\.(png|jpg|gif)$" #pozyskuje nazwe pliku do pobrania
    regexGetURLBase="^https:\/\/[^\/]+" #pozyskuje bazowe URL podanego URL

    imgUrls=$(grep -oE $regexGetImg ./.website | grep -oE $regexRemoveAttrName) #uzywa wyrazen regularnych: regexGetImg i regexRemoveAttrName aby pozyskac czyste linki do obrazkow

    dirName="images-$(date "+%Y-%m-%d@%H-%M-%S")" #ustawia nazwe folderu jako images-[aktualna data] (w formacie YYYY-MM-DD@HH-mm-ss)

    mkdir $dirName #tworzy folder na obrazki z daną nazwą

    for img in $imgUrls #iteruje po kazdym linku z imgUrls
    do
        fileName="`echo $img | grep -oE $regexGetFileName`" #uzywa wyrazenia regularnego regexGetFileName aby ustawic nazwe pobieranego obrazka
        if [[ "$img" =~ ^\/\/.+ ]] #jeśli link jest bezwgledny ale zaczyna sie od "//" bez "https:"
        then
            echo "Downloading..."
            curl "https:$img" -o ./$dirName/$fileName -s #pobiera plik z danego linku z dodanym "https:"
            echo "SUCCESS! Downloaded file: $fileName" #informuje o pobraniu pliku
        elif [[ "$img" =~ ^https.+ ]] #w innym przypadku, jesli link jest bezwzgledny i ma "https://"
        then
            echo "Downloading..."
            curl $img -o ./$dirName/$fileName -s #pobiera plik z danego linku
            echo "SUCCESS! Downloaded file: $fileName" 
        elif [[ "$img" =~ ^\/[^\/].+ ]] #w innym przypadku, jesli plik jest wzgledny
        then
            baseURL="`echo $url | grep -oE $regexGetURLBase`" #pozyskuje bazowe URL strony
            echo "Downloading..."
            curl "$baseURL$img" -o ./$dirName/$fileName -s #pobiera plik z linku po połączeniu bazowego URL strony i względnego linku, sprawiając ze link staje się bezwzgledny
            echo "SUCCESS! Downloaded file: $fileName"
        fi
    done

    rm ./.website #usuwa plik tymczasowy
        exit 0 #konczy dzialanie programu
fi