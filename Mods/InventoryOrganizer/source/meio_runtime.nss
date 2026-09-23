// Heartbeat integration and low-frequency physical-content validation.

#include "meio_ui"

void MEIO_InstallHooks()
{
    object oModule = GetModule();
    ESI_InjectToObject(oModule, MEIO_ESI_ACQUIRE, EVENT_SCRIPT_MODULE_ON_ACQUIRE_ITEM, "meio_modacq", ESI_INJECTION_PLACEMENT_FIRST);
    ESI_InjectToObject(oModule, MEIO_ESI_GUI, EVENT_SCRIPT_MODULE_ON_PLAYER_GUIEVENT, "meio_guievt", ESI_INJECTION_PLACEMENT_FIRST);
    ESI_InjectToObject(oModule, MEIO_ESI_TARGET, EVENT_SCRIPT_MODULE_ON_PLAYER_TARGET, "meio_target", ESI_INJECTION_PLACEMENT_FIRST);
    ESI_InjectToObject(oModule, MEIO_ESI_CHAT, EVENT_SCRIPT_MODULE_ON_PLAYER_CHAT, "meio_modchat", ESI_INJECTION_PLACEMENT_LAST);
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
        MEIO_EndTransfer(oPC, MEIO_TRANSFER_INITIAL_IMPORT);
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
    SetLocalInt(oPC, MEIO_LOCAL_HEARTBEAT_COUNTER, GetLocalInt(oPC, MEIO_LOCAL_HEARTBEAT_COUNTER) + 1);
    MEIO_RecoverStaleKeyTransfer(oPC);
    MEIO_GetUIScalePercent(oPC);
    MEIO_EnsureAutomaticSettings(oPC);
    MEIO_Debug(oPC, "Heartbeat entered; regular inventory sorting is disabled on heartbeat reserved=" + ObjectToString(GetLocalObject(oPC, MEIO_LOCAL_RESERVED)) + " suppress=" + IntToString(GetLocalInt(oPC, MEIO_LOCAL_SUPPRESS_SORT)));
    MEMORIA_SetHeartbeatDiagnostic(oPC, "installing MEIO event hooks");
    MEIO_InstallHooks();
    MEIO_CleanupKeepOutRegistry(oPC);
    if (!ESI_IsRuntimeMarkerSet(oPC, MEIO_RUNTIME_INITIAL_IMPORT))
    {
        DeleteLocalInt(oPC, MEIO_LOCAL_INITIAL_IMPORT_RUNNING);
        DeleteLocalInt(oPC, MEIO_LOCAL_TRANSFER_MODE);
        ESI_SetRuntimeMarker(oPC, MEIO_RUNTIME_INITIAL_IMPORT);
    }
    MEMORIA_SetHeartbeatDiagnostic(oPC, "initializing the Scriptorium and its physical storage");
    object oScriptorium = MEIO_EnsureScriptorium(oPC);
    object oStorage = MEIO_EnsureStorage(oPC);
    object oPotionStorage = MEIO_EnsurePotionStorage(oPC);
    object oBookStorage = MEIO_EnsureBookStorage(oPC);
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
    if (GetIsObjectValid(oScriptorium) && GetIsObjectValid(oStorage) && GetIsObjectValid(oPotionStorage) && GetIsObjectValid(oBookStorage))
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
                if (MEIO_BeginTransfer(oPC, MEIO_TRANSFER_INITIAL_IMPORT, FALSE))
                {
                    int iGeneration = GetLocalInt(oPC, MEIO_LOCAL_INITIAL_IMPORT_GENERATION) + 1;
                    SetLocalInt(oPC, MEIO_LOCAL_INITIAL_IMPORT_GENERATION, iGeneration);
                    SetLocalInt(oPC, MEIO_LOCAL_INITIAL_IMPORT_RUNNING, TRUE);
                    MEIO_RunInitialImportBatch(oPC, iGeneration);
                }
            }
        }
        MEMORIA_SetHeartbeatDiagnostic(oPC, "validating Scriptorium contents");
        MEIO_ValidateContents(oPC, oStorage);
        MEIO_ValidatePotionContents(oPC, oPotionStorage);
        MEIO_ValidateBookContents(oPC, oBookStorage);
        MEIO_ProcessVaultContents(oPC, MEIO_INITIAL_IMPORT_BATCH_SIZE);
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
