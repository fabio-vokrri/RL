# Progetto di Reti Logiche

Progetto del corso di Reti Logiche (a.a. 2023-2024), svolto in collaborazione con il collega Francesco Simone.

Il progetto consiste nell’implementazione di un componente hardware, interfacciato ad una memoria di tipo *Single-Port Block RAM Write-First Mode*, che svolga le seguenti funzioni:

- leggere dalla memoria una sequenza di `K` parole `W`, il cui valore è compreso tra 0 e 255.
- il valore 0 all’interno della sequenza deve essere interpretato come "valore non specificato".
- la sequenza di `K` parole da elaborare è presente in memoria a partire dall’indirizzo `i_add` specificato, ogni 2 byte (e.g. `ADD`, `ADD+2`, `ADD+4`, ...).
- completare la sequenza, sostituendo gli zero, laddove presenti, con l’ultimo valore valido letto. N
- nel byte mancante (e.g. `ADD+1`, `ADD+3`, `ADD+5`, ...), dovrà essere inserito il valore di credibilità, il quale sarà pari a 31  ogni qualvolta il valore della sequenza sia diverso da zero e, in caso contrario, verrà decrementato fino ad un minimo di zero

(per maggiori dettagli riguardati i requisiti del progetto consultare il file di [specifica](specification.pdf)).

Il componente è stato implementato utilizzando un automa a stati finiti realizzata su _una macchina di Mealy_ composta da 5 stati:
1. Stato `INIT`, di inizializzazione.
2. Stato `BUF`, di attesa della stabilizzazione dei segnali.
3. Stato `READ`, di lettura della memoria RAM a cui il componente è interfacciato.
4. Stato `WRITE_VAL`, di scrittura del valore in memoria.
5. Stato `WRITE_CRED`, di scrittura della credibilità in memoria.

I cui funzionamenti sono meglio descritti nel file di [documentazione](documentation.pdf).

Il componente hardware è stato poi sintetizzato, utilizzando i tools offerti dal software VIVADO :TM: Xilinx, per poter eseguire test funzionali e di timing, in maniera da garantire il corretto funzionamento entro i limiti di tempo imposti dalla specifica del progetto.
