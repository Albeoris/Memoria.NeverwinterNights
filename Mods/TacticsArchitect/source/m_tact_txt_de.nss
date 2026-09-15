void main()
{
    int i = StringToInt(GetScriptParam("M_TACT_TEXT_KEY"));
    if (i == 27) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Parameter fur Verbundetenschaden"); return; }
    if (i == 64) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Gegnerwertung mindestens"); return; }
    if (i == 65) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Gegnerwertung hochstens"); return; }
    if (i == 66) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "ZIELPRIORITATEN"); return; }
    if (i == 67) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Prioritat hinzufugen"); return; }
    if (i == 68) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Prioritatseditor"); return; }
    if (i == 69) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Feindliche Zauberwirker"); return; }
    if (i == 70) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Gegner mit hochster Wertung"); return; }
    if (i == 71) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Gegner mit niedrigster Wertung"); return; }
    if (i == 72) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Gegner mit wenigster Gesundheit"); return; }
    if (i == 73) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Gegner mit meiste Gesundheit"); return; }
    if (i == 74) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Danach: alle anderen Gegner"); return; }
    if (i == 75) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Kriterium"); return; }
    if (i == 76) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "REGELN"); return; }
    if (i == 77) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Entscheidungen debuggen"); return; }
    if (i == 78) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Gewaehltes Ziel pruefen"); return; }
    if (i == 79) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "[M_TACT] Waehle eine Kreatur fuer den Diagnosebericht."); return; }
    if (i == 80) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "[M_TACT] Diagnoseziel-Auswahl abgebrochen."); return; }
    if (i == 81) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Der Bereich wird automatisch vom Zauber bestimmt"); return; }
    if (i == 82) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Ohne Einschrankungen"); return; }
    if (i == 83) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Vor dem Zaubern prufen"); return; }
    if (i == 84) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Beim Zaubern prufen"); return; }
    if (i == 85) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Nur bei stillstehenden Verbundeten"); return; }
    if (i == 86) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "AKTIONEN"); return; }
    if (i == 88) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Globale Prioritaten"); return; }
    if (i == 89) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Regelprioritaten"); return; }
    if (i == 90) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Aktionseditor"); return; }
    if (i == 91) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Aktion hinzufugen"); return; }
    if (i == 92) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Gegnerbewertung"); return; }
    if (i == 93) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Vergleich"); return; }
    if (i == 94) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Mindestens"); return; }
    if (i == 95) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Hochstens"); return; }
    if (i == 96) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Gesundheit unter"); return; }
    if (i == 97) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Zielperson"); return; }
    if (i == 98) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Dieser Charakter"); return; }
    if (i == 99) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Ein Verbundeter"); return; }
    if (i == 100) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Nur feindliche Flachenaktionen gelten; die beste Gruppe wird automatisch gewahlt."); return; }
    if (i == 101) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Nach Zielprioritaten"); return; }
    if (i == 102) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Keine Aktionen"); return; }
    if (i == 103) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Aktionsprioritaten"); return; }
    if (i == 104) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Danach: global, dann andere Gegner"); return; }
    if (i == 105) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Danach: Regel, global, andere Gegner"); return; }
    if (i == 106) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Verbundete werden ignoriert und konnen getroffen werden."); return; }
    if (i == 107) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Der Bereich wird vorher gepruft.\nDer Zauber wird danach nicht abgebrochen."); return; }
    if (i == 108) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Sicherheit wird beim Zaubern gepruft.\nNeue Gefahr bricht den Zauber ab."); return; }
    if (i == 109) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Der Zauber wartet auf stillstehende Verbundete.\nDann folgt eine Prufung."); return; }
    if (i == 110) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Gegenstand ausrusten"); return; }
    if (i == 111) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Ausrustbare Gegenstande"); return; }
    string s = i == 1 ? "Taktikarchitekt" : i == 2 ? "Offnet den visuellen Taktikeditor. Legt priorisierte Aktionen und Bedingungen fur den Helden, einen bestimmten Begleiter oder eine Kreaturenart fest." : i == 3 ? "Taktikarchitekt installiert, Version" : i == 4 ? "Taktikarchitekt" : i == 5 ? "Charakter" : i == 6 ? "Profilbereich" : i == 7 ? "Dieser Charakter" : i == 8 ? "Diese Kreaturenart" : i == 9 ? "Aktuelle Taktik" : i == 10 ? "Neu" : i == 11 ? "Loschen" : i == 12 ? "Aktiv" : i == 13 ? "Taktikname" : i == 14 ? "Umbenennen" : i == 15 ? "AKTION" : i == 16 ? "WENN" : i == 17 ? "Hoch" : i == 18 ? "Runter" : i == 19 ? "Bearbeiten" : i == 20 ? "Regel hinzufugen" : i == 21 ? "Schliessen" : i == 22 ? "Regel bearbeiten" : i == 23 ? "Aktion auswahlen" : i == 24 ? "Bedingung auswahlen" : i == 25 ? "Erweitert" : i == 26 ? "Darf sich in Reichweite bewegen" : i == 27 ? "Verbundenen Schaden erlauben" : i == 28 ? "Quelle" : i == 29 ? "Beliebige verfugbare Quelle" : i == 30 ? "Zauberbuchplatz" : i == 31 ? "Gewahlte Gegenstandsart" : i == 32 ? "Ziel" : i == 33 ? "Automatisch" : i == 34 ? "Selbst" : i == 35 ? "Nachster sinnvoller Gegner" : i == 36 ? "Verbunder mit wenigster Gesundheit" : i == 37 ? "Beste Gegnergruppe" : i == 38 ? "Immer" : i == 39 ? "Gegner in der Nahe" : i == 40 ? "Gegner gruppiert" : i == 41 ? "Eigene Gesundheit unter" : i == 42 ? "Gesundheit eines Verbundeten unter" : i == 43 ? "Keine beschworene Kreatur" : i == 44 ? "Kein Vertrauter beschworen" : i == 45 ? "Schwellenwert" : i == 46 ? "Radius (Meter)" : i == 47 ? "Speichern" : i == 48 ? "Abbrechen" : i == 49 ? "Zauber oder Gegenstand auswahlen" : i == 50 ? "Suchen" : i == 51 ? "Zuruck" : i == 52 ? "Weiter" : i == 53 ? "Auswahlen" : i == 54 ? "Vertrauten beschworen" : i == 55 ? "Nachsten Gegner angreifen" : i == 56 ? "Zauber oder nutzbarer Gegenstand..." : i == 57 ? "Nicht konfiguriert" : i == 58 ? "Standard" : i == 59 ? "Noch keine Regeln. Erste Prioritat hinzufugen." : i == 60 ? "Hauptcharakter" : i == 61 ? "Ungultiger Wert." : i == 62 ? "Gegner mit niedrigster Gesundheit" : i == 63 ? "Gegner mit hochster Gesundheit" : "";
    SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", s);
}
