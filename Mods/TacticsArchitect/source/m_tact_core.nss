// Tactics Architect (M_TACT) - persistent model, integration and party registry.
#include "esi_lib"
#include "memoria_core"
#include "memoria_group"
#include "memoria_item"
#include "memoria_locale"

const string M_TACT_VERSION = "0.7.0";
const string M_TACT_ITEM_RESREF = "m_tact_modeitem";
const string M_TACT_ITEM_TAG = "M_TACT_TACTICS_ARCHITECT_74C2";
const string M_TACT_ACTIVATE_HANDLER = "m_tact_evact";
const string M_TACT_ESI_KEY = "7421";
const string M_TACT_LOCAL_DATABASE = "M_TACT_DATABASE_V1";
const string M_TACT_LOCAL_STORAGE_READY = "M_TACT_STORAGE_READY";
const string M_TACT_LOCAL_STORAGE_SYNCED = "M_TACT_STORAGE_SYNCED";
const string M_TACT_LOCAL_INSTALLED = "M_TACT_INSTALLED";
const string M_TACT_LOCAL_ESI = "M_TACT_ESI_INSTALLED";
const string M_TACT_LOCAL_ESI_GUI = "M_TACT_ESI_GUI_INSTALLED";
const string M_TACT_LOCAL_ESI_TARGET = "M_TACT_ESI_TARGET_INSTALLED";
const string M_TACT_LOCAL_ITEM_SCHEMA = "M_TACT_ITEM_SCHEMA";
const string M_TACT_LOCAL_ITEM_LANGUAGE = "M_TACT_ITEM_LANGUAGE";
const string M_TACT_LOCAL_LANGUAGE = "M_TACT_LANGUAGE";
const string M_TACT_LOCAL_TEXT = "M_TACT_TEXT_RESULT";
const string M_TACT_LOCAL_IS_RUSSIAN = "M_TACT_LANGUAGE_IS_RUSSIAN";
const string M_TACT_LOCAL_GROUP_COUNT = "M_TACT_GROUP_COUNT";
const string M_TACT_LOCAL_GROUP_MEMBER = "M_TACT_GROUP_MEMBER_";
const string M_TACT_LOCAL_ACTOR = "M_TACT_UI_ACTOR";
const string M_TACT_LOCAL_SCOPE = "M_TACT_UI_SCOPE";
const string M_TACT_LOCAL_PROFILE = "M_TACT_UI_PROFILE";
const string M_TACT_LOCAL_TACTIC = "M_TACT_UI_TACTIC";
const string M_TACT_LOCAL_RULE = "M_TACT_UI_RULE";
const string M_TACT_LOCAL_PICKER = "M_TACT_UI_PICKER";
const string M_TACT_LOCAL_PICKER_MODE = "M_TACT_UI_PICKER_MODE";
const string M_TACT_LOCAL_PICKER_PAGE = "M_TACT_UI_PICKER_PAGE";
const string M_TACT_LOCAL_RULE_PAGE = "M_TACT_UI_RULE_PAGE";
const string M_TACT_LOCAL_PRIORITY = "M_TACT_UI_PRIORITY";
const string M_TACT_LOCAL_PRIORITY_TEMP = "M_TACT_UI_PRIORITY_TEMP";
const string M_TACT_LOCAL_PRIORITY_SCOPE = "M_TACT_UI_PRIORITY_SCOPE";
const string M_TACT_LOCAL_ACTION = "M_TACT_UI_ACTION";
const string M_TACT_LOCAL_ACTION_TEMP = "M_TACT_UI_ACTION_TEMP";
const string M_TACT_LOCAL_OWNED = "M_TACT_ACTION_OWNED";
const string M_TACT_LOCAL_OWNER = "M_TACT_ACTION_OWNER";
const string M_TACT_LOCAL_OWNED_TICKS = "M_TACT_ACTION_OWNED_TICKS";
const string M_TACT_LOCAL_MANUAL = "M_TACT_MANUAL_CONTROL";
const string M_TACT_LOCAL_LAST_LOCATION = "M_TACT_LAST_LOCATION";
const string M_TACT_LOCAL_DEBUG_TARGETING = "M_TACT_DEBUG_TARGETING";
const string M_TACT_LOCAL_DEBUG_LAST = "M_TACT_DEBUG_LAST";
const string M_TACT_LOCAL_FAILURE = "M_TACT_FAILURE";
const string M_TACT_LOCAL_REJECT_REASON = "M_TACT_REJECT_REASON";
const string M_TACT_LOCAL_MOTION_TICK = "M_TACT_MOTION_TICK";
const string M_TACT_LOCAL_MOTION_X = "M_TACT_MOTION_X";
const string M_TACT_LOCAL_MOTION_Y = "M_TACT_MOTION_Y";
const string M_TACT_LOCAL_MOTION_VX = "M_TACT_MOTION_VX";
const string M_TACT_LOCAL_MOTION_VY = "M_TACT_MOTION_VY";
const string M_TACT_LOCAL_MOTION_READY = "M_TACT_MOTION_READY";
const string M_TACT_LOCAL_MOTION_AREA = "M_TACT_MOTION_AREA";
const string M_TACT_LOCAL_DISPATCH_TICK = "M_TACT_DISPATCH_TICK";
const string M_TACT_LOCAL_ACTIVE_AOE = "M_TACT_ACTIVE_AOE";
const string M_TACT_LOCAL_ACTIVE_AOE_LOCATION = "M_TACT_ACTIVE_AOE_LOCATION";
const string M_TACT_LOCAL_ACTIVE_AOE_RADIUS = "M_TACT_ACTIVE_AOE_RADIUS";
const string M_TACT_LOCAL_ACTIVE_AOE_DELAY = "M_TACT_ACTIVE_AOE_DELAY";
const string M_TACT_LOCAL_ACTIVE_AOE_SPELL = "M_TACT_ACTIVE_AOE_SPELL";
const string M_TACT_LOCAL_ACTIVE_AOE_LEVEL = "M_TACT_ACTIVE_AOE_LEVEL";
const string M_TACT_LOCAL_ACTIVE_AOE_MINIMUM = "M_TACT_ACTIVE_AOE_MINIMUM";
const string M_TACT_LOCAL_AOE_CLEARANCE = "M_TACT_AOE_CLEARANCE";
const string M_TACT_LOCAL_ACTOR_TICK = "M_TACT_ACTOR_TICK";
const string M_TACT_LOCAL_BLOCKED_ITEM = "M_TACT_BLOCKED_ITEM";
const string M_TACT_LOCAL_BLOCKED_ITEM_UNTIL = "M_TACT_BLOCKED_ITEM_UNTIL";
const string M_TACT_PARAM_TEXT_KEY = "M_TACT_TEXT_KEY";

