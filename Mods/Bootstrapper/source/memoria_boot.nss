// Manifest-driven heartbeat loader for NWN:EE override mods.

#include "nw_inc_nui"

const string M_BOOTSTRAPPER_MANIFEST_PREFIX = "memoria_";
const string M_BOOTSTRAPPER_DISCOVERY_LOCAL = "M_BOOTSTRAPPER_DISCOVERY";
const string M_BOOTSTRAPPER_CACHE_OWNER_LOCAL = "M_BOOTSTRAPPER_CACHE_OWNER";
const string M_BOOTSTRAPPER_CACHE_WINDOW = "m_boot_cache";
const string M_BOOTSTRAPPER_DISPATCH_CYCLE_LOCAL = "M_BOOTSTRAPPER_DISPATCH_CYCLE";
const string M_BOOTSTRAPPER_DISPATCH_DONE_LOCAL = "M_BOOTSTRAPPER_DISPATCH_DONE_";
const string M_BOOTSTRAPPER_DISPATCH_FAILURE_LOCAL = "M_BOOTSTRAPPER_DISPATCH_FAILURE_";

void M_BOOTSTRAPPER_ReportError(object oPlayer, string sManifest, string sError)
{
    string sLocal = "M_BOOTSTRAPPER_ERR_" + sManifest;
    if (GetLocalString(oPlayer, sLocal) == sError) return;
    SetLocalString(oPlayer, sLocal, sError);
    SendMessageToPC(oPlayer, "Memoria Bootstrapper ignored " + sManifest + ".txt: " + sError);
}

int M_BOOTSTRAPPER_HasId(json jEntries, string sId)
{
    int nIndex;
    for (nIndex = 0; nIndex < JsonGetLength(jEntries); nIndex++)
    {
        if (JsonGetString(JsonObjectGet(JsonArrayGet(jEntries, nIndex), "id")) == sId) return TRUE;
    }
    return FALSE;
}

json M_BOOTSTRAPPER_DiscoverEntries(object oPlayer)
{
    json jEntries = JsonArray();
    int nNth = 1;
    string sManifest = ResManFindPrefix(M_BOOTSTRAPPER_MANIFEST_PREFIX, RESTYPE_TXT, nNth, FALSE);
    while (sManifest != "")
    {
        json jManifest = JsonParse(ResManGetFileContents(sManifest, RESTYPE_TXT));
        string sError = JsonGetError(jManifest);
        int nSchema = JsonGetInt(JsonObjectGet(jManifest, "schema"));
        string sId = JsonGetString(JsonObjectGet(jManifest, "id"));
        string sHeartbeat = JsonGetString(JsonObjectGet(jManifest, "heartbeat"));
        int nPriority = JsonGetInt(JsonObjectGet(jManifest, "priority"));
        if (sError != "") M_BOOTSTRAPPER_ReportError(oPlayer, sManifest, sError);
        else if (JsonGetType(jManifest) != JSON_TYPE_OBJECT || nSchema != 1 || sId == "" || sHeartbeat == "") M_BOOTSTRAPPER_ReportError(oPlayer, sManifest, "invalid schema, id, or heartbeat resource");
        else if (M_BOOTSTRAPPER_HasId(jEntries, sId)) M_BOOTSTRAPPER_ReportError(oPlayer, sManifest, "duplicate module id " + sId);
        else if (ResManGetAliasFor(sHeartbeat, RESTYPE_NCS) == "") M_BOOTSTRAPPER_ReportError(oPlayer, sManifest, "heartbeat script " + sHeartbeat + ".ncs was not found");
        else
        {
            if (sId == "esi") nPriority = 0;
            else if (nPriority < 1) nPriority = 1;
            json jEntry = JsonObject();
            jEntry = JsonObjectSet(jEntry, "heartbeat", JsonString(sHeartbeat));
            jEntry = JsonObjectSet(jEntry, "id", JsonString(sId));
            jEntry = JsonObjectSet(jEntry, "priority", JsonInt(nPriority));
            jEntries = JsonArrayInsert(jEntries, jEntry);
            int nInsert = JsonGetLength(jEntries) - 1;
            while (nInsert > 0 && JsonGetInt(JsonObjectGet(JsonArrayGet(jEntries, nInsert - 1), "priority")) > nPriority)
            {
                json jPrevious = JsonArrayGet(jEntries, nInsert - 1);
                jEntries = JsonArraySet(jEntries, nInsert, jPrevious);
                jEntries = JsonArraySet(jEntries, nInsert - 1, jEntry);
                nInsert--;
            }
        }
        nNth++;
        sManifest = ResManFindPrefix(M_BOOTSTRAPPER_MANIFEST_PREFIX, RESTYPE_TXT, nNth, FALSE);
    }
    return jEntries;
}

json M_BOOTSTRAPPER_BuildCacheWindow()
{
    json jRoot = NuiVisible(NuiSpacer(), JsonBool(FALSE));
    return NuiWindow(jRoot, JsonString(""), NuiRect(-100.0f, -100.0f, 1.0f, 1.0f), JsonBool(FALSE), JsonBool(FALSE), JsonBool(FALSE), JsonBool(TRUE), JsonBool(FALSE), JsonBool(FALSE));
}

