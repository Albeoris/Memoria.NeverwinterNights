void main()
{
    int nKey = StringToInt(GetScriptParam("MEMORIA_CONFIG_TEXT_KEY"));
    string sText = nKey == 1 ? "Memoria Configuration" : nKey == 2 ? "Open the Memoria Configuration Manager. Target an object to run registered diagnostics." : nKey == 3 ? "Memoria Configuration" : nKey == 4 ? "No registered Memoria mods." : nKey == 5 ? "Save" : nKey == 6 ? "Close" : nKey == 7 ? "must be between" : "";
    SetLocalString(OBJECT_SELF, "MEMORIA_CONFIG_TEXT_RESULT", sText);
}