const int M_TACT_SCHEMA = 2;
const int M_TACT_ITEM_SCHEMA = 1;
const int M_TACT_MAX_GROUP = 32;
const int M_TACT_SCOPE_PC = 0;
const int M_TACT_SCOPE_EXACT = 1;
const int M_TACT_SCOPE_TYPE = 2;
const int M_TACT_PRIORITY_SCOPE_GLOBAL = 0;
const int M_TACT_PRIORITY_SCOPE_RULE = 1;
const int M_TACT_PRIORITY_SCOPE_ACTION = 2;
const float M_TACT_HEARTBEAT_SECONDS = 6.0f;
const float M_TACT_INTERVAL = 0.5f;
const int M_TACT_MAX_AOE_TARGETS = 16;
const int M_TACT_MAX_AOE_CANDIDATE_ENEMIES = 12;
const float M_TACT_AOE_PROJECTILE_SPEED = 20.0f;
const float M_TACT_AOE_ALLY_MARGIN = 0.75f;
const float M_TACT_AOE_ENGAGEMENT_DISTANCE = 2.0f;
const float M_TACT_AOE_STATIONARY_SPEED = 0.5f;
const int M_TACT_AOE_SAFETY_SAFE = 1;
const int M_TACT_AOE_SAFETY_VERY_SAFE = 2;
const int M_TACT_AOE_SAFETY_STATIONARY = 3;