json M_BOOTSTRAPPER_GetEntries(object oPlayer)
{
    // NUI user data is server-side and expires with its window, so the cache cannot be restored from a save game.
    object oModule = GetModule();
    object oCacheOwner = GetLocalObject(oModule, M_BOOTSTRAPPER_CACHE_OWNER_LOCAL);
    int nToken = GetIsObjectValid(oCacheOwner) ? NuiFindWindow(oCacheOwner, M_BOOTSTRAPPER_CACHE_WINDOW) : 0;
    json jEntries = NuiGetUserData(oCacheOwner, nToken);
    if (nToken > 0 && JsonGetType(jEntries) == JSON_TYPE_ARRAY) return jEntries;

    jEntries = M_BOOTSTRAPPER_DiscoverEntries(oPlayer);
    oCacheOwner = oPlayer;
    nToken = NuiFindWindow(oCacheOwner, M_BOOTSTRAPPER_CACHE_WINDOW);
    if (nToken == 0) nToken = NuiCreate(oCacheOwner, M_BOOTSTRAPPER_BuildCacheWindow(), M_BOOTSTRAPPER_CACHE_WINDOW, "m_boot_noop");
    if (nToken > 0)
    {
        NuiSetUserData(oCacheOwner, nToken, jEntries);
        SetLocalObject(oModule, M_BOOTSTRAPPER_CACHE_OWNER_LOCAL, oCacheOwner);
    }
    return jEntries;
}

void M_BOOTSTRAPPER_CheckDispatch(object oPlayer, string sId, string sHeartbeat, string sDoneLocal, string sFailureLocal)
{
    if (!GetIsObjectValid(oPlayer)) return;
    if (!GetLocalInt(oPlayer, sDoneLocal))
    {
        string sFailure = sId + " (" + sHeartbeat + ".ncs)";
        if (GetLocalString(oPlayer, sFailureLocal) != sFailure)
        {
            SetLocalString(oPlayer, sFailureLocal, sFailure);
            SendMessageToPC(oPlayer, "Memoria Bootstrapper heartbeat failed: " + sFailure + ". Other registered mods will continue to run.");
        }
    }
    DeleteLocalInt(oPlayer, sDoneLocal);
}

void M_BOOTSTRAPPER_Dispatch(object oPlayer, string sId, string sHeartbeat, int nCycle, int nIndex)
{
    string sDoneLocal = M_BOOTSTRAPPER_DISPATCH_DONE_LOCAL + IntToString(nCycle) + "_" + IntToString(nIndex);
    string sFailureLocal = M_BOOTSTRAPPER_DISPATCH_FAILURE_LOCAL + IntToString(nIndex);
    DeleteLocalInt(oPlayer, sDoneLocal);
    DelayCommand(0.1f, M_BOOTSTRAPPER_CheckDispatch(oPlayer, sId, sHeartbeat, sDoneLocal, sFailureLocal));
    ExecuteScript(sHeartbeat, oPlayer);
    SetLocalInt(oPlayer, sDoneLocal, TRUE);
    DeleteLocalString(oPlayer, sFailureLocal);
}

void main()
{
    object oPlayer = OBJECT_SELF;
    if (!GetIsPC(oPlayer) || GetIsDM(oPlayer) || GetIsObjectValid(GetMaster(oPlayer)) || GetIsPossessedFamiliar(oPlayer)) return;

    json jEntries = M_BOOTSTRAPPER_GetEntries(oPlayer);
    int nCycle = GetLocalInt(oPlayer, M_BOOTSTRAPPER_DISPATCH_CYCLE_LOCAL) + 1;
    SetLocalInt(oPlayer, M_BOOTSTRAPPER_DISPATCH_CYCLE_LOCAL, nCycle);

    string sDetected = "";
    int nIndex;
    for (nIndex = 0; nIndex < JsonGetLength(jEntries); nIndex++)
    {
        json jEntry = JsonArrayGet(jEntries, nIndex);
        string sHeartbeat = JsonGetString(JsonObjectGet(jEntry, "heartbeat"));
        string sId = JsonGetString(JsonObjectGet(jEntry, "id"));
        DelayCommand(IntToFloat(nIndex) * 0.01f, M_BOOTSTRAPPER_Dispatch(oPlayer, sId, sHeartbeat, nCycle, nIndex));
        sDetected = sDetected == "" ? sId : sDetected + "," + sId;
    }
    if (GetLocalString(oPlayer, M_BOOTSTRAPPER_DISCOVERY_LOCAL) != sDetected)
    {
        SetLocalString(oPlayer, M_BOOTSTRAPPER_DISCOVERY_LOCAL, sDetected);
        SendMessageToPC(oPlayer, "Memoria Bootstrapper heartbeat modules: " + (sDetected == "" ? "none" : sDetected) + ".");
    }
}
