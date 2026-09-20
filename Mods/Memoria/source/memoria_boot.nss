// Dependency-aware heartbeat dispatcher for NWN:EE override mods.

#include "memoria_loader"
#include "memoria_diag"

const string MEMORIA_BOOT_DISPATCH_CYCLE_LOCAL = "MEMORIA_BOOT_DISPATCH_CYCLE";
const string MEMORIA_BOOT_DISPATCH_DONE_LOCAL = "MEMORIA_BOOT_DISPATCH_DONE_";
const string MEMORIA_BOOT_DISPATCH_FAILURE_LOCAL = "MEMORIA_BOOT_DISPATCH_FAILURE_";
const string MEMORIA_BOOT_DISPATCH_DIAGNOSTIC_LOCAL = "MEMORIA_BOOT_DISPATCH_DIAGNOSTIC_";

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

void MEMORIA_BOOT_CheckDispatch(object oPlayer, string sId, string sHeartbeat, string sDoneLocal, string sFailureLocal, string sDiagnosticLocal)
{
    if (!GetIsObjectValid(oPlayer)) return;
    if (!GetLocalInt(oPlayer, sDoneLocal))
    {
        string sFailure = sId + " (" + sHeartbeat + ".ncs)";
        if (GetLocalString(oPlayer, sFailureLocal) != sFailure)
        {
            SetLocalString(oPlayer, sFailureLocal, sFailure);
            string sDiagnostic = GetLocalString(oPlayer, sDiagnosticLocal);
            if (sDiagnostic == "") sDiagnostic = "the package did not report its current stage";
            SendMessageToPC(oPlayer, "Memoria heartbeat failed: " + sFailure + ". Last reported stage: " + sDiagnostic + ". The exact VM error is written to nwengineLog.txt because NWScript does not expose it to the caller. Other compatible mods will continue to run.");
        }
    }
    DeleteLocalInt(oPlayer, sDoneLocal);
    DeleteLocalString(oPlayer, sDiagnosticLocal);
}

void MEMORIA_BOOT_Dispatch(object oPlayer, string sId, string sHeartbeat, int nCycle, int nIndex)
{
    string sDoneLocal = MEMORIA_BOOT_DISPATCH_DONE_LOCAL + IntToString(nCycle) + "_" + IntToString(nIndex);
    string sFailureLocal = MEMORIA_BOOT_DISPATCH_FAILURE_LOCAL + IntToString(nIndex);
    string sDiagnosticLocal = MEMORIA_BOOT_DISPATCH_DIAGNOSTIC_LOCAL + IntToString(nCycle) + "_" + IntToString(nIndex);
    DeleteLocalInt(oPlayer, sDoneLocal);
    DeleteLocalString(oPlayer, sDiagnosticLocal);
    DelayCommand(0.1f, MEMORIA_BOOT_CheckDispatch(oPlayer, sId, sHeartbeat, sDoneLocal, sFailureLocal, sDiagnosticLocal));
    SetLocalString(oPlayer, MEMORIA_HEARTBEAT_DIAGNOSTIC_TARGET_LOCAL, sDiagnosticLocal);
    ExecuteScript(sHeartbeat, oPlayer);
    SetLocalInt(oPlayer, sDoneLocal, TRUE);
    DeleteLocalString(oPlayer, sFailureLocal);
    DeleteLocalString(oPlayer, sDiagnosticLocal);
    DeleteLocalString(oPlayer, MEMORIA_HEARTBEAT_DIAGNOSTIC_TARGET_LOCAL);
}

void main()
{
    object oPlayer = OBJECT_SELF;
    if (!GetIsPC(oPlayer) || GetIsDM(oPlayer) || GetIsObjectValid(GetMaster(oPlayer)) || GetIsPossessedFamiliar(oPlayer)) return;
    json jEntries = MEMORIA_BOOT_GetEntries(oPlayer);
    int nCycle = GetLocalInt(oPlayer, MEMORIA_BOOT_DISPATCH_CYCLE_LOCAL) + 1;
    SetLocalInt(oPlayer, MEMORIA_BOOT_DISPATCH_CYCLE_LOCAL, nCycle);
    int nIndex;
    for (nIndex = 0; nIndex < JsonGetLength(jEntries); nIndex++)
    {
        json jEntry = JsonArrayGet(jEntries, nIndex);
        string sHeartbeat = JsonGetString(JsonObjectGet(jEntry, "heartbeat"));
        string sId = JsonGetString(JsonObjectGet(jEntry, "id"));
        DelayCommand(IntToFloat(nIndex) * 0.01f, MEMORIA_BOOT_Dispatch(oPlayer, sId, sHeartbeat, nCycle, nIndex));
    }
}
