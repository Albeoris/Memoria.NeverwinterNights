// Shared manifest discovery and dependency compatibility for Memoria packages.

#include "nw_inc_nui"
#include "x3_inc_string"

const string MEMORIA_MANIFEST_SUFFIX = "_memoria";
const string MEMORIA_CACHE_OWNER_LOCAL = "MEMORIA_CACHE_OWNER";
const string MEMORIA_CACHE_WINDOW = "memoria_cache";
const string MEMORIA_ERRORS_LOCAL = "MEMORIA_ERRORS";
const string MEMORIA_ERRORS_REPORTED_LOCAL = "MEMORIA_ERRORS_REPORTED";
const int MEMORIA_MANIFEST_SCHEMA = 1;

int MEMORIA_IdEquals(string sLeft, string sRight)
{
    return GetStringLowerCase(sLeft) == GetStringLowerCase(sRight);
}

int MEMORIA_IsManifestResource(string sResource)
{
    int nSuffixLength = GetStringLength(MEMORIA_MANIFEST_SUFFIX);
    int nResourceLength = GetStringLength(sResource);
    return nResourceLength > nSuffixLength && GetSubString(sResource, nResourceLength - nSuffixLength, nSuffixLength) == MEMORIA_MANIFEST_SUFFIX;
}

void MEMORIA_ReportError(object oPlayer, string sResource, string sError)
{
    string sLocal = "MEMORIA_ERR_" + sResource;
    if (GetLocalString(oPlayer, sLocal) == sError) return;
    SetLocalString(oPlayer, sLocal, sError);
    SendMessageToPC(oPlayer, StringToRGBString("Memoria error: ", STRING_COLOR_RED) + StringToRGBString(sResource + ".txt: " + sError, "770"));
}

json MEMORIA_ParseVersion(string sVersion)
{
    json jMatch = RegExpMatch("^(0|[1-9][0-9]*)[.](0|[1-9][0-9]*)[.](0|[1-9][0-9]*)$", sVersion);
    if (JsonGetLength(jMatch) != 4) return JsonArray();
    json jVersion = JsonArray();
    jVersion = JsonArrayInsert(jVersion, JsonInt(StringToInt(JsonGetString(JsonArrayGet(jMatch, 1)))));
    jVersion = JsonArrayInsert(jVersion, JsonInt(StringToInt(JsonGetString(JsonArrayGet(jMatch, 2)))));
    jVersion = JsonArrayInsert(jVersion, JsonInt(StringToInt(JsonGetString(JsonArrayGet(jMatch, 3)))));
    return jVersion;
}

json MEMORIA_ParseRangeVersion(string sVersion)
{
    json jVersion = MEMORIA_ParseVersion(sVersion);
    if (JsonGetLength(jVersion) == 3) return jVersion;
    json jMatch = RegExpMatch("^(0|[1-9][0-9]*)(?:[.](0|[1-9][0-9]*))?$", sVersion);
    if (JsonGetLength(jMatch) < 2) return JsonArray();
    jVersion = JsonArray();
    jVersion = JsonArrayInsert(jVersion, JsonInt(StringToInt(JsonGetString(JsonArrayGet(jMatch, 1)))));
    jVersion = JsonArrayInsert(jVersion, JsonInt(JsonGetLength(jMatch) > 2 ? StringToInt(JsonGetString(JsonArrayGet(jMatch, 2))) : 0));
    jVersion = JsonArrayInsert(jVersion, JsonInt(0));
    return jVersion;
}

int MEMORIA_CompareVersions(json jLeft, json jRight)
{
    int nIndex;
    for (nIndex = 0; nIndex < 3; nIndex++)
    {
        int nLeft = JsonGetInt(JsonArrayGet(jLeft, nIndex));
        int nRight = JsonGetInt(JsonArrayGet(jRight, nIndex));
        if (nLeft > nRight) return 1;
        if (nLeft < nRight) return -1;
    }
    return 0;
}