const int M_TACT_TEXT_ITEM_NAME = 1;
const int M_TACT_TEXT_ITEM_DESCRIPTION = 2;
const int M_TACT_TEXT_INSTALLED = 3;
const int M_TACT_TEXT_TITLE = 4;
const int M_TACT_TEXT_PROFILE = 5;
const int M_TACT_TEXT_SCOPE = 6;
const int M_TACT_TEXT_SCOPE_EXACT = 7;
const int M_TACT_TEXT_SCOPE_TYPE = 8;
const int M_TACT_TEXT_TACTIC = 9;
const int M_TACT_TEXT_NEW = 10;
const int M_TACT_TEXT_DELETE = 11;
const int M_TACT_TEXT_ENABLED = 12;
const int M_TACT_TEXT_TACTIC_NAME = 13;
const int M_TACT_TEXT_RENAME = 14;
const int M_TACT_TEXT_ACTION = 15;
const int M_TACT_TEXT_CONDITION = 16;
const int M_TACT_TEXT_UP = 17;
const int M_TACT_TEXT_DOWN = 18;
const int M_TACT_TEXT_EDIT = 19;
const int M_TACT_TEXT_ADD_RULE = 20;
const int M_TACT_TEXT_CLOSE = 21;
const int M_TACT_TEXT_RULE_EDITOR = 22;
const int M_TACT_TEXT_CHOOSE_ACTION = 23;
const int M_TACT_TEXT_CHOOSE_CONDITION = 24;
const int M_TACT_TEXT_ADVANCED = 25;
const int M_TACT_TEXT_ALLOW_MOVEMENT = 26;
const int M_TACT_TEXT_FRIENDLY_FIRE = 27;
const int M_TACT_TEXT_SOURCE = 28;
const int M_TACT_TEXT_SOURCE_ANY = 29;
const int M_TACT_TEXT_SOURCE_SPELL = 30;
const int M_TACT_TEXT_SOURCE_ITEM = 31;
const int M_TACT_TEXT_TARGET = 32;
const int M_TACT_TEXT_TARGET_AUTO = 33;
const int M_TACT_TEXT_TARGET_SELF = 34;
const int M_TACT_TEXT_TARGET_ENEMY = 35;
const int M_TACT_TEXT_TARGET_ALLY = 36;
const int M_TACT_TEXT_TARGET_CLUSTER = 37;
const int M_TACT_TEXT_COND_ALWAYS = 38;
const int M_TACT_TEXT_COND_ENEMIES = 39;
const int M_TACT_TEXT_COND_CLUSTER = 40;
const int M_TACT_TEXT_COND_SELF_HP = 41;
const int M_TACT_TEXT_COND_ALLY_HP = 42;
const int M_TACT_TEXT_COND_NO_SUMMON = 43;
const int M_TACT_TEXT_COND_NO_FAMILIAR = 44;
const int M_TACT_TEXT_THRESHOLD = 45;
const int M_TACT_TEXT_RADIUS = 46;
const int M_TACT_TEXT_SAVE = 47;
const int M_TACT_TEXT_CANCEL = 48;
const int M_TACT_TEXT_PICKER = 49;
const int M_TACT_TEXT_SEARCH = 50;
const int M_TACT_TEXT_PREVIOUS = 51;
const int M_TACT_TEXT_NEXT = 52;
const int M_TACT_TEXT_CHOOSE = 53;
const int M_TACT_TEXT_SUMMON_FAMILIAR = 54;
const int M_TACT_TEXT_BASIC_ATTACK = 55;
const int M_TACT_TEXT_SELECT_POWER = 56;
const int M_TACT_TEXT_UNCONFIGURED = 57;
const int M_TACT_TEXT_DEFAULT_TACTIC = 58;
const int M_TACT_TEXT_NO_RULES = 59;
const int M_TACT_TEXT_PROFILE_PC = 60;
const int M_TACT_TEXT_INVALID = 61;
const int M_TACT_TEXT_TARGET_ENEMY_LOW = 62;
const int M_TACT_TEXT_TARGET_ENEMY_HIGH = 63;
const int M_TACT_TEXT_COND_ENEMY_RATING_MIN = 64;
const int M_TACT_TEXT_COND_ENEMY_RATING_MAX = 65;
const int M_TACT_TEXT_TARGET_PRIORITIES = 66;
const int M_TACT_TEXT_ADD_PRIORITY = 67;
const int M_TACT_TEXT_PRIORITY_EDITOR = 68;
const int M_TACT_TEXT_PRIORITY_CASTER = 69;
const int M_TACT_TEXT_PRIORITY_RATING_HIGH = 70;
const int M_TACT_TEXT_PRIORITY_RATING_LOW = 71;
const int M_TACT_TEXT_PRIORITY_HEALTH_LOW = 72;
const int M_TACT_TEXT_PRIORITY_HEALTH_HIGH = 73;
const int M_TACT_TEXT_PRIORITY_DEFAULT = 74;
const int M_TACT_TEXT_PRIORITY_KIND = 75;
const int M_TACT_TEXT_RULES = 76;
const int M_TACT_TEXT_DEBUG = 77;
const int M_TACT_TEXT_INSPECT_TARGET = 78;
const int M_TACT_TEXT_INSPECT_PROMPT = 79;
const int M_TACT_TEXT_INSPECT_CANCELLED = 80;
const int M_TACT_TEXT_AREA_FROM_SPELL = 81;
const int M_TACT_TEXT_FRIENDLY_FIRE_UNRESTRICTED = 82;
const int M_TACT_TEXT_FRIENDLY_FIRE_PRECAST = 83;
const int M_TACT_TEXT_FRIENDLY_FIRE_DURING_CAST = 84;
const int M_TACT_TEXT_FRIENDLY_FIRE_STATIONARY = 85;
const int M_TACT_TEXT_ACTIONS = 86;
const int M_TACT_TEXT_GLOBAL_PRIORITIES = 88;
const int M_TACT_TEXT_LOCAL_PRIORITIES = 89;
const int M_TACT_TEXT_ACTION_EDITOR = 90;
const int M_TACT_TEXT_ADD_ACTION = 91;
const int M_TACT_TEXT_COND_ENEMY_RATING = 92;
const int M_TACT_TEXT_COMPARISON = 93;
const int M_TACT_TEXT_AT_LEAST = 94;
const int M_TACT_TEXT_AT_MOST = 95;
const int M_TACT_TEXT_COND_HEALTH = 96;
const int M_TACT_TEXT_SUBJECT = 97;
const int M_TACT_TEXT_SUBJECT_SELF = 98;
const int M_TACT_TEXT_SUBJECT_ALLY = 99;
const int M_TACT_TEXT_CLUSTER_HINT = 100;
const int M_TACT_TEXT_TARGET_BY_PRIORITIES = 101;
const int M_TACT_TEXT_NO_ACTIONS = 102;
const int M_TACT_TEXT_ACTION_PRIORITIES = 103;
const int M_TACT_TEXT_RULE_PRIORITY_FALLBACK = 104;
const int M_TACT_TEXT_ACTION_PRIORITY_FALLBACK = 105;
const int M_TACT_TEXT_FRIENDLY_FIRE_UNRESTRICTED_HELP = 106;
const int M_TACT_TEXT_FRIENDLY_FIRE_PRECAST_HELP = 107;
const int M_TACT_TEXT_FRIENDLY_FIRE_DURING_CAST_HELP = 108;
const int M_TACT_TEXT_FRIENDLY_FIRE_STATIONARY_HELP = 109;
const int M_TACT_TEXT_EQUIP_ITEM = 110;
const int M_TACT_TEXT_EQUIPPABLE_ITEMS = 111;

