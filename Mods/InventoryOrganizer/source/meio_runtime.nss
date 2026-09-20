// Heartbeat integration and low-frequency physical-content validation.

#include "meio_ui"

void MEIO_InstallHooks()
{
    object oModule = GetModule();
    ESI_InjectToObject(oModule, MEIO_ESI_ACQUIRE, EVENT_SCRIPT_MODULE_ON_ACQUIRE_ITEM, "meio_modacq", ESI_INJECTION_PLACEMENT_FIRST);
    ESI_InjectToObject(oModule, MEIO_ESI_ACTIVATE, EVENT_SCRIPT_MODULE_ON_ACTIVATE_ITEM, "meio_modact", ESI_INJECTION_PLACEMENT_FIRST);
    ESI_InjectToObject(oModule, MEIO_ESI_GUI, EVENT_SCRIPT_MODULE_ON_PLAYER_GUIEVENT, "meio_guievt", ESI_INJECTION_PLACEMENT_FIRST);
    ESI_InjectToObject(oModule, MEIO_ESI_TARGET, EVENT_SCRIPT_MODULE_ON_PLAYER_TARGET, "meio_target", ESI_INJECTION_PLACEMENT_FIRST);
}

void MEIO_RunInitialImportBatch(object oPC, int iGeneration)
{
    if (!MEIO_IsPC(oPC) || GetLocalInt(oPC, MEIO_LOCAL_INITIAL_IMPORT_DONE) || GetLocalInt(oPC, MEIO_LOCAL_INITIAL_IMPORT_GENERATION) != iGeneration)
    {
        return;
    }
    MEIO_Debug(oPC, "Initial Scriptorium import batch started limit=" + IntToString(MEIO_INITIAL_IMPORT_BATCH_SIZE));
    int bComplete = MEIO_StoreInitialInventoryBatch(oPC, MEIO_INITIAL_IMPORT_BATCH_SIZE);
    MEIO_RebuildOpenWindowIndex(oPC);
    if (bComplete)
    {
        SetLocalInt(oPC, MEIO_LOCAL_INITIAL_IMPORT_DONE, TRUE);
        DeleteLocalInt(oPC, MEIO_LOCAL_INITIAL_IMPORT_RUNNING);
        MEIO_Debug(oPC, "Initial Scriptorium import completed");
        return;
    }
    DelayCommand(0.1f, MEIO_RunInitialImportBatch(oPC, iGeneration));
}

void MEIO_Heartbeat(object oPC)
{
    if (!MEIO_IsPC(oPC))
    {
        return;
    }
    MEIO_Debug(oPC, "Heartbeat entered; regular inventory sorting is disabled on heartbeat reserved=" + ObjectToString(GetLocalObject(oPC, MEIO_LOCAL_RESERVED)) + " suppress=" + IntToString(GetLocalInt(oPC, MEIO_LOCAL_SUPPRESS_SORT)) + " sortMode=" + IntToString(GetLocalInt(oPC, MEIO_CFG_SORT_MODE)));
    MEMORIA_SetHeartbeatDiagnostic(oPC, "installing MEIO event hooks");
    MEIO_InstallHooks();
    MEIO_CleanupKeepOutRegistry(oPC);
    if (!ESI_IsRuntimeMarkerSet(oPC, MEIO_RUNTIME_INITIAL_IMPORT))
    {
        DeleteLocalInt(oPC, MEIO_LOCAL_INITIAL_IMPORT_RUNNING);
        ESI_SetRuntimeMarker(oPC, MEIO_RUNTIME_INITIAL_IMPORT);
    }
    MEMORIA_SetHeartbeatDiagnostic(oPC, "initializing the Scriptorium and its physical storage");
    object oScriptorium = MEIO_EnsureScriptorium(oPC);
    object oStorage = MEIO_EnsureStorage(oPC);
    if (!ESI_IsRuntimeMarkerSet(oPC, MEIO_RUNTIME_RESERVATION))
    {
        if (GetIsObjectValid(GetLocalObject(oPC, MEIO_LOCAL_RESERVED)))
        {
            MEIO_Debug(oPC, "Heartbeat startup recovery decision=return-reservation");
            MEIO_ReturnReservation(oPC);
        }
        else
        {
            MEIO_Debug(oPC, "Heartbeat startup recovery decision=clear-empty-reservation");
            MEIO_ClearReservation(oPC);
        }
        ESI_SetRuntimeMarker(oPC, MEIO_RUNTIME_RESERVATION);
    }
    if (GetIsObjectValid(oScriptorium) && GetIsObjectValid(oStorage))
    {
        if (!GetLocalInt(oPC, MEIO_LOCAL_INITIAL_IMPORT_DONE))
        {
            if (!GetLocalInt(oPC, MEIO_LOCAL_INITIAL_IMPORT_RUNNING))
            {
                if (!GetLocalInt(oPC, MEIO_LOCAL_INITIAL_IMPORT_SNAPSHOT_DONE))
                {
                    MEIO_MarkInitialImportItems(oPC);
                    SetLocalInt(oPC, MEIO_LOCAL_INITIAL_IMPORT_SNAPSHOT_DONE, TRUE);
                }
                int iGeneration = GetLocalInt(oPC, MEIO_LOCAL_INITIAL_IMPORT_GENERATION) + 1;
                SetLocalInt(oPC, MEIO_LOCAL_INITIAL_IMPORT_GENERATION, iGeneration);
                SetLocalInt(oPC, MEIO_LOCAL_INITIAL_IMPORT_RUNNING, TRUE);
                MEIO_RunInitialImportBatch(oPC, iGeneration);
            }
        }
        MEMORIA_SetHeartbeatDiagnostic(oPC, "validating Scriptorium contents");
        MEIO_ValidateContents(oPC, oStorage);
        MEIO_ReconcileDuplicates(oPC, oScriptorium);
    }
    object oReserved = GetLocalObject(oPC, MEIO_LOCAL_RESERVED);
    if ((!GetIsObjectValid(oReserved) && GetLocalInt(oPC, MEIO_LOCAL_RESERVED_ISSUED)) || (GetIsObjectValid(oReserved) && !MEIO_IsDirectlyIn(oReserved, oPC)))
    {
        MEIO_Debug(oPC, "Heartbeat decision=clear-reservation reason=reserved-item-not-in-player-inventory " + MEIO_DebugItemState(oPC, oReserved));
        MEIO_ClearReservation(oPC);
    }
    MEIO_Debug(oPC, "Heartbeat completed; no recurring inventory scroll transfer attempted");
    MEMORIA_SetHeartbeatDiagnostic(oPC, "MEIO heartbeat completed");
}
