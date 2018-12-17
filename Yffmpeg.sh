#!/bin/bash

# Modifica del titolo di un file avi
# modificate la directory sulla root dei vostri media
cd /media/root

# finestra principale
input=$(yad --title="Modifica titolo ad un AVI" --center --borders="20" --width="550" --separator=","  2> /dev/null \
        --form \
        --field="File da modificare":SFL "$avi1" \
        --field="Nome file di destinazione\n(<i>output</i>)":SFL "$avi1" \
        --field="Nuovo titolo\n(modifica il titolo nel file destinazione)" "$title" \
        --field="Elimina (alla fine) file da modificare?\n(Se vistato elimina il file).":CHK "$elim" \
        --button="gtk-cancel:1" \
        --button=" Procedi!iconok.png:2"  \
2>/dev/null
);return_code=$?

# split della stringa
avi1="$(cut -d',' -f1 <<<"$input")"
avi2="$(cut -d',' -f2 <<<"$input")"
title="$(cut -d',' -f3 <<<"$input")"
elim="$(cut -d',' -f4 <<<"$input")"

# alternative di split per più caratteri
# IFS=$'\n' read -rd '' -a stringa <<<"$input"
if [ "$elim" = "TRUE" ]; then
stringa="ATTENZIONE!! Prevista cancellazione dei file:
'$avi1'

"
fi

# cambia solo il titolo senza alterare il resto usa ffmpeg
stringa="$stringa ffmpeg -i '$avi1' -vcodec copy -acodec copy -map 0 -metadata title='$title' '$avi2'"

# finestra di controllo
[[ "$return_code" -eq "2" ]] && { printf "%s\n" "$stringa"| yad --text-info --width="550" --height="400" --wrap --title="Conferma dati" \
        --button="gtk-cancel:1" \
        --button=" Conferma!iconok.png:2" \
2>/dev/null
};return_code=$?

# Se si è cliccata la conferma dello ricerca
if [ "$return_code" -eq "2" ]; then


        if [ "x$avi1" = "x" ]; then

                echo "Manca il file AVI da modificare"

        fi
        if [ "x$avi2" = "x" ]; then

                echo "Manca il nome del nuovo file"

        fi
        if [ "x$title" = "x" ]; then

                echo "Manca il titolo"

        fi
        if [ "x$avi1" = "x" ] ||  [ "x$avi2" = "x" ] || [ "x$title" = "x" ]; then
            echo "Parametri incoerenti...esco."
            exit 1
        else        
                echo "Procedo con la modifica del titolo ($stringa)..."

                # riga modififcabile in funzione del coder utilizzato
                cmd="ffmpeg -i '$avi1' -vcodec copy -acodec copy -map 0 -metadata title='$title' '$avi2'"

                # elimina eventualmente i file di origine
                if [ "$elim" = "TRUE" ]; then
                    cmd="$cmd && rm -i '$avi1'"
                fi
#               avvio degli script per la modifica del file avi
                echo $cmd # controllo
                # inizio per il tempo impiegato                
                START=$(date +%s)                
                eval exec $cmd
                END=$(date +%s)
                DIFF=$(( $END - $START ))
				echo "Tempo impiegato $DIFF secondi"
        fi
else
        echo "Modifica annullata."
fi