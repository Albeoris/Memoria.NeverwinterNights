void main()
{
    object oPlayer = OBJECT_SELF;
    int bRussian = GetStringByStrRef(3) == "Барды";
    int nLanguage = GetPlayerLanguage(oPlayer);
    string sResult = "en";
    if (bRussian)
        sResult = "ru";
    else if (nLanguage == PLAYER_LANGUAGE_FRENCH)
        sResult = "fr";
    else if (nLanguage == PLAYER_LANGUAGE_GERMAN)
        sResult = "de";
    else if (nLanguage == PLAYER_LANGUAGE_ITALIAN)
        sResult = "it";
    else if (nLanguage == PLAYER_LANGUAGE_SPANISH)
        sResult = "es";
    SetLocalInt(oPlayer, "MEMORIA_LANGUAGE_IS_RUSSIAN", bRussian);
    SetLocalString(oPlayer, "MEMORIA_LANGUAGE", sResult);
}