string M_TACT_GetLanguage(object oPC)
{
    return MEMORIA_GetLanguage(oPC, M_TACT_LOCAL_LANGUAGE, "m_tact_is_ru", M_TACT_LOCAL_IS_RUSSIAN);
}

string M_TACT_GetText(int iKey, object oPC)
{
    return MEMORIA_GetText(iKey, oPC, M_TACT_GetLanguage(oPC), "m_tact_txt_", M_TACT_LOCAL_TEXT, M_TACT_PARAM_TEXT_KEY);
}

json M_TACT_NewTactic(object oPC)
{
    json jTactic = JsonObject();
    jTactic = JsonObjectSet(jTactic, "name", JsonString(M_TACT_GetText(M_TACT_TEXT_DEFAULT_TACTIC, oPC)));
    jTactic = JsonObjectSet(jTactic, "enabled", JsonBool(TRUE));
    jTactic = JsonObjectSet(jTactic, "rules", JsonArray());
    jTactic = JsonObjectSet(jTactic, "target_priorities", JsonArray());
    return jTactic;
}

json M_TACT_NewDatabase()
{
    json jDatabase = JsonObject();
    jDatabase = JsonObjectSet(jDatabase, "version", JsonInt(M_TACT_SCHEMA));
    jDatabase = JsonObjectSet(jDatabase, "profiles", JsonArray());
    return jDatabase;
}

