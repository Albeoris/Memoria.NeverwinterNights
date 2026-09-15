void main()
{
    int i = StringToInt(GetScriptParam("M_TACT_TEXT_KEY"));
    if (i == 27) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Parametri del fuoco amico"); return; }
    if (i == 64) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Difficolta nemico almeno"); return; }
    if (i == 65) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Difficolta nemico al massimo"); return; }
    if (i == 66) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "PRIORITA BERSAGLIO"); return; }
    if (i == 67) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Aggiungi priorita"); return; }
    if (i == 68) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Editor priorita"); return; }
    if (i == 69) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Incantatori nemici"); return; }
    if (i == 70) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Nemici con difficolta piu alta"); return; }
    if (i == 71) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Nemici con difficolta piu bassa"); return; }
    if (i == 72) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Nemici con salute minima"); return; }
    if (i == 73) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Nemici con salute massima"); return; }
    if (i == 74) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Poi: tutti gli altri nemici"); return; }
    if (i == 75) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Criterio"); return; }
    if (i == 76) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "REGOLE"); return; }
    if (i == 77) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Debug delle decisioni"); return; }
    if (i == 78) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Esamina il bersaglio"); return; }
    if (i == 79) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "[M_TACT] Seleziona una creatura per la diagnostica."); return; }
    if (i == 80) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "[M_TACT] Selezione diagnostica annullata."); return; }
    if (i == 81) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "L'area e determinata automaticamente dall'incantesimo"); return; }
    if (i == 82) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Senza restrizioni"); return; }
    if (i == 83) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Controlla prima del lancio"); return; }
    if (i == 84) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Controlla durante il lancio"); return; }
    if (i == 85) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Solo con alleati fermi"); return; }
    if (i == 86) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "AZIONI"); return; }
    if (i == 88) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Priorita globali"); return; }
    if (i == 89) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Priorita della regola"); return; }
    if (i == 90) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Editor azione"); return; }
    if (i == 91) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Aggiungi azione"); return; }
    if (i == 92) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Grado del nemico"); return; }
    if (i == 93) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Confronto"); return; }
    if (i == 94) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Almeno"); return; }
    if (i == 95) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Al massimo"); return; }
    if (i == 96) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Salute inferiore"); return; }
    if (i == 97) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Soggetto"); return; }
    if (i == 98) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Questo personaggio"); return; }
    if (i == 99) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Un alleato"); return; }
    if (i == 100) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Si applicano solo azioni ostili ad area; il gruppo migliore viene scelto automaticamente."); return; }
    if (i == 101) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Secondo le priorita dei bersagli"); return; }
    if (i == 102) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Nessuna azione"); return; }
    if (i == 103) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Priorita dell'azione"); return; }
    if (i == 104) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Poi: globali, quindi altri nemici"); return; }
    if (i == 105) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Poi: regola, globali, altri nemici"); return; }
    if (i == 106) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Gli alleati vengono ignorati e possono essere colpiti."); return; }
    if (i == 107) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "L'area viene controllata prima.\nIl lancio non viene annullato dopo."); return; }
    if (i == 108) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "La sicurezza viene ricontrollata.\nUn nuovo pericolo annulla il lancio."); return; }
    if (i == 109) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Il lancio attende che gli alleati si fermino.\nPoi controlla l'area."); return; }
    if (i == 110) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Equipaggia oggetto"); return; }
    if (i == 111) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Oggetti equipaggiabili"); return; }
    string s = i == 1 ? "Architetto tattico" : i == 2 ? "Apre l'editor visuale delle tattiche. Configura azioni e condizioni prioritarie per l'eroe, un compagno specifico o un tipo di creatura." : i == 3 ? "Architetto tattico installato, versione" : i == 4 ? "Architetto tattico" : i == 5 ? "Personaggio" : i == 6 ? "Ambito del profilo" : i == 7 ? "Questo personaggio" : i == 8 ? "Questo tipo di creatura" : i == 9 ? "Tattica attuale" : i == 10 ? "Nuova" : i == 11 ? "Elimina" : i == 12 ? "Attiva" : i == 13 ? "Nome della tattica" : i == 14 ? "Rinomina" : i == 15 ? "AZIONE" : i == 16 ? "QUANDO" : i == 17 ? "Su" : i == 18 ? "Giu" : i == 19 ? "Modifica" : i == 20 ? "Aggiungi regola" : i == 21 ? "Chiudi" : i == 22 ? "Modifica regola" : i == 23 ? "Scegli azione" : i == 24 ? "Scegli condizione" : i == 25 ? "Avanzate" : i == 26 ? "Puo muoversi a portata" : i == 27 ? "Consenti fuoco amico" : i == 28 ? "Fonte" : i == 29 ? "Qualsiasi fonte disponibile" : i == 30 ? "Slot del libro degli incantesimi" : i == 31 ? "Tipo di oggetto selezionato" : i == 32 ? "Bersaglio" : i == 33 ? "Automatico" : i == 34 ? "Se stesso" : i == 35 ? "Nemico adatto piu vicino" : i == 36 ? "Alleato con meno salute" : i == 37 ? "Miglior gruppo di nemici" : i == 38 ? "Sempre" : i == 39 ? "Nemici vicini" : i == 40 ? "Nemici raggruppati" : i == 41 ? "Salute personale sotto" : i == 42 ? "Salute alleato sotto" : i == 43 ? "Nessuna creatura evocata" : i == 44 ? "Nessun famiglio evocato" : i == 45 ? "Soglia" : i == 46 ? "Raggio (metri)" : i == 47 ? "Salva" : i == 48 ? "Annulla" : i == 49 ? "Scegli un incantesimo o oggetto" : i == 50 ? "Cerca" : i == 51 ? "Precedente" : i == 52 ? "Successivo" : i == 53 ? "Scegli" : i == 54 ? "Evoca famiglio" : i == 55 ? "Attacca il nemico piu vicino" : i == 56 ? "Incantesimo o oggetto utilizzabile..." : i == 57 ? "Non configurato" : i == 58 ? "Predefinita" : i == 59 ? "Nessuna regola. Aggiungi la prima priorita." : i == 60 ? "Eroe principale" : i == 61 ? "Valore non valido." : i == 62 ? "Nemico con meno salute" : i == 63 ? "Nemico con piu salute" : "";
    SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", s);
}
