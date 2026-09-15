// Shared text normalization helpers for Memoria mods.

/// @brief Validates a decimal string and normalizes its first comma or period separator to a period.
/// @param sValue Candidate decimal text containing digits and at most one separator.
/// @return Normalized decimal text, or an empty string when an invalid character or second separator is encountered.
string MEMORIA_NormalizeDecimal(string sValue)
{
    string sResult = "";
    int bSeparator = FALSE;
    int iIndex;
    for (iIndex = 0; iIndex < GetStringLength(sValue); iIndex++)
    {
        string sCharacter = GetSubString(sValue, iIndex, 1);
        if (FindSubString("0123456789", sCharacter) >= 0)
            sResult += sCharacter;
        else if ((sCharacter == "." || sCharacter == ",") && !bSeparator)
        {
            sResult += ".";
            bSeparator = TRUE;
        }
        else
            return "";
    }
    return sResult;
}

/// @brief Converts searchable JSON text to lowercase, including escaped uppercase Cyrillic letters.
/// @param sValue JSON-derived text to normalize for case-insensitive searching.
/// @return Lowercase search text with escaped Cyrillic capitals replaced by their lowercase forms.
string MEMORIA_FoldJsonSearchText(string sValue)
{
    sValue = GetStringLowerCase(sValue);
    sValue = RegExpReplace("\\\\u0410", sValue, "\\u0430");
    sValue = RegExpReplace("\\\\u0411", sValue, "\\u0431");
    sValue = RegExpReplace("\\\\u0412", sValue, "\\u0432");
    sValue = RegExpReplace("\\\\u0413", sValue, "\\u0433");
    sValue = RegExpReplace("\\\\u0414", sValue, "\\u0434");
    sValue = RegExpReplace("\\\\u0415", sValue, "\\u0435");
    sValue = RegExpReplace("\\\\u0401", sValue, "\\u0451");
    sValue = RegExpReplace("\\\\u0416", sValue, "\\u0436");
    sValue = RegExpReplace("\\\\u0417", sValue, "\\u0437");
    sValue = RegExpReplace("\\\\u0418", sValue, "\\u0438");
    sValue = RegExpReplace("\\\\u0419", sValue, "\\u0439");
    sValue = RegExpReplace("\\\\u041a", sValue, "\\u043a");
    sValue = RegExpReplace("\\\\u041b", sValue, "\\u043b");
    sValue = RegExpReplace("\\\\u041c", sValue, "\\u043c");
    sValue = RegExpReplace("\\\\u041d", sValue, "\\u043d");
    sValue = RegExpReplace("\\\\u041e", sValue, "\\u043e");
    sValue = RegExpReplace("\\\\u041f", sValue, "\\u043f");
    sValue = RegExpReplace("\\\\u0420", sValue, "\\u0440");
    sValue = RegExpReplace("\\\\u0421", sValue, "\\u0441");
    sValue = RegExpReplace("\\\\u0422", sValue, "\\u0442");
    sValue = RegExpReplace("\\\\u0423", sValue, "\\u0443");
    sValue = RegExpReplace("\\\\u0424", sValue, "\\u0444");
    sValue = RegExpReplace("\\\\u0425", sValue, "\\u0445");
    sValue = RegExpReplace("\\\\u0426", sValue, "\\u0446");
    sValue = RegExpReplace("\\\\u0427", sValue, "\\u0447");
    sValue = RegExpReplace("\\\\u0428", sValue, "\\u0448");
    sValue = RegExpReplace("\\\\u0429", sValue, "\\u0449");
    sValue = RegExpReplace("\\\\u042a", sValue, "\\u044a");
    sValue = RegExpReplace("\\\\u042b", sValue, "\\u044b");
    sValue = RegExpReplace("\\\\u042c", sValue, "\\u044c");
    sValue = RegExpReplace("\\\\u042d", sValue, "\\u044d");
    sValue = RegExpReplace("\\\\u042e", sValue, "\\u044e");
    sValue = RegExpReplace("\\\\u042f", sValue, "\\u044f");
    return sValue;
}

/// @brief Serializes a JSON string value and normalizes its contents for case-insensitive searching.
/// @param jValue JSON string value to serialize and normalize.
/// @return Normalized serialized contents without the surrounding JSON quotes, or an empty string for output shorter than two characters.
string MEMORIA_GetJsonSearchText(json jValue)
{
    string sValue = MEMORIA_FoldJsonSearchText(JsonDump(jValue));
    int iLength = GetStringLength(sValue);
    return iLength >= 2 ? GetSubString(sValue, 1, iLength - 2) : "";
}
