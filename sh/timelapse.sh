#!/bin/bash
# creiamo un video time lapse da una sequenza di fotografie
# requisiti: bash, imagemagick, ffmpeg
# uso: timelapse.sh nomedir

# prende il nome della dir che contiene le immagini dalla riga di comando
DATI=$1

# facciamo pulizie e prepariamoci a lavorare...
rm -rf ./elabora/*.jpg
mkdir elabora

# copia le immagini dalla cartella che contiene le foto a quella di lavoro (elabora)
# rinominandole in modo che piacciano a ffmpeg (00001.jpg, 00002.jpg, 00003.jpg...)
# nl restituisce una coppia numero progressivo + nome file
ls $DATI/*.JPG | nl -nrz -w5 | while read newname oldname
do
		cp -v "$oldname" elabora/$newname.jpg
done

# ci spostiamo nella dir di lavoro
cd elabora

# ATTENZIONE! ffmpeg non è in grado di lavorare con immagini più grandi di 
# 5120x5120! Vanno rimpicciolite prima di continuare!
# vediamo la dimensione della prima immagine: prima prendiamone il nome...
FIRST=`ls *.jpg | head -n 1 `
# e poi chiediamo a identify (da imagemagick) di descrivercela...
DESCR=`identify $FIRST`
# spezziamo la descrizione dove ci sono gli spazi, sostituendoli con degli a capo
# e la memorizziamo nella variabile $SPLITDESCR come un array
SPLITDESCR=(`echo $DESCR | tr " " "\n"`)
# la terza "parola" (indice 2) contiene le dimensioni dell'immagine. E' ok, ma 
# dobbiamo scartare anche l'altezza dell'immagine (tanto riprendiamo sempre in 
# orizzontale). Per far questo filtriamo il testo usando sed (scartiamo i numeri
# che ci sono da x in poi (1234x1234 diventa solo 1234)
SIZE=`echo ${SPLITDESCR[2]} | sed -e 's/x[0-9]*//'`

# ora controlliamo se la larghezza è maggiore del limite di ffmpeg: se sì, 
# dobbiamo ridimensionare le immagini. Altrimenti non facciamo nulla
if [ $SIZE -gt 5120 ]
then
		echo "immagini troppo grandi, devo ridimensionarle..."
		for img in `ls *.jpg`
		do
				echo ridimensiono $i ...
				# mogrify è come convert, solo modifica le immagini su cui lavora
				mogrify -resize 5120x5120 $img
		done
fi

#echo `pwd`
# # # # # # # # # # # # # # # # # # # # # # # # # 
# qui creiamo il time lapse vero e proprio: giocando con il primo parametro -r
# si può regolare la velocità del video finale. Valori troppo bassi rendono
# il video "a scatti". ffmpeg farà del suo meglio per interpolare i fotogrammi
# e darci un video fluido.
# se non va bene, non c'è bisogno di rieseguire tutto lo script: copia questo
# ultimo comando in un terminale e cambia "-r 15" in un valore diverso (consiglio
# un valore tra 10 e 30)
ffmpeg -r 15 -i '%05d.jpg' -r 25 -s hd720 -vcodec mpeg4 -qscale 1 \
                                         -y ../video-timelapse.mp4
		
# abbiamo finito, ciao ciao
exit

