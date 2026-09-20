// Shared heartbeat diagnostics for isolated package dispatch.

const string MEMORIA_HEARTBEAT_DIAGNOSTIC_LOCAL = "MEMORIA_HEARTBEAT_DIAGNOSTIC";
const string MEMORIA_HEARTBEAT_DIAGNOSTIC_TARGET_LOCAL = "MEMORIA_HEARTBEAT_DIAGNOSTIC_TARGET";

/// @brief Records the current package stage for Memoria's heartbeat failure report.
/// @param oPlayer Player whose heartbeat is being dispatched.
/// @param sStage Short description of the operation currently in progress.
void MEMORIA_SetHeartbeatDiagnostic(object oPlayer, string sStage)
{
    string sLocal = GetLocalString(oPlayer, MEMORIA_HEARTBEAT_DIAGNOSTIC_TARGET_LOCAL);
    if (sLocal == "") sLocal = MEMORIA_HEARTBEAT_DIAGNOSTIC_LOCAL;
    SetLocalString(oPlayer, sLocal, sStage);
}

/// @brief Clears the last reported heartbeat stage.
/// @param oPlayer Player whose diagnostic state is cleared.
void MEMORIA_ClearHeartbeatDiagnostic(object oPlayer)
{
    string sLocal = GetLocalString(oPlayer, MEMORIA_HEARTBEAT_DIAGNOSTIC_TARGET_LOCAL);
    if (sLocal == "") sLocal = MEMORIA_HEARTBEAT_DIAGNOSTIC_LOCAL;
    DeleteLocalString(oPlayer, sLocal);
}