int MEMORIA_IsCompatibleInterval(json jInstalled, string sInterval)
{
    int nLength = GetStringLength(sInterval);
    if (nLength < 3) return FALSE;
    string sOpen = GetSubString(sInterval, 0, 1);
    string sClose = GetSubString(sInterval, nLength - 1, 1);
    if ((sOpen != "[" && sOpen != "(") || (sClose != "]" && sClose != ")")) return FALSE;
    string sBody = GetSubString(sInterval, 1, nLength - 2);
    int nComma = FindSubString(sBody, ",");
    if (nComma < 0)
    {
        if (sOpen != "[" || sClose != "]") return FALSE;
        json jExact = MEMORIA_ParseRangeVersion(sBody);
        return JsonGetLength(jExact) == 3 && MEMORIA_CompareVersions(jInstalled, jExact) == 0;
    }
    if (FindSubString(sBody, ",", nComma + 1) >= 0) return FALSE;
    string sMinimum = GetStringLeft(sBody, nComma);
    string sMaximum = GetStringRight(sBody, GetStringLength(sBody) - nComma - 1);
    if ((sMinimum == "" && sOpen != "(") || (sMaximum == "" && sClose != ")")) return FALSE;
    if (sMinimum != "")
    {
        json jMinimum = MEMORIA_ParseRangeVersion(sMinimum);
        if (JsonGetLength(jMinimum) != 3) return FALSE;
        int nMinimumComparison = MEMORIA_CompareVersions(jInstalled, jMinimum);
        if (nMinimumComparison < 0 || (nMinimumComparison == 0 && sOpen == "(")) return FALSE;
    }
    if (sMaximum != "")
    {
        json jMaximum = MEMORIA_ParseRangeVersion(sMaximum);
        if (JsonGetLength(jMaximum) != 3) return FALSE;
        int nMaximumComparison = MEMORIA_CompareVersions(jInstalled, jMaximum);
        if (nMaximumComparison > 0 || (nMaximumComparison == 0 && sClose == ")")) return FALSE;
    }
    return TRUE;
}

int MEMORIA_IsCompatibleVersion(string sInstalled, string sVersions)
{
    json jInstalled = MEMORIA_ParseVersion(sInstalled);
    if (JsonGetLength(jInstalled) != 3 || sVersions == "") return FALSE;
    int nStart;
    while (nStart <= GetStringLength(sVersions))
    {
        int nSeparator = FindSubString(sVersions, ";", nStart);
        int nEnd = nSeparator < 0 ? GetStringLength(sVersions) : nSeparator;
        if (MEMORIA_IsCompatibleInterval(jInstalled, GetSubString(sVersions, nStart, nEnd - nStart))) return TRUE;
        if (nSeparator < 0) return FALSE;
        nStart = nSeparator + 1;
    }
    return FALSE;
}

int MEMORIA_IsValidVersions(string sVersions)
{
    if (sVersions == "") return FALSE;
    int nStart;
    while (nStart <= GetStringLength(sVersions))
    {
        int nSeparator = FindSubString(sVersions, ";", nStart);
        int nEnd = nSeparator < 0 ? GetStringLength(sVersions) : nSeparator;
        string sInterval = GetSubString(sVersions, nStart, nEnd - nStart);
        int nLength = GetStringLength(sInterval);
        if (nLength < 3) return FALSE;
        string sOpen = GetSubString(sInterval, 0, 1);
        string sClose = GetSubString(sInterval, nLength - 1, 1);
        string sBody = GetSubString(sInterval, 1, nLength - 2);
        int nComma = FindSubString(sBody, ",");
        if ((sOpen != "[" && sOpen != "(") || (sClose != "]" && sClose != ")")) return FALSE;
        if (nComma < 0)
        {
            if (sOpen != "[" || sClose != "]" || JsonGetLength(MEMORIA_ParseRangeVersion(sBody)) != 3) return FALSE;
        }
        else
        {
            if (FindSubString(sBody, ",", nComma + 1) >= 0) return FALSE;
            string sMinimum = GetStringLeft(sBody, nComma);
            string sMaximum = GetStringRight(sBody, GetStringLength(sBody) - nComma - 1);
            if ((sMinimum == "" && sOpen != "(") || (sMaximum == "" && sClose != ")") || (sMinimum != "" && JsonGetLength(MEMORIA_ParseRangeVersion(sMinimum)) != 3) || (sMaximum != "" && JsonGetLength(MEMORIA_ParseRangeVersion(sMaximum)) != 3)) return FALSE;
            if (sMinimum != "" && sMaximum != "")
            {
                int nComparison = MEMORIA_CompareVersions(MEMORIA_ParseRangeVersion(sMinimum), MEMORIA_ParseRangeVersion(sMaximum));
                if (nComparison > 0 || (nComparison == 0 && (sOpen != "[" || sClose != "]"))) return FALSE;
            }
        }
        if (nSeparator < 0) return TRUE;
        nStart = nSeparator + 1;
    }
    return FALSE;
}

