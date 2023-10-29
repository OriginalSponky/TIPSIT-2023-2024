# campo_minato

Caratteristiche
Interfaccia utente intuitiva per giocare a Campo Minato.
Possibilità di scavalcare le caselle vuote.

Struttura del progetto

Librerie usate:

flutter/material: Contiene il codice sorgente principale dell'app.
dart:math: Contiene un sistema di progettazione open source creato e supportato da designer e sviluppatori di Google.

## Come giocare a Campo Minato

Il Campo Minato è un gioco di logica in cui l'obiettivo principale è scoprire tutte le caselle sicure sul campo senza fare esplodere le mine. Ecco come giocare:


1. **Scopri le caselle**: Clicca su una casella sul campo per rivelarla. Se la casella contiene una mina, perderai immediatamente. Se la casella è vuota, verrà rivelato un numero che indica quante mine ci sono nelle caselle adiacenti.

2. **Scopri tutte le caselle sicure**: Continua a rivelare le caselle una alla volta. L'obiettivo è scoprire tutte le caselle che non contengono mine. Puoi usarne la logica per determinare dove sono posizionate le mine in base alle informazioni rivelate.

3. **Completa il gioco**: Il gioco è completato con successo quando hai rivelato tutte le caselle sicure senza fare esplodere le mine. In tal caso, verrà visualizzato un messaggio di vittoria e il tempo impiegato per completare il gioco verrà registrato.

4. **Scavalcamento delle caselle vuote**: Se una casella è vuota e non contiene mine né numeri, rivelerà tutte le caselle adiacenti, semplificando il gioco.

5. **Continua a giocare**: Puoi giocare a Campo Minato quante volte vuoi, cercando di migliorare i tuoi punteggi e raggiungere il tempo più basso possibile.

Contatti
Se hai domande o suggerimenti, sentiti libero di contattarmi:

Nome del creatore: Andrea Sponchiado
Email: andrea.sponchiado@itiszuccante.edu.it
Grazie per aver scelto il nostro Campo Minato in Dart! Divertiti a giocare e a esplorare il codice sorgente.