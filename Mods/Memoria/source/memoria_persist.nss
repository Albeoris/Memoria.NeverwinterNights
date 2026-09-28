// Save-local authoritative persistence with a player-scoped campaign bridge.

const string MEMORIA_PERSIST_DATABASE = "memoriapersist";
const string MEMORIA_PERSIST_LOCAL_PREFIX = "MEMORIA_PERSIST_";

string MEMORIA_PersistHashPart(string sValue)
{
    string sHash = IntToString(HashString(sValue));
    if (GetSubString(sHash, 0, 1) == "-")
    {
        sHash = "n" + GetSubString(sHash, 1, GetStringLength(sHash) - 1);
    }
    return sHash;
}

string MEMORIA_PersistJsonKey(string sNamespace, string sStateId)
{
    return "j" + MEMORIA_PersistHashPart(GetStringLowerCase(sNamespace)) + "s" + MEMORIA_PersistHashPart(GetStringLowerCase(sStateId));
}

string MEMORIA_PersistObjectKey(string sNamespace, string sSlot)
{
    return "o" + MEMORIA_PersistHashPart(GetStringLowerCase(sNamespace)) + "s" + MEMORIA_PersistHashPart(GetStringLowerCase(sSlot));
}

string MEMORIA_PersistLocalJsonKey(string sNamespace, string sStateId)
{
    return MEMORIA_PERSIST_LOCAL_PREFIX + "JSON_" + MEMORIA_PersistJsonKey(sNamespace, sStateId);
}

string MEMORIA_PersistLocalInitializedKey(string sNamespace, string sStateId)
{
    return MEMORIA_PERSIST_LOCAL_PREFIX + "INITIALIZED_" + MEMORIA_PersistJsonKey(sNamespace, sStateId);
}

int MEMORIA_PersistHasLocalJson(string sNamespace, string sStateId)
{
    return GetLocalInt(GetModule(), MEMORIA_PersistLocalInitializedKey(sNamespace, sStateId));
}

json MEMORIA_PersistGetLocalJson(string sNamespace, string sStateId)
{
    return GetLocalJson(GetModule(), MEMORIA_PersistLocalJsonKey(sNamespace, sStateId));
}

json MEMORIA_PersistGetCampaignJson(object oPC, string sNamespace, string sStateId)
{
    return GetCampaignJson(MEMORIA_PERSIST_DATABASE, MEMORIA_PersistJsonKey(sNamespace, sStateId), oPC);
}

json MEMORIA_PersistInitializeJson(object oPC, string sNamespace, string sStateId, json jDefault, int bImportCampaignState)
{
    object oModule = GetModule();
    string sLocalKey = MEMORIA_PersistLocalJsonKey(sNamespace, sStateId);
    string sInitializedKey = MEMORIA_PersistLocalInitializedKey(sNamespace, sStateId);
    json jState;
    if (GetLocalInt(oModule, sInitializedKey))
    {
        jState = GetLocalJson(oModule, sLocalKey);
    }
    else
    {
        jState = bImportCampaignState ? MEMORIA_PersistGetCampaignJson(oPC, sNamespace, sStateId) : JsonNull();
        if (JsonGetType(jState) == JSON_TYPE_NULL)
        {
            jState = jDefault;
        }
        SetLocalJson(oModule, sLocalKey, jState);
        SetLocalInt(oModule, sInitializedKey, TRUE);
    }
    SetCampaignJson(MEMORIA_PERSIST_DATABASE, MEMORIA_PersistJsonKey(sNamespace, sStateId), jState, oPC);
    return jState;
}

int MEMORIA_PersistCommitJson(object oPC, string sNamespace, string sStateId, json jState)
{
    object oModule = GetModule();
    string sLocalKey = MEMORIA_PersistLocalJsonKey(sNamespace, sStateId);
    string sInitializedKey = MEMORIA_PersistLocalInitializedKey(sNamespace, sStateId);
    int bChanged = !GetLocalInt(oModule, sInitializedKey) || JsonDump(GetLocalJson(oModule, sLocalKey)) != JsonDump(jState);
    if (!bChanged)
    {
        return FALSE;
    }
    SetLocalJson(oModule, sLocalKey, jState);
    SetLocalInt(oModule, sInitializedKey, TRUE);
    SetCampaignJson(MEMORIA_PERSIST_DATABASE, MEMORIA_PersistJsonKey(sNamespace, sStateId), jState, oPC);
    return TRUE;
}

int MEMORIA_PersistStoreObject(object oPC, string sNamespace, string sSlot, object oObject, int bSaveState)
{
    if (!GetIsObjectValid(oObject))
    {
        return FALSE;
    }
    return StoreCampaignObject(MEMORIA_PERSIST_DATABASE, MEMORIA_PersistObjectKey(sNamespace, sSlot), oObject, oPC, bSaveState);
}

object MEMORIA_PersistRetrieveObject(object oPC, string sNamespace, string sSlot, location lLocation)
{
    return RetrieveCampaignObject(MEMORIA_PERSIST_DATABASE, MEMORIA_PersistObjectKey(sNamespace, sSlot), lLocation, oPC, oPC, FALSE);
}
