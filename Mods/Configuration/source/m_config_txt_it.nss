void main()
{
    int nKey = StringToInt(GetScriptParam("MEMORIA_CONFIG_TEXT_KEY"));
    string sText = nKey == 1 ? "Configurazione Memoria" : nKey == 2 ? "Apre il gestore di configurazione di Memoria. Seleziona un oggetto per eseguire la diagnostica disponibile." : nKey == 3 ? "Configurazione Memoria" : nKey == 4 ? "Nessun mod Memoria registrato." : nKey == 5 ? "Salva" : nKey == 6 ? "Chiudi" : nKey == 7 ? "deve essere compreso tra" : "";
    SetLocalString(OBJECT_SELF, "MEMORIA_CONFIG_TEXT_RESULT", sText);
}