int MEMORIA_FindPackage(json jPackages, string sId)
{
    int nIndex;
    for (nIndex = 0; nIndex < JsonGetLength(jPackages); nIndex++)
    {
        if (MEMORIA_IdEquals(JsonGetString(JsonObjectGet(JsonArrayGet(jPackages, nIndex), "id")), sId)) return nIndex;
    }
    return -1;
}

string MEMORIA_ValidateDependencies(json jDependencies, string sModId)
{
    if (JsonGetType(jDependencies) != JSON_TYPE_ARRAY) return "dependencies must be an array";
    json jIds = JsonArray();
    int nIndex;
    for (nIndex = 0; nIndex < JsonGetLength(jDependencies); nIndex++)
    {
        json jDependency = JsonArrayGet(jDependencies, nIndex);
        string sId = JsonGetString(JsonObjectGet(jDependency, "id"));
        string sVersions = JsonGetString(JsonObjectGet(jDependency, "versions"));
        if (JsonGetType(jDependency) != JSON_TYPE_OBJECT || sId == "" || !MEMORIA_IsValidVersions(sVersions)) return "each dependency must contain an id and valid versions";
        if (MEMORIA_IdEquals(sId, sModId)) return "a package cannot depend on itself";
        int nSeen;
        for (nSeen = 0; nSeen < JsonGetLength(jIds); nSeen++)
        {
            if (MEMORIA_IdEquals(JsonGetString(JsonArrayGet(jIds, nSeen)), sId)) return "duplicate dependency " + sId;
        }
        jIds = JsonArrayInsert(jIds, JsonString(sId));
    }
    return "";
}

void MEMORIA_ReportPackageErrors(object oPlayer, json jPackages)
{
    string sSignature = "";
    string sDetails = "";
    int nFailed;
    int nIndex;
    for (nIndex = 0; nIndex < JsonGetLength(jPackages); nIndex++)
    {
        json jPackage = JsonArrayGet(jPackages, nIndex);
        if (JsonGetInt(JsonObjectGet(jPackage, "_enabled"))) continue;
        string sResource = JsonGetString(JsonObjectGet(jPackage, "_resource"));
        string sName = JsonGetString(JsonObjectGet(jPackage, "name"));
        if (sName == "") sName = JsonGetString(JsonObjectGet(jPackage, "id"));
        if (sName == "") sName = sResource;
        string sError = JsonGetString(JsonObjectGet(jPackage, "_error"));
        string sEntry = sName + " (" + sResource + ".txt) incompatible with:\n- " + sError;
        nFailed++;
        sSignature += "|" + sResource + ":" + sError;
        sDetails = sDetails == "" ? sEntry : sDetails + "\n\n" + sEntry;
    }
    if (GetLocalInt(oPlayer, MEMORIA_ERRORS_REPORTED_LOCAL) && GetLocalString(oPlayer, MEMORIA_ERRORS_LOCAL) == sSignature) return;
    SetLocalInt(oPlayer, MEMORIA_ERRORS_REPORTED_LOCAL, TRUE);
    SetLocalString(oPlayer, MEMORIA_ERRORS_LOCAL, sSignature);
    int nLoaded = JsonGetLength(jPackages) - nFailed;
    if (sDetails != "")
    {
        string sSummary = IntToString(nFailed) + (nFailed == 1 ? " mod failed" : " mods failed") + " to initialize; " + IntToString(nLoaded) + (nLoaded == 1 ? " mod loaded successfully." : " mods loaded successfully.");
        SendMessageToPC(oPlayer, StringToRGBString("Memoria found incompatible mods:", STRING_COLOR_RED) + "\n\n" + StringToRGBString(sDetails, "770") + "\n\n" + StringToRGBString(sSummary, STRING_COLOR_RED));
    }
    else
    {
        string sMod = nLoaded == 1 ? " mod" : " mods";
        SendMessageToPC(oPlayer, StringToRGBString("Memoria: All " + IntToString(nLoaded) + sMod + " loaded successfully.", STRING_COLOR_GREEN));
    }
}