int M_TACT_EnsurePersistentStorage(object oPC)
{
    if (GetLocalInt(oPC, M_TACT_LOCAL_STORAGE_READY)) return TRUE;
    sqlquery qCreate = SqlPrepareQueryObject(oPC, "CREATE TABLE IF NOT EXISTS m_tact_state_74c2 (slot TEXT PRIMARY KEY, payload TEXT NOT NULL)");
    SqlStep(qCreate);
    if (SqlGetError(qCreate) != "") return FALSE;
    SetLocalInt(oPC, M_TACT_LOCAL_STORAGE_READY, TRUE);
    return TRUE;
}

json M_TACT_LoadPersistentDatabase(object oPC)
{
    if (!M_TACT_EnsurePersistentStorage(oPC)) return JsonNull();
    sqlquery qLoad = SqlPrepareQueryObject(oPC, "SELECT payload FROM m_tact_state_74c2 WHERE slot = 'database'");
    if (!SqlStep(qLoad)) return JsonNull();
    return SqlGetJson(qLoad, 0);
}

void M_TACT_WritePersistentDatabase(object oPC, json jDatabase)
{
    if (!M_TACT_EnsurePersistentStorage(oPC)) return;
    sqlquery qSave = SqlPrepareQueryObject(oPC, "INSERT OR REPLACE INTO m_tact_state_74c2 (slot, payload) VALUES ('database', @payload)");
    SqlBindJson(qSave, "@payload", jDatabase);
    SqlStep(qSave);
    if (SqlGetError(qSave) == "") SetLocalInt(oPC, M_TACT_LOCAL_STORAGE_SYNCED, TRUE);
}

json M_TACT_GetDatabase(object oPC)
{
    json jDatabase = GetLocalJson(oPC, M_TACT_LOCAL_DATABASE);
    if (JsonGetType(jDatabase) == JSON_TYPE_OBJECT && JsonGetInt(JsonObjectGet(jDatabase, "version")) == M_TACT_SCHEMA)
    {
        if (!GetLocalInt(oPC, M_TACT_LOCAL_STORAGE_SYNCED)) M_TACT_WritePersistentDatabase(oPC, jDatabase);
        return jDatabase;
    }
    jDatabase = M_TACT_LoadPersistentDatabase(oPC);
    if (JsonGetType(jDatabase) != JSON_TYPE_OBJECT || JsonGetInt(JsonObjectGet(jDatabase, "version")) != M_TACT_SCHEMA) jDatabase = M_TACT_NewDatabase();
    SetLocalJson(oPC, M_TACT_LOCAL_DATABASE, jDatabase);
    M_TACT_WritePersistentDatabase(oPC, jDatabase);
    return jDatabase;
}

void M_TACT_SaveDatabase(object oPC, json jDatabase)
{
    SetLocalJson(oPC, M_TACT_LOCAL_DATABASE, jDatabase);
    M_TACT_WritePersistentDatabase(oPC, jDatabase);
}

int M_TACT_GetDebugEnabled(object oPC)
{
    return JsonGetInt(JsonObjectGet(M_TACT_GetDatabase(oPC), "debug"));
}

void M_TACT_SetDebugEnabled(object oPC, int bEnabled)
{
    M_TACT_SaveDatabase(oPC, JsonObjectSet(M_TACT_GetDatabase(oPC), "debug", JsonBool(bEnabled)));
    if (!bEnabled) DeleteLocalString(oPC, M_TACT_LOCAL_DEBUG_LAST);
}

