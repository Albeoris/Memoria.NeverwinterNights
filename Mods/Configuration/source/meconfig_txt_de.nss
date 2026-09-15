void main()
{
    int nKey = StringToInt(GetScriptParam("MEMORIA_CONFIG_TEXT_KEY"));
    string sText = nKey == 1 ? "Memoria-Konfiguration" : nKey == 2 ? "Öffnet die Memoria-Konfiguration. Wähle ein Objekt als Ziel, um registrierte Diagnosen auszuführen." : nKey == 3 ? "Memoria-Konfiguration" : nKey == 4 ? "Keine registrierten Memoria-Mods." : nKey == 5 ? "Speichern" : nKey == 6 ? "Schließen" : nKey == 7 ? "muss im Bereich liegen" : "";
    SetLocalString(OBJECT_SELF, "MEMORIA_CONFIG_TEXT_RESULT", sText);
}
