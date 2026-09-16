// Shared manifest discovery and dependency compatibility for Memoria packages.

#include "nw_inc_nui"

const string MEMORIA_MANIFEST_SUFFIX = "_memoria";
const string MEMORIA_CACHE_OWNER_LOCAL = "MEMORIA_CACHE_OWNER";
const string MEMORIA_CACHE_WINDOW = "memoria_cache";
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
    SendMessageToPC(oPlayer, "Memoria ignored " + sResource + ".txt: " + sError);
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

int MEMORIA_IsCompatibleVersion(string sInstalled, string sMinimum)
{
    json jInstalled = MEMORIA_ParseVersion(sInstalled);
    json jMinimum = MEMORIA_ParseVersion(sMinimum);
    if (JsonGetLength(jInstalled) != 3 || JsonGetLength(jMinimum) != 3) return FALSE;
    int nInstalledMajor = JsonGetInt(JsonArrayGet(jInstalled, 0));
    int nMinimumMajor = JsonGetInt(JsonArrayGet(jMinimum, 0));
    if (nInstalledMajor != nMinimumMajor) return FALSE;
    int nIndex;
    for (nIndex = 0; nIndex < 3; nIndex++)
    {
        int nInstalled = JsonGetInt(JsonArrayGet(jInstalled, nIndex));
        int nRequired = JsonGetInt(JsonArrayGet(jMinimum, nIndex));
        if (nInstalled > nRequired) return TRUE;
        if (nInstalled < nRequired) return FALSE;
    }
    return TRUE;
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

string MEMORIA_ValidateDependencies(json jDependencies, string sPackageId)
{
    if (JsonGetType(jDependencies) != JSON_TYPE_ARRAY) return "dependencies must be an array";
    json jIds = JsonArray();
    int nIndex;
    for (nIndex = 0; nIndex < JsonGetLength(jDependencies); nIndex++)
    {
        json jDependency = JsonArrayGet(jDependencies, nIndex);
        string sId = JsonGetString(JsonObjectGet(jDependency, "id"));
        string sVersion = JsonGetString(JsonObjectGet(jDependency, "version"));
        if (JsonGetType(jDependency) != JSON_TYPE_OBJECT || sId == "" || JsonGetLength(MEMORIA_ParseVersion(sVersion)) != 3) return "each dependency must contain an id and an X.Y.Z minimum version";
        if (MEMORIA_IdEquals(sId, sPackageId)) return "a package cannot depend on itself";
        int nSeen;
        for (nSeen = 0; nSeen < JsonGetLength(jIds); nSeen++)
        {
            if (MEMORIA_IdEquals(JsonGetString(JsonArrayGet(jIds, nSeen)), sId)) return "duplicate dependency " + sId;
        }
        jIds = JsonArrayInsert(jIds, JsonString(sId));
    }
    return "";
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
            if (sError != "") MEMORIA_ReportError(oPlayer, sResource, sError);
            else if (nDuplicate >= 0)
            {
                json jDuplicate = JsonArrayGet(jPackages, nDuplicate);
                string sDuplicateResource = JsonGetString(JsonObjectGet(jDuplicate, "_resource"));
                MEMORIA_ReportError(oPlayer, sDuplicateResource, "duplicate package id " + sId);
                MEMORIA_ReportError(oPlayer, sResource, "duplicate package id " + sId);
                jDuplicate = JsonObjectSet(jDuplicate, "_enabled", JsonBool(FALSE));
                jDuplicate = JsonObjectSet(jDuplicate, "_error", JsonString("duplicate package id " + sId));
                jPackages = JsonArraySet(jPackages, nDuplicate, jDuplicate);
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
                string sMinimum = JsonGetString(JsonObjectGet(jRequirement, "version"));
                int nInstalledIndex = MEMORIA_FindPackage(jPackages, sRequiredId);
                if (nInstalledIndex < 0) sDependencyError = "requires " + sRequiredId + " " + sMinimum + " or newer within major version " + GetSubString(sMinimum, 0, FindSubString(sMinimum, ".")) + ", but it is not installed";
                else
                {
                    json jInstalled = JsonArrayGet(jPackages, nInstalledIndex);
                    string sInstalledVersion = JsonGetString(JsonObjectGet(jInstalled, "version"));
                    if (!JsonGetInt(JsonObjectGet(jInstalled, "_enabled"))) sDependencyError = "requires " + sRequiredId + ", but that package is disabled";
                    else if (!MEMORIA_IsCompatibleVersion(sInstalledVersion, sMinimum)) sDependencyError = "requires " + sRequiredId + " " + sMinimum + " or newer within the same major version, but " + sInstalledVersion + " is installed";
                }
            }
            if (sDependencyError != "")
            {
                jPackage = JsonObjectSet(jPackage, "_enabled", JsonBool(FALSE));
                jPackage = JsonObjectSet(jPackage, "_error", JsonString(sDependencyError));
                jPackages = JsonArraySet(jPackages, nPackage, jPackage);
                MEMORIA_ReportError(oPlayer, JsonGetString(JsonObjectGet(jPackage, "_resource")), sDependencyError);
            }
        }
    }

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