json MEMORIA_DiscoverPackages(object oPlayer)
{
    json jPackages = JsonArray();
    int nNth = 1;
    string sResource = ResManFindPrefix("", RESTYPE_TXT, nNth, FALSE, "OVERRIDE:");
    while (sResource != "")
    {
        if (MEMORIA_IsManifestResource(sResource))
        {
            json jManifest = JsonParse(ResManGetFileContents(sResource, RESTYPE_TXT));
            string sError = JsonGetError(jManifest);
            string sId = JsonGetString(JsonObjectGet(jManifest, "id"));
            string sName = JsonGetString(JsonObjectGet(jManifest, "name"));
            string sVersion = JsonGetString(JsonObjectGet(jManifest, "version"));
            if (sError != "") { }
            else if (JsonGetType(jManifest) != JSON_TYPE_OBJECT || JsonGetInt(JsonObjectGet(jManifest, "schema")) != MEMORIA_MANIFEST_SCHEMA || sId == "") sError = "invalid schema or id";
            else if (JsonGetLength(MEMORIA_ParseVersion(sVersion)) != 3) sError = "version must use X.Y.Z SemVer notation";
            else sError = MEMORIA_ValidateDependencies(JsonObjectGet(jManifest, "dependencies"), sId);
            json jBootstrapper = JsonObjectGet(jManifest, "bootstrapper");
            string sHeartbeat = JsonGetString(JsonObjectGet(jBootstrapper, "heartbeat"));
            if (sError == "" && JsonGetType(jBootstrapper) != JSON_TYPE_NULL && (JsonGetType(jBootstrapper) != JSON_TYPE_OBJECT || sHeartbeat == "")) sError = "invalid bootstrapper section or heartbeat resource";
            else if (sError == "" && sHeartbeat != "" && ResManGetAliasFor(sHeartbeat, RESTYPE_NCS) == "") sError = "heartbeat script " + sHeartbeat + ".ncs was not found";
            int nDuplicate = sError == "" ? MEMORIA_FindPackage(jPackages, sId) : -1;
            if (sError != "")
            {
                if (JsonGetType(jManifest) != JSON_TYPE_OBJECT) jManifest = JsonObject();
                jManifest = JsonObjectSet(jManifest, "id", JsonString(sId));
                jManifest = JsonObjectSet(jManifest, "name", JsonString(sName));
                jManifest = JsonObjectSet(jManifest, "_resource", JsonString(sResource));
                jManifest = JsonObjectSet(jManifest, "_enabled", JsonBool(FALSE));
                jManifest = JsonObjectSet(jManifest, "_error", JsonString(sError));
                jPackages = JsonArrayInsert(jPackages, jManifest);
            }
            else if (nDuplicate >= 0)
            {
                json jDuplicate = JsonArrayGet(jPackages, nDuplicate);
                jDuplicate = JsonObjectSet(jDuplicate, "_enabled", JsonBool(FALSE));
                jDuplicate = JsonObjectSet(jDuplicate, "_error", JsonString("duplicate package id " + sId));
                jPackages = JsonArraySet(jPackages, nDuplicate, jDuplicate);
                jManifest = JsonObjectSet(jManifest, "_resource", JsonString(sResource));
                jManifest = JsonObjectSet(jManifest, "_enabled", JsonBool(FALSE));
                jManifest = JsonObjectSet(jManifest, "_error", JsonString("duplicate package id " + sId));
                jPackages = JsonArrayInsert(jPackages, jManifest);
            }
            else
            {
                jManifest = JsonObjectSet(jManifest, "_resource", JsonString(sResource));
                jManifest = JsonObjectSet(jManifest, "_enabled", JsonBool(TRUE));
                jPackages = JsonArrayInsert(jPackages, jManifest);
            }
        }
        nNth++;
        sResource = ResManFindPrefix("", RESTYPE_TXT, nNth, FALSE, "OVERRIDE:");
    }

    int nPass;
    for (nPass = 0; nPass < JsonGetLength(jPackages); nPass++)
    {
        int nPackage;
        for (nPackage = 0; nPackage < JsonGetLength(jPackages); nPackage++)
        {
            json jPackage = JsonArrayGet(jPackages, nPackage);
            if (!JsonGetInt(JsonObjectGet(jPackage, "_enabled"))) continue;
            json jDependencies = JsonObjectGet(jPackage, "dependencies");
            string sDependencyError = "";
            int nDependency;
            for (nDependency = 0; nDependency < JsonGetLength(jDependencies) && sDependencyError == ""; nDependency++)
            {
                json jRequirement = JsonArrayGet(jDependencies, nDependency);
                string sRequiredId = JsonGetString(JsonObjectGet(jRequirement, "id"));
                string sVersions = JsonGetString(JsonObjectGet(jRequirement, "versions"));
                int nInstalledIndex = MEMORIA_FindPackage(jPackages, sRequiredId);
                if (nInstalledIndex < 0) sDependencyError = sRequiredId + " not installed, requires: " + sVersions;
                else
                {
                    json jInstalled = JsonArrayGet(jPackages, nInstalledIndex);
                    string sInstalledVersion = JsonGetString(JsonObjectGet(jInstalled, "version"));
                    if (!JsonGetInt(JsonObjectGet(jInstalled, "_enabled"))) sDependencyError = sRequiredId + " " + sInstalledVersion + " disabled, requires: " + sVersions;
                    else if (!MEMORIA_IsCompatibleVersion(sInstalledVersion, sVersions)) sDependencyError = sRequiredId + " " + sInstalledVersion + ", requires: " + sVersions;
                }
            }
            if (sDependencyError != "")
            {
                jPackage = JsonObjectSet(jPackage, "_enabled", JsonBool(FALSE));
                jPackage = JsonObjectSet(jPackage, "_error", JsonString(sDependencyError));
                jPackages = JsonArraySet(jPackages, nPackage, jPackage);
            }
        }
    }

    MEMORIA_ReportPackageErrors(oPlayer, jPackages);
    json jCompatible = JsonArray();
    int nIndex;
    for (nIndex = 0; nIndex < JsonGetLength(jPackages); nIndex++)
    {
        json jPackage = JsonArrayGet(jPackages, nIndex);
        if (JsonGetInt(JsonObjectGet(jPackage, "_enabled"))) jCompatible = JsonArrayInsert(jCompatible, jPackage);
    }
    return jCompatible;
}

