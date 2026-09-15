void main()
{
    int nKey = StringToInt(GetScriptParam("MEMORIA_CONFIG_TEXT_KEY"));
    string sText = nKey == 1 ? "Configuration de Memoria" : nKey == 2 ? "Ouvre le gestionnaire de configuration de Memoria. Ciblez un objet pour lancer les diagnostics disponibles." : nKey == 3 ? "Configuration de Memoria" : nKey == 4 ? "Aucun mod Memoria enregistré." : nKey == 5 ? "Enregistrer" : nKey == 6 ? "Fermer" : nKey == 7 ? "doit être compris entre" : "";
    SetLocalString(OBJECT_SELF, "MEMORIA_CONFIG_TEXT_RESULT", sText);
}