int M_TACT_GetRelativeEnemyRating(object oActor, object oEnemy)
{
    float fDifference = GetChallengeRating(oEnemy) - IntToFloat(GetHitDice(oActor));
    if (fDifference <= -6.0f) return 0;
    if (fDifference <= -4.0f) return 1;
    if (fDifference <= -2.0f) return 2;
    if (fDifference <= 0.0f) return 3;
    if (fDifference <= 2.0f) return 4;
    if (fDifference <= 4.0f) return 5;
    return 6;
}

json M_TACT_GetProfiles(object oPC)
{
    return JsonObjectGet(M_TACT_GetDatabase(oPC), "profiles");
}

json M_TACT_GetProfile(object oPC, int iProfile)
{
    return JsonArrayGet(M_TACT_GetProfiles(oPC), iProfile);
}

void M_TACT_SetProfile(object oPC, int iProfile, json jProfile)
{
    json jDatabase = M_TACT_GetDatabase(oPC);
    json jProfiles = JsonArraySet(JsonObjectGet(jDatabase, "profiles"), iProfile, jProfile);
    M_TACT_SaveDatabase(oPC, JsonObjectSet(jDatabase, "profiles", jProfiles));
}

string M_TACT_GetProfileKey(object oActor, int iScope)
{
    if (iScope == M_TACT_SCOPE_PC)
        return "pc";
    if (iScope == M_TACT_SCOPE_TYPE)
        return GetResRef(oActor);
    string sUUID = GetObjectUUID(oActor);
    if (sUUID == "")
    {
        ForceRefreshObjectUUID(oActor);
        sUUID = GetObjectUUID(oActor);
    }
    return sUUID;
}

int M_TACT_FindProfile(object oPC, int iScope, string sKey)
{
    json jProfiles = M_TACT_GetProfiles(oPC);
    int iIndex;
    for (iIndex = 0; iIndex < JsonGetLength(jProfiles); iIndex++)
    {
        json jProfile = JsonArrayGet(jProfiles, iIndex);
        if (JsonGetInt(JsonObjectGet(jProfile, "scope")) == iScope && JsonGetString(JsonObjectGet(jProfile, "key")) == sKey)
            return iIndex;
    }
    return -1;
}

int M_TACT_EnsureProfile(object oPC, object oActor, int iScope)
{
    if (oActor == oPC)
        iScope = M_TACT_SCOPE_PC;
    string sKey = M_TACT_GetProfileKey(oActor, iScope);
    int iProfile = M_TACT_FindProfile(oPC, iScope, sKey);
    if (iProfile >= 0)
        return iProfile;
    json jProfile = JsonObject();
    jProfile = JsonObjectSet(jProfile, "scope", JsonInt(iScope));
    jProfile = JsonObjectSet(jProfile, "key", JsonString(sKey));
    jProfile = JsonObjectSet(jProfile, "label", JsonString(oActor == oPC ? M_TACT_GetText(M_TACT_TEXT_PROFILE_PC, oPC) : GetName(oActor)));
    jProfile = JsonObjectSet(jProfile, "active", JsonInt(0));
    jProfile = JsonObjectSet(jProfile, "tactics", JsonArrayInsert(JsonArray(), M_TACT_NewTactic(oPC)));
    json jDatabase = M_TACT_GetDatabase(oPC);
    json jProfiles = JsonArrayInsert(JsonObjectGet(jDatabase, "profiles"), jProfile);
    M_TACT_SaveDatabase(oPC, JsonObjectSet(jDatabase, "profiles", jProfiles));
    return JsonGetLength(jProfiles) - 1;
}

int M_TACT_FindRuntimeProfile(object oPC, object oActor)
{
    if (oActor == oPC)
        return M_TACT_FindProfile(oPC, M_TACT_SCOPE_PC, "pc");
    int iProfile = M_TACT_FindProfile(oPC, M_TACT_SCOPE_EXACT, M_TACT_GetProfileKey(oActor, M_TACT_SCOPE_EXACT));
    if (iProfile >= 0)
        return iProfile;
    return M_TACT_FindProfile(oPC, M_TACT_SCOPE_TYPE, GetResRef(oActor));
}

object M_TACT_GetGroupMember(object oPC, int iIndex)
{
    return MEMORIA_GetGroupMember(oPC, M_TACT_LOCAL_GROUP_MEMBER, iIndex);
}

