# Progetto di Reti Logiche

Progetto del corso di Reti Logiche (a.a. 2023-2024), svolto in collaborazione con il collega Francesco Simone.

Il progetto consiste nell’implementazione di un componente hardware, interfacciato ad una memoria di tipo *Single-Port Block RAM Write-First Mode*, che svolga le seguenti funzioni:

- leggere dalla memoria una sequenza di `K` parole `W`, il cui valore è compreso tra 0 e 255.
- il valore 0 all’interno della sequenza deve essere interpretato come "valore non specificato".
- la sequenza di `K` parole da elaborare è presente in memoria a partire dall’indirizzo `i_add` specificato, ogni 2 byte (e.g. `ADD`, `ADD+2`, `ADD+4`, ...).
- completare la sequenza, sostituendo gli zero, laddove presenti, con l’ultimo valore valido letto. N
- nel byte mancante (e.g. `ADD+1`, `ADD+3`, `ADD+5`, ...), dovrà essere inserito il valore di credibilità, il quale sarà pari a 31  ogni qualvolta il valore della sequenza sia diverso da zero e, in caso contrario, verrà decrementato fino ad un minimo di zero

Per maggiori dettagli sull'implementazione consultare la [documentazione](documentation.pdf).
