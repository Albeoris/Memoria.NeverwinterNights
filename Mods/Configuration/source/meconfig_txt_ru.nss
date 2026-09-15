void main()
{
    int nKey = StringToInt(GetScriptParam("MEMORIA_CONFIG_TEXT_KEY"));
    string sText = nKey == 1 ? "Настройки Memoria" : nKey == 2 ? "Открывает менеджер настроек Memoria. Выберите объект целью, чтобы запустить доступную диагностику." : nKey == 3 ? "Настройки Memoria" : nKey == 4 ? "Зарегистрированные моды Memoria не найдены." : nKey == 5 ? "Сохранить" : nKey == 6 ? "Закрыть" : nKey == 7 ? "должно быть в диапазоне" : "";
    SetLocalString(OBJECT_SELF, "MEMORIA_CONFIG_TEXT_RESULT", sText);
}
