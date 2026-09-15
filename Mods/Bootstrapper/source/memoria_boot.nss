// Manifest-driven heartbeat loader for NWN:EE override mods.

const string M_BOOTSTRAPPER_MANIFEST_PREFIX = "memoria_";
const string M_BOOTSTRAPPER_DISCOVERY_LOCAL = "M_BOOTSTRAPPER_DISCOVERY";

void M_BOOTSTRAPPER_ReportError(object oPlayer, string sManifest, string sError)
{
    string sLocal = "M_BOOTSTRAPPER_ERR_" + sManifest;
    if (GetLocalString(oPlayer, sLocal) == sError) return;
    SetLocalString(oPlayer, sLocal, sError);
    SendMessageToPC(oPlayer, "Memoria Bootstrapper ignored " + sManifest + ".txt: " + sError);
}

void main()
{
    object oPlayer = OBJECT_SELF;
    if (!GetIsPC(oPlayer) || GetIsDM(oPlayer) || GetIsObjectValid(GetMaster(oPlayer)) || GetIsPossessedFamiliar(oPlayer)) return;

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

    string sDetected = "";
    int nIndex;
    for (nIndex = 0; nIndex < JsonGetLength(jEntries); nIndex++)
    {
        json jEntry = JsonArrayGet(jEntries, nIndex);
        string sHeartbeat = JsonGetString(JsonObjectGet(jEntry, "heartbeat"));
        string sId = JsonGetString(JsonObjectGet(jEntry, "id"));
        ExecuteScript(sHeartbeat, oPlayer);
        sDetected = sDetected == "" ? sId : sDetected + "," + sId;
    }
    if (GetLocalString(oPlayer, M_BOOTSTRAPPER_DISCOVERY_LOCAL) != sDetected)
    {
        SetLocalString(oPlayer, M_BOOTSTRAPPER_DISCOVERY_LOCAL, sDetected);
        SendMessageToPC(oPlayer, "Memoria Bootstrapper heartbeat modules: " + (sDetected == "" ? "none" : sDetected) + ".");
    }
}
