; BRDUtil.msg

;MESSAGE BOX TITLE
0000      Buffalo RAMDISK Utility

;FONT SIZE
0001      7

; DIALOG TITLE
2001      Buffalo RAMDISK Utility

; Label
2101      OK
2102      Annulla

2111      Stato : %s
2112      Lettera dell'unità:

2120      Modalità di backup
2121      Nessun backup
2122      Backup (spegnimento e sospensione)
2123      Ripristinare automaticamente i dati a ogni riavvio.
2124      Backup (per Expert)
2125      Backup quando inattivo.
2126      Backup durante la scrittura.
2127      Salvataggio residuo
2128      %lld MB
2129      Esegui backup adesso!
2130      Interrompi backup adesso!

2140      Varie
2141      Crea collegamenti nella cartella Documenti
2142      Utilizzare la cache per Internet Explorer.
2143      Utilizzare la cache per Firefox.

2160      Area RAMDISK 
2161      Utilizza oltre 4 GB e meno di 4 GB
2162      Capacità predisposta  RAMDISK 
2163      %d MB
2164      Max. %d MB
2165      Dimensioni disco
2166      Imposta dimensioni max.
2171      Oltre 4 GB
2181      Inferiore a 4 GB
2191      Nessuna

2200      * In alcuni computer, potrebbe non essere possibile utilizzare la gestione del sistema operativo esternamente.
2201      * Cache di TurboPC; il sistema operativo utilizza la gestione dello spazio esterno. Se il sistema operativo non ha spazio libero sufficiente oltre all'amministrazione, l'amministrazione del sistema operativo utilizza lo spazio interno.

; Restart
3011 Q Y2 Alcune impostazioni vengono modificate dopo il riavvio. \n\nRiavviare?
3012 I O  Alcune impostazioni vengono modificate dopo il riavvio.
3013 Q Y2 Riavvio del driver annullato. \nAlcune impostazioni vengono modificate dopo il riavvio. \n\nRiavviare?

; Memory area configuration
3021 Q C2 Modifica delle impostazione dell'area di memoria.\n\n[Attenzione] I dati archiviati in RAMDISK corrente non vengono salvati. Viene anche avviata l'inizializzazione del RAMDISK corrente. \n\nContinuare?

; Driver status
3101      Impostazioni predefinite.
3102      Interrotto.
3103      In esecuzione.
3105      Sospeso.
3181      Interrotto per un errore di sistema.
3182      Interrotto per un errore di autenticazione.
3183      Interrotto per un errore del bus di indirizzo.
3184      Interrotto per un errore di accesso alla memoria superiore a 4 GB.
3185      Interrotto per un conflitto tra configurazione e memoria effettiva.
3186      Interrotto per via di un'area di memoria non specificata.
3187      RAMDISK richiede almeno 1 GB.

; Driver status　（Error message）
3381 E O  Interrotto per un errore di sistema.
3382 W O  Nessuna memoria Buffalo trovata.\n\nPer utilizzare l'utilità è necessaria almeno una memoria a marchio Buffalo.
3383 W O  Interrotto per un errore del bus di indirizzo.\n\nReimpostazione.
3384 W O  Interrotto per impossibilità ad accedere oltre 4 GB.\n\nReimpostazione.
3385 W O  Capacità di memoria diminuita.\n\nRAMDISK non è disponibile.\n\nReimpostazione.
3387 E O  RAMDISK richiede almeno 1 GB.

; Driver status　（Memory capacity）
3401 Q Y  Capacità di memoria aumentata.\n\nReimpostare?
3402 Q Y  Capacità di memoria diminuita.\n\nReimpostare?
3403 Q Y  Capacità di memoria aumentata.\n\nReimpostare?
3404 Q Y  Capacità di memoria diminuita.\n\nReimpostare?
3411      Sì
3412      No（mantenere l'impostazione）
3413      Non viene visualizzato.

; Boot error
3501 E O  È richiesta un'autorizzazione di amministratore.
3502 E O  RAMDISK  non è attivato.
3503 E O  ERROR. QUERY_PARAMETERS
3510 E O  Disinstallare per via dei problemi incorsi.

; Configuration error
3600 E O  Impossibile configurare.
3601 W O  Impossibile impostare la lettera dell'unità.
3602 W O  Impossibile impostare la modalità di backup.
3603 W O  Impossibile impostare l'area di memoria.
3611 W O  Impossibile eseguire il backup immediato.
3612 W O  Impossibile annullare il backup.

3621 W O  Area di memoria non selezionata.
3622 W O  Capacità del disco non valida specificata nell'area gestita dal sistema operativo.
3623 W O  Capacità del disco non valida specificata nell'area di memoria totale.

3701 W O  Impossibile impostare la cache di Internet Explorer.
3702 W O  Impossibile impostare la cache di Firefox.
3703 E O  Impossibile impostare perché è in esecuzione FireFox.
3704 W O  Impossibile impostare ReadyBoost.

3711 W O  Errore di montaggio di My RAMDISK 
3712 W O  Errore di smontaggio di My RAMDISK 

3721 W O  Impossibile aggiungere  MAXMEM  all'opzione di avvio.
3722 W O  Impossibile eliminare  MAXMEM  dall'opzione di avvio.

; ReadyBoost
4101      Proprietà di  (%c:)
4102    Non utilizzare questo dispositivo.(&D)
4103     Utilizzare questo dispositivo.(&U)

; My RAMDISK
4201      My RAMDISK

; Wizard
5001      Configurazione di RAMDISK Utility
5002      Configurazione facile
5003      Configurazione avanzata
5004      Configurazione automatica adeguata all'ambiente.
5005      Selezionare questa opzione per eseguire una configurazione personalizzata.
5006      Stato : %s
5010 Q Y  Crea  %ldMB RAMDISK.\nContinuare?
5011 I O  La configurazione facile è stata eseguita.

; BRDUtilTray.exe
6001      Utilità delle attività Buffalo RAMDISK
6101      Configurazione
6102      Esci 
6501 E O  Impossibile verificare la CPU inattiva.
6502 Q Y  Imposta attivazione del monitoraggio delle prestazioni della CPU.\nFare clic su OK per attivare il monitoraggio delle prestazioni della CPU.
6503 E O  Impossibile verificare la CPU inattiva.\nConfigurare le impostazioni della memoria virtuale.
6504 E O  Impossibile eseguire "Buffalo RAMDISK Utility".

; BRDStartup.exe
7801 E O  Errore di autenticazione.