json MEMORIA_BuildCacheWindow()
{
    return NuiWindow(NuiVisible(NuiSpacer(), JsonBool(FALSE)), JsonString(""), NuiRect(-100.0f, -100.0f, 1.0f, 1.0f), JsonBool(FALSE), JsonBool(FALSE), JsonBool(FALSE), JsonBool(TRUE), JsonBool(FALSE), JsonBool(FALSE));
}

json MEMORIA_GetPackages(object oPlayer)
{
    object oModule = GetModule();
    object oCacheOwner = GetLocalObject(oModule, MEMORIA_CACHE_OWNER_LOCAL);
    int nToken = GetIsObjectValid(oCacheOwner) ? NuiFindWindow(oCacheOwner, MEMORIA_CACHE_WINDOW) : 0;
    json jPackages = NuiGetUserData(oCacheOwner, nToken);
    if (nToken > 0 && JsonGetType(jPackages) == JSON_TYPE_ARRAY) return jPackages;
    jPackages = MEMORIA_DiscoverPackages(oPlayer);
    oCacheOwner = oPlayer;
    nToken = NuiFindWindow(oCacheOwner, MEMORIA_CACHE_WINDOW);
    if (nToken == 0) nToken = NuiCreate(oCacheOwner, MEMORIA_BuildCacheWindow(), MEMORIA_CACHE_WINDOW, "memoria_noop");
    if (nToken > 0)
    {
        NuiSetUserData(oCacheOwner, nToken, jPackages);
        SetLocalObject(oModule, MEMORIA_CACHE_OWNER_LOCAL, oCacheOwner);
    }
    return jPackages;
}
