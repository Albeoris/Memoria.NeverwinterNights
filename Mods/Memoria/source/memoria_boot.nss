// Dependency-aware heartbeat dispatcher for NWN:EE override mods.

#include "memoria_loader"

const string MEMORIA_BOOT_DISCOVERY_LOCAL = "MEMORIA_BOOT_DISCOVERY";
const string MEMORIA_BOOT_DISPATCH_CYCLE_LOCAL = "MEMORIA_BOOT_DISPATCH_CYCLE";
const string MEMORIA_BOOT_DISPATCH_DONE_LOCAL = "MEMORIA_BOOT_DISPATCH_DONE_";
const string MEMORIA_BOOT_DISPATCH_FAILURE_LOCAL = "MEMORIA_BOOT_DISPATCH_FAILURE_";

json MEMORIA_BOOT_GetEntries(object oPlayer)
{
    json jPackages = MEMORIA_GetPackages(oPlayer);
    json jEntries = JsonArray();
    int nPackage;
    for (nPackage = 0; nPackage < JsonGetLength(jPackages); nPackage++)
    {
        json jManifest = JsonArrayGet(jPackages, nPackage);
        json jBootstrapper = JsonObjectGet(jManifest, "bootstrapper");
        if (JsonGetType(jBootstrapper) == JSON_TYPE_NULL) continue;
        string sResource = JsonGetString(JsonObjectGet(jManifest, "_resource"));
        string sId = JsonGetString(JsonObjectGet(jManifest, "id"));
        string sHeartbeat = JsonGetString(JsonObjectGet(jBootstrapper, "heartbeat"));
        int nPriority = JsonGetInt(JsonObjectGet(jBootstrapper, "priority"));
        if (JsonGetType(jBootstrapper) != JSON_TYPE_OBJECT || sHeartbeat == "") MEMORIA_ReportError(oPlayer, sResource, "invalid bootstrapper section or heartbeat resource");
        else if (ResManGetAliasFor(sHeartbeat, RESTYPE_NCS) == "") MEMORIA_ReportError(oPlayer, sResource, "heartbeat script " + sHeartbeat + ".ncs was not found");
        else
        {
            if (MEMORIA_IdEquals(sId, "esi")) nPriority = 0;
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
    }
    return jEntries;
}

void MEMORIA_BOOT_CheckDispatch(object oPlayer, string sId, string sHeartbeat, string sDoneLocal, string sFailureLocal)
{
    if (!GetIsObjectValid(oPlayer)) return;
    if (!GetLocalInt(oPlayer, sDoneLocal))
    {
        string sFailure = sId + " (" + sHeartbeat + ".ncs)";
        if (GetLocalString(oPlayer, sFailureLocal) != sFailure)
        {
            SetLocalString(oPlayer, sFailureLocal, sFailure);
            SendMessageToPC(oPlayer, "Memoria heartbeat failed: " + sFailure + ". Other compatible mods will continue to run.");
        }
    }
    DeleteLocalInt(oPlayer, sDoneLocal);
}

void MEMORIA_BOOT_Dispatch(object oPlayer, string sId, string sHeartbeat, int nCycle, int nIndex)
{
    string sDoneLocal = MEMORIA_BOOT_DISPATCH_DONE_LOCAL + IntToString(nCycle) + "_" + IntToString(nIndex);
    string sFailureLocal = MEMORIA_BOOT_DISPATCH_FAILURE_LOCAL + IntToString(nIndex);
    DeleteLocalInt(oPlayer, sDoneLocal);
    DelayCommand(0.1f, MEMORIA_BOOT_CheckDispatch(oPlayer, sId, sHeartbeat, sDoneLocal, sFailureLocal));
    ExecuteScript(sHeartbeat, oPlayer);
    SetLocalInt(oPlayer, sDoneLocal, TRUE);
    DeleteLocalString(oPlayer, sFailureLocal);
}

void main()
{
    object oPlayer = OBJECT_SELF;
    if (!GetIsPC(oPlayer) || GetIsDM(oPlayer) || GetIsObjectValid(GetMaster(oPlayer)) || GetIsPossessedFamiliar(oPlayer)) return;
    json jEntries = MEMORIA_BOOT_GetEntries(oPlayer);
    int nCycle = GetLocalInt(oPlayer, MEMORIA_BOOT_DISPATCH_CYCLE_LOCAL) + 1;
    SetLocalInt(oPlayer, MEMORIA_BOOT_DISPATCH_CYCLE_LOCAL, nCycle);
    string sDetected = "";
    int nIndex;
    for (nIndex = 0; nIndex < JsonGetLength(jEntries); nIndex++)
    {
        json jEntry = JsonArrayGet(jEntries, nIndex);
        string sHeartbeat = JsonGetString(JsonObjectGet(jEntry, "heartbeat"));
        string sId = JsonGetString(JsonObjectGet(jEntry, "id"));
        DelayCommand(IntToFloat(nIndex) * 0.01f, MEMORIA_BOOT_Dispatch(oPlayer, sId, sHeartbeat, nCycle, nIndex));
        sDetected = sDetected == "" ? sId : sDetected + "," + sId;
    }
    if (GetLocalString(oPlayer, MEMORIA_BOOT_DISCOVERY_LOCAL) != sDetected)
    {
        SetLocalString(oPlayer, MEMORIA_BOOT_DISCOVERY_LOCAL, sDetected);
        SendMessageToPC(oPlayer, "Memoria heartbeat modules: " + (sDetected == "" ? "none" : sDetected) + ".");
    }
}