int M_TACT_GetGroupCount(object oPC)
{
    return MEMORIA_GetGroupCount(oPC, M_TACT_LOCAL_GROUP_COUNT);
}

int M_TACT_IsGroupCreature(object oCreature, object oPC)
{
    return MEMORIA_IsPartyCreature(oCreature, oPC);
}

int M_TACT_IsGroupCached(object oPC, object oCreature)
{
    return MEMORIA_IsGroupMemberCached(oPC, oCreature, M_TACT_LOCAL_GROUP_COUNT, M_TACT_LOCAL_GROUP_MEMBER);
}

void M_TACT_AddGroupMember(object oPC, object oCreature)
{
    MEMORIA_AddGroupMember(oPC, oCreature, M_TACT_LOCAL_GROUP_COUNT, M_TACT_LOCAL_GROUP_MEMBER, M_TACT_MAX_GROUP);
}

void M_TACT_BuildGroupCache(object oPC)
{
    MEMORIA_BuildGroupCache(oPC, M_TACT_LOCAL_GROUP_COUNT, M_TACT_LOCAL_GROUP_MEMBER, M_TACT_MAX_GROUP);
}

void M_TACT_LocalizeItem(object oItem, object oPC)
{
    SetName(oItem, M_TACT_GetText(M_TACT_TEXT_ITEM_NAME, oPC));
    SetDescription(oItem, M_TACT_GetText(M_TACT_TEXT_ITEM_DESCRIPTION, oPC), TRUE);
    SetDescription(oItem, M_TACT_GetText(M_TACT_TEXT_ITEM_DESCRIPTION, oPC), FALSE);
    SetLocalString(oItem, M_TACT_LOCAL_ITEM_LANGUAGE, M_TACT_GetLanguage(oPC));
}

void M_TACT_EnsureItem(object oPC)
{
    object oItem = GetItemPossessedBy(oPC, M_TACT_ITEM_TAG);
    if (GetIsObjectValid(oItem) && GetLocalInt(oItem, M_TACT_LOCAL_ITEM_SCHEMA) != M_TACT_ITEM_SCHEMA)
    {
        DestroyObject(oItem);
        oItem = OBJECT_INVALID;
    }
    if (!GetIsObjectValid(oItem))
        oItem = CreateItemOnObject(M_TACT_ITEM_RESREF, oPC, 1, M_TACT_ITEM_TAG);
    if (GetIsObjectValid(oItem))
    {
        SetLocalInt(oItem, M_TACT_LOCAL_ITEM_SCHEMA, M_TACT_ITEM_SCHEMA);
        SetPlotFlag(oItem, TRUE);
        SetItemCursedFlag(oItem, TRUE);
        if (GetLocalString(oItem, M_TACT_LOCAL_ITEM_LANGUAGE) != M_TACT_GetLanguage(oPC))
            M_TACT_LocalizeItem(oItem, oPC);
    }
}

void M_TACT_InstallHook()
{
    object oModule = GetModule();
    if (!GetLocalInt(oModule, M_TACT_LOCAL_ESI) && ESI_InjectToObject(oModule, M_TACT_ESI_KEY, EVENT_SCRIPT_MODULE_ON_ACTIVATE_ITEM, M_TACT_ACTIVATE_HANDLER, ESI_INJECTION_PLACEMENT_FIRST))
        SetLocalInt(oModule, M_TACT_LOCAL_ESI, TRUE);
    if (!GetLocalInt(oModule, M_TACT_LOCAL_ESI_GUI) && ESI_InjectToObject(oModule, M_TACT_ESI_KEY, EVENT_SCRIPT_MODULE_ON_PLAYER_GUIEVENT, "m_tact_guievt", ESI_INJECTION_PLACEMENT_FIRST))
        SetLocalInt(oModule, M_TACT_LOCAL_ESI_GUI, TRUE);
    if (!GetLocalInt(oModule, M_TACT_LOCAL_ESI_TARGET) && ESI_InjectToObject(oModule, M_TACT_ESI_KEY, EVENT_SCRIPT_MODULE_ON_PLAYER_TARGET, "m_tact_target", ESI_INJECTION_PLACEMENT_FIRST))
        SetLocalInt(oModule, M_TACT_LOCAL_ESI_TARGET, TRUE);
}
