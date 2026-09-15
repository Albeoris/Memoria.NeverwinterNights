void main()
{
    int nKey = StringToInt(GetScriptParam("MEMORIA_CONFIG_TEXT_KEY"));
    string sText = nKey == 1 ? "Configuración de Memoria" : nKey == 2 ? "Abre el administrador de configuración de Memoria. Selecciona un objeto para ejecutar los diagnósticos disponibles." : nKey == 3 ? "Configuración de Memoria" : nKey == 4 ? "No hay mods de Memoria registrados." : nKey == 5 ? "Guardar" : nKey == 6 ? "Cerrar" : nKey == 7 ? "debe estar entre" : "";
    SetLocalString(OBJECT_SELF, "MEMORIA_CONFIG_TEXT_RESULT", sText);
}
