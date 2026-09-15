// Original work Copyright (c) 2020 Mischa Dutzik (Ravick).
// Relicensed under the MIT License by Albeoris. See THIRD_PARTY_NOTICES.md.

#include "melse_sin_lib"

void main()
{
    int nStrRef = StringToInt(GetScriptParam(MELSE_SIN_PARAM_STRREF));
    
    string sString = nStrRef == 1   ? "Dovrei tenere d'occhio i tesori in questa zona." 
                   : nStrRef == 2   ? "Questa zona sembra priva di tesori." 
                   : nStrRef == 5   ? "ha lasciato cadere un oggetto missione!"
                   : nStrRef == 7   ? "ha lasciato cadere un oggetto equipaggiato!" 
                   : nStrRef == 8   ? "Acquisito l'ultima volta da " 
                   : nStrRef == 9   ? "nell'area " 
                   : nStrRef == 10  ? "Oggetto (non identificato)"
                   : nStrRef == 11  ? "viene ignorato."

                   : nStrRef == 99   ? "Looting System Enhanced"
                   : nStrRef == 100  ? "Indietro..."
                   : nStrRef == 101  ? "Rilevamento tesori"
                   : nStrRef == 102  ? "Tracciamento tesori"
                   : nStrRef == 103  ? "Saccheggio automatico dei tesori"
                   : nStrRef == 104  ? "Cadaveri saccheggiabili"
                   : nStrRef == 105  ? "I cadaveri saccheggiabili scompaiono dopo il saccheggio"
                   : nStrRef == 106  ? "I cadaveri saccheggiabili scompaiono col tempo"
                   : nStrRef == 107  ? "I cadaveri saccheggiabili possono essere resuscitati"
                   : nStrRef == 108  ? "Saccheggio automatico dei cadaveri dopo l'esame"
                   : nStrRef == 109  ? "Saccheggio automatico dei cadaveri dopo l'uccisione"
                   : nStrRef == 110  ? "Saccheggio automatico dei cadaveri uccisi da un compagno"
                   : nStrRef == 111  ? "La descrizione dell'oggetto mostra chi lo ha acquisito l'ultima volta"
                   : nStrRef == 112  ? "La descrizione dell'oggetto mostra il prezzo base"

                   : nStrRef == 120  ? "Indietro..."
                   : nStrRef == 121  ? "Tempo di decomposizione dei cadaveri saccheggiabili in secondi"
                   : nStrRef == 122  ? "Prezzo base minimo per il saccheggio automatico"
                   : nStrRef == 123  ? "Peso base massimo per il saccheggio automatico"

                   : nStrRef == 900  ? "Chiudi."
                   : nStrRef == 901  ? "Caratteristiche..."
                   : nStrRef == 902  ? "Parametri..."
                   : nStrRef == 911  ? "+ 1"
                   : nStrRef == 912  ? "+ 10"
                   : nStrRef == 913  ? "+ 100"
                   : nStrRef == 914  ? "- 1"
                   : nStrRef == 915  ? "- 10"
                   : nStrRef == 916  ? "- 100"

                   : nStrRef == 951  ? "Distruggi il cadavere selezionato!"
                   : nStrRef == 952  ? "Distruggi tutti i cadaveri nell'area corrente!"
                   : nStrRef == 953  ? "Distruggi tutti i cadaveri nel modulo corrente!"

                   : nStrRef == 501  ? "Ravick's Looting System Enhanced: versione installata"
                   : nStrRef == 502  ? "Ravick's Looting System Enhanced: aggiornato alla versione"

                   : nStrRef == 601  ? "Spiegami come usare MELSE!"
                   : nStrRef == 602  ? "Tutte le funzionalità di MELSE sono state installate automaticamente. Non è necessaria alcuna ulteriore azione, a meno che tu non voglia attivare o personalizzare alcune funzionalità, cosa che viene spiegata in questo tutorial."
                   : nStrRef == 603  ? "Per interagire con MELSE, trova e usa lo \"Strumento Giocatore 9\" sotto \"Abilità speciali\" nel menu del tasto destro. Dovrai quindi scegliere un bersaglio, che determina il tipo di interazione. Non selezionare nulla ora, altrimenti il tutorial si chiuderà!"
                   : nStrRef == 604  ? "Cosa succede se seleziono il mio personaggio?"
                   : nStrRef == 605  ? "Cosa succede se seleziono un cadavere?"
                   : nStrRef == 606  ? "Ora so come usare MELSE. Chiudi il tutorial."
                   : nStrRef == 607  ? "Selezionando il tuo personaggio si aprirà il pannello di configurazione. Qui potrai attivare singole funzionalità o modificare parametri specifici."
                   : nStrRef == 608  ? "Selezionando il cadavere di un nemico si aprirà il pannello degli strumenti. Attualmente le opzioni disponibili sono limitate alla risoluzione dei problemi, come la distruzione dei cadaveri rimanenti per correggere possibili bug di alcuni script del modulo che dipendono dall'esistenza di creature (vive o morte)."

                   :                STRING_EMPTY;

    SetLocalString(OBJECT_SELF, "MELSE_CONFIG_TEXT_RESULT", sString);
    MELSE_SIN_SetBufferedString(nStrRef, sString);
}
