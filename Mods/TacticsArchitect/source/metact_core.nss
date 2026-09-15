// Tactics Architect (METACT) - persistent model, integration and party registry.
#include "esi_lib"
#include "memoria_core"
#include "memoria_group"
#include "memoria_item"
#include "memoria_locale"

const string METACT_VERSION = "0.7.0";
const string METACT_ESI_KEY = "7421";
const string METACT_LOCAL_DATABASE = "METACT_DATABASE_V1";
const string METACT_LOCAL_STORAGE_READY = "METACT_STORAGE_READY";
const string METACT_LOCAL_STORAGE_SYNCED = "METACT_STORAGE_SYNCED";
const string METACT_LOCAL_INSTALLED = "METACT_INSTALLED";
const string METACT_LOCAL_ESI_GUI = "METACT_ESI_GUI_INSTALLED";
const string METACT_LOCAL_ESI_TARGET = "METACT_ESI_TARGET_INSTALLED";
const string METACT_LOCAL_LANGUAGE = "METACT_LANGUAGE";
const string METACT_LOCAL_TEXT = "METACT_TEXT_RESULT";
const string METACT_LOCAL_IS_RUSSIAN = "METACT_LANGUAGE_IS_RUSSIAN";
const string METACT_LOCAL_GROUP_COUNT = "METACT_GROUP_COUNT";
const string METACT_LOCAL_GROUP_MEMBER = "METACT_GROUP_MEMBER_";
const string METACT_LOCAL_ACTOR = "METACT_UI_ACTOR";
const string METACT_LOCAL_SCOPE = "METACT_UI_SCOPE";
const string METACT_LOCAL_PROFILE = "METACT_UI_PROFILE";
const string METACT_LOCAL_TACTIC = "METACT_UI_TACTIC";
const string METACT_LOCAL_RULE = "METACT_UI_RULE";
const string METACT_LOCAL_PICKER = "METACT_UI_PICKER";
const string METACT_LOCAL_PICKER_MODE = "METACT_UI_PICKER_MODE";
const string METACT_LOCAL_PICKER_PAGE = "METACT_UI_PICKER_PAGE";
const string METACT_LOCAL_RULE_PAGE = "METACT_UI_RULE_PAGE";
const string METACT_LOCAL_PRIORITY = "METACT_UI_PRIORITY";
const string METACT_LOCAL_PRIORITY_TEMP = "METACT_UI_PRIORITY_TEMP";
const string METACT_LOCAL_PRIORITY_SCOPE = "METACT_UI_PRIORITY_SCOPE";
const string METACT_LOCAL_ACTION = "METACT_UI_ACTION";
const string METACT_LOCAL_ACTION_TEMP = "METACT_UI_ACTION_TEMP";
const string METACT_LOCAL_OWNED = "METACT_ACTION_OWNED";
const string METACT_LOCAL_OWNER = "METACT_ACTION_OWNER";
const string METACT_LOCAL_OWNED_TICKS = "METACT_ACTION_OWNED_TICKS";
const string METACT_LOCAL_MANUAL = "METACT_MANUAL_CONTROL";
const string METACT_LOCAL_LAST_LOCATION = "METACT_LAST_LOCATION";
const string METACT_LOCAL_DEBUG_TARGETING = "METACT_DEBUG_TARGETING";
const string METACT_LOCAL_DEBUG_LAST = "METACT_DEBUG_LAST";
const string METACT_LOCAL_FAILURE = "METACT_FAILURE";
const string METACT_LOCAL_REJECT_REASON = "METACT_REJECT_REASON";
const string METACT_LOCAL_MOTION_TICK = "METACT_MOTION_TICK";
const string METACT_LOCAL_MOTION_X = "METACT_MOTION_X";
const string METACT_LOCAL_MOTION_Y = "METACT_MOTION_Y";
const string METACT_LOCAL_MOTION_VX = "METACT_MOTION_VX";
const string METACT_LOCAL_MOTION_VY = "METACT_MOTION_VY";
const string METACT_LOCAL_MOTION_READY = "METACT_MOTION_READY";
const string METACT_LOCAL_MOTION_AREA = "METACT_MOTION_AREA";
const string METACT_LOCAL_DISPATCH_TICK = "METACT_DISPATCH_TICK";
const string METACT_LOCAL_ACTIVE_AOE = "METACT_ACTIVE_AOE";
const string METACT_LOCAL_ACTIVE_AOE_LOCATION = "METACT_ACTIVE_AOE_LOCATION";
const string METACT_LOCAL_ACTIVE_AOE_RADIUS = "METACT_ACTIVE_AOE_RADIUS";
const string METACT_LOCAL_ACTIVE_AOE_DELAY = "METACT_ACTIVE_AOE_DELAY";
const string METACT_LOCAL_ACTIVE_AOE_SPELL = "METACT_ACTIVE_AOE_SPELL";
const string METACT_LOCAL_ACTIVE_AOE_LEVEL = "METACT_ACTIVE_AOE_LEVEL";
const string METACT_LOCAL_ACTIVE_AOE_MINIMUM = "METACT_ACTIVE_AOE_MINIMUM";
const string METACT_LOCAL_AOE_CLEARANCE = "METACT_AOE_CLEARANCE";
const string METACT_LOCAL_ACTOR_TICK = "METACT_ACTOR_TICK";
const string METACT_LOCAL_BLOCKED_ITEM = "METACT_BLOCKED_ITEM";
const string METACT_LOCAL_BLOCKED_ITEM_UNTIL = "METACT_BLOCKED_ITEM_UNTIL";
const string METACT_PARAM_TEXT_KEY = "METACT_TEXT_KEY";

const int METACT_SCHEMA = 2;
const int METACT_MAX_GROUP = 32;
const int METACT_SCOPE_PC = 0;
const int METACT_SCOPE_EXACT = 1;
const int METACT_SCOPE_TYPE = 2;
const int METACT_PRIORITY_SCOPE_GLOBAL = 0;
const int METACT_PRIORITY_SCOPE_RULE = 1;
const int METACT_PRIORITY_SCOPE_ACTION = 2;
const float METACT_HEARTBEAT_SECONDS = 6.0f;
const float METACT_INTERVAL = 0.5f;
const int METACT_MAX_AOE_TARGETS = 16;
const int METACT_MAX_AOE_CANDIDATE_ENEMIES = 12;
const float METACT_AOE_PROJECTILE_SPEED = 20.0f;
const float METACT_AOE_ALLY_MARGIN = 0.75f;
const float METACT_AOE_ENGAGEMENT_DISTANCE = 2.0f;
const float METACT_AOE_STATIONARY_SPEED = 0.5f;
const int METACT_AOE_SAFETY_SAFE = 1;
const int METACT_AOE_SAFETY_VERY_SAFE = 2;
const int METACT_AOE_SAFETY_STATIONARY = 3;

const int METACT_TEXT_INSTALLED = 3;
const int METACT_TEXT_TITLE = 4;
const int METACT_TEXT_PROFILE = 5;
const int METACT_TEXT_SCOPE = 6;
const int METACT_TEXT_SCOPE_EXACT = 7;
const int METACT_TEXT_SCOPE_TYPE = 8;
const int METACT_TEXT_TACTIC = 9;
const int METACT_TEXT_NEW = 10;
const int METACT_TEXT_DELETE = 11;
const int METACT_TEXT_ENABLED = 12;
const int METACT_TEXT_TACTIC_NAME = 13;
const int METACT_TEXT_RENAME = 14;
const int METACT_TEXT_ACTION = 15;
const int METACT_TEXT_CONDITION = 16;
const int METACT_TEXT_UP = 17;
const int METACT_TEXT_DOWN = 18;
const int METACT_TEXT_EDIT = 19;
const int METACT_TEXT_ADD_RULE = 20;
const int METACT_TEXT_CLOSE = 21;
const int METACT_TEXT_RULE_EDITOR = 22;
const int METACT_TEXT_CHOOSE_ACTION = 23;
const int METACT_TEXT_CHOOSE_CONDITION = 24;
const int METACT_TEXT_ADVANCED = 25;
const int METACT_TEXT_ALLOW_MOVEMENT = 26;
const int METACT_TEXT_FRIENDLY_FIRE = 27;
const int METACT_TEXT_SOURCE = 28;
const int METACT_TEXT_SOURCE_ANY = 29;
const int METACT_TEXT_SOURCE_SPELL = 30;
const int METACT_TEXT_SOURCE_ITEM = 31;
const int METACT_TEXT_TARGET = 32;
const int METACT_TEXT_TARGET_AUTO = 33;
const int METACT_TEXT_TARGET_SELF = 34;
const int METACT_TEXT_TARGET_ENEMY = 35;
const int METACT_TEXT_TARGET_ALLY = 36;
const int METACT_TEXT_TARGET_CLUSTER = 37;
const int METACT_TEXT_COND_ALWAYS = 38;
const int METACT_TEXT_COND_ENEMIES = 39;
const int METACT_TEXT_COND_CLUSTER = 40;
const int METACT_TEXT_COND_SELF_HP = 41;
const int METACT_TEXT_COND_ALLY_HP = 42;
const int METACT_TEXT_COND_NO_SUMMON = 43;
const int METACT_TEXT_COND_NO_FAMILIAR = 44;
const int METACT_TEXT_THRESHOLD = 45;
const int METACT_TEXT_RADIUS = 46;
const int METACT_TEXT_SAVE = 47;
const int METACT_TEXT_CANCEL = 48;
const int METACT_TEXT_PICKER = 49;
const int METACT_TEXT_SEARCH = 50;
const int METACT_TEXT_PREVIOUS = 51;
const int METACT_TEXT_NEXT = 52;
const int METACT_TEXT_CHOOSE = 53;
const int METACT_TEXT_SUMMON_FAMILIAR = 54;
const int METACT_TEXT_BASIC_ATTACK = 55;
const int METACT_TEXT_SELECT_POWER = 56;
const int METACT_TEXT_UNCONFIGURED = 57;
const int METACT_TEXT_DEFAULT_TACTIC = 58;
const int METACT_TEXT_NO_RULES = 59;
const int METACT_TEXT_PROFILE_PC = 60;
const int METACT_TEXT_INVALID = 61;
const int METACT_TEXT_TARGET_ENEMY_LOW = 62;
const int METACT_TEXT_TARGET_ENEMY_HIGH = 63;
const int METACT_TEXT_COND_ENEMY_RATING_MIN = 64;
const int METACT_TEXT_COND_ENEMY_RATING_MAX = 65;
const int METACT_TEXT_TARGET_PRIORITIES = 66;
const int METACT_TEXT_ADD_PRIORITY = 67;
const int METACT_TEXT_PRIORITY_EDITOR = 68;
const int METACT_TEXT_PRIORITY_CASTER = 69;
const int METACT_TEXT_PRIORITY_RATING_HIGH = 70;
const int METACT_TEXT_PRIORITY_RATING_LOW = 71;
const int METACT_TEXT_PRIORITY_HEALTH_LOW = 72;
const int METACT_TEXT_PRIORITY_HEALTH_HIGH = 73;
const int METACT_TEXT_PRIORITY_DEFAULT = 74;
const int METACT_TEXT_PRIORITY_KIND = 75;
const int METACT_TEXT_RULES = 76;
const int METACT_TEXT_DEBUG = 77;
const int METACT_TEXT_INSPECT_TARGET = 78;
const int METACT_TEXT_INSPECT_PROMPT = 79;
const int METACT_TEXT_INSPECT_CANCELLED = 80;
const int METACT_TEXT_AREA_FROM_SPELL = 81;
const int METACT_TEXT_FRIENDLY_FIRE_UNRESTRICTED = 82;
const int METACT_TEXT_FRIENDLY_FIRE_PRECAST = 83;
const int METACT_TEXT_FRIENDLY_FIRE_DURING_CAST = 84;
const int METACT_TEXT_FRIENDLY_FIRE_STATIONARY = 85;
const int METACT_TEXT_ACTIONS = 86;
const int METACT_TEXT_GLOBAL_PRIORITIES = 88;
const int METACT_TEXT_LOCAL_PRIORITIES = 89;
const int METACT_TEXT_ACTION_EDITOR = 90;
const int METACT_TEXT_ADD_ACTION = 91;
const int METACT_TEXT_COND_ENEMY_RATING = 92;
const int METACT_TEXT_COMPARISON = 93;
const int METACT_TEXT_AT_LEAST = 94;
const int METACT_TEXT_AT_MOST = 95;
const int METACT_TEXT_COND_HEALTH = 96;
const int METACT_TEXT_SUBJECT = 97;
const int METACT_TEXT_SUBJECT_SELF = 98;
const int METACT_TEXT_SUBJECT_ALLY = 99;
const int METACT_TEXT_CLUSTER_HINT = 100;
const int METACT_TEXT_TARGET_BY_PRIORITIES = 101;
const int METACT_TEXT_NO_ACTIONS = 102;
const int METACT_TEXT_ACTION_PRIORITIES = 103;
const int METACT_TEXT_RULE_PRIORITY_FALLBACK = 104;
const int METACT_TEXT_ACTION_PRIORITY_FALLBACK = 105;
const int METACT_TEXT_FRIENDLY_FIRE_UNRESTRICTED_HELP = 106;
const int METACT_TEXT_FRIENDLY_FIRE_PRECAST_HELP = 107;
const int METACT_TEXT_FRIENDLY_FIRE_DURING_CAST_HELP = 108;
const int METACT_TEXT_FRIENDLY_FIRE_STATIONARY_HELP = 109;
const int METACT_TEXT_EQUIP_ITEM = 110;
const int METACT_TEXT_EQUIPPABLE_ITEMS = 111;

string METACT_GetLanguage(object oPC)
{
    return MEMORIA_GetLanguage(oPC, METACT_LOCAL_LANGUAGE, "metact_is_ru", METACT_LOCAL_IS_RUSSIAN);
}

string METACT_GetText(int iKey, object oPC)
{
    return MEMORIA_GetText(iKey, oPC, METACT_GetLanguage(oPC), "metact_txt_", METACT_LOCAL_TEXT, METACT_PARAM_TEXT_KEY);
}

json METACT_NewTactic(object oPC)
{
    json jTactic = JsonObject();
    jTactic = JsonObjectSet(jTactic, "name", JsonString(METACT_GetText(METACT_TEXT_DEFAULT_TACTIC, oPC)));
    jTactic = JsonObjectSet(jTactic, "enabled", JsonBool(TRUE));
    jTactic = JsonObjectSet(jTactic, "rules", JsonArray());
    jTactic = JsonObjectSet(jTactic, "target_priorities", JsonArray());
    return jTactic;
}

json METACT_NewDatabase()
{
    json jDatabase = JsonObject();
    jDatabase = JsonObjectSet(jDatabase, "version", JsonInt(METACT_SCHEMA));
    jDatabase = JsonObjectSet(jDatabase, "profiles", JsonArray());
    return jDatabase;
}

int METACT_EnsurePersistentStorage(object oPC)
{
    if (GetLocalInt(oPC, METACT_LOCAL_STORAGE_READY)) return TRUE;
    sqlquery qCreate = SqlPrepareQueryObject(oPC, "CREATE TABLE IF NOT EXISTS metact_state_74c2 (slot TEXT PRIMARY KEY, payload TEXT NOT NULL)");
    SqlStep(qCreate);
    if (SqlGetError(qCreate) != "") return FALSE;
    SetLocalInt(oPC, METACT_LOCAL_STORAGE_READY, TRUE);
    return TRUE;
}

json METACT_LoadPersistentDatabase(object oPC)
{
    if (!METACT_EnsurePersistentStorage(oPC)) return JsonNull();
    sqlquery qLoad = SqlPrepareQueryObject(oPC, "SELECT payload FROM metact_state_74c2 WHERE slot = 'database'");
    if (!SqlStep(qLoad)) return JsonNull();
    return SqlGetJson(qLoad, 0);
}

void METACT_WritePersistentDatabase(object oPC, json jDatabase)
{
    if (!METACT_EnsurePersistentStorage(oPC)) return;
    sqlquery qSave = SqlPrepareQueryObject(oPC, "INSERT OR REPLACE INTO metact_state_74c2 (slot, payload) VALUES ('database', @payload)");
    SqlBindJson(qSave, "@payload", jDatabase);
    SqlStep(qSave);
    if (SqlGetError(qSave) == "") SetLocalInt(oPC, METACT_LOCAL_STORAGE_SYNCED, TRUE);
}

json METACT_GetDatabase(object oPC)
{
    json jDatabase = GetLocalJson(oPC, METACT_LOCAL_DATABASE);
    if (JsonGetType(jDatabase) == JSON_TYPE_OBJECT && JsonGetInt(JsonObjectGet(jDatabase, "version")) == METACT_SCHEMA)
    {
        if (!GetLocalInt(oPC, METACT_LOCAL_STORAGE_SYNCED)) METACT_WritePersistentDatabase(oPC, jDatabase);
        return jDatabase;
    }
    jDatabase = METACT_LoadPersistentDatabase(oPC);
    if (JsonGetType(jDatabase) != JSON_TYPE_OBJECT || JsonGetInt(JsonObjectGet(jDatabase, "version")) != METACT_SCHEMA) jDatabase = METACT_NewDatabase();
    SetLocalJson(oPC, METACT_LOCAL_DATABASE, jDatabase);
    METACT_WritePersistentDatabase(oPC, jDatabase);
    return jDatabase;
}

void METACT_SaveDatabase(object oPC, json jDatabase)
{
    SetLocalJson(oPC, METACT_LOCAL_DATABASE, jDatabase);
    METACT_WritePersistentDatabase(oPC, jDatabase);
}

int METACT_GetDebugEnabled(object oPC)
{
    return JsonGetInt(JsonObjectGet(METACT_GetDatabase(oPC), "debug"));
}

void METACT_SetDebugEnabled(object oPC, int bEnabled)
{
    METACT_SaveDatabase(oPC, JsonObjectSet(METACT_GetDatabase(oPC), "debug", JsonBool(bEnabled)));
    if (!bEnabled) DeleteLocalString(oPC, METACT_LOCAL_DEBUG_LAST);
}

int METACT_GetRelativeEnemyRating(object oActor, object oEnemy)
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

json METACT_GetProfiles(object oPC)
{
    return JsonObjectGet(METACT_GetDatabase(oPC), "profiles");
}

json METACT_GetProfile(object oPC, int iProfile)
{
    return JsonArrayGet(METACT_GetProfiles(oPC), iProfile);
}

void METACT_SetProfile(object oPC, int iProfile, json jProfile)
{
    json jDatabase = METACT_GetDatabase(oPC);
    json jProfiles = JsonArraySet(JsonObjectGet(jDatabase, "profiles"), iProfile, jProfile);
    METACT_SaveDatabase(oPC, JsonObjectSet(jDatabase, "profiles", jProfiles));
}

string METACT_GetProfileKey(object oActor, int iScope)
{
    if (iScope == METACT_SCOPE_PC)
        return "pc";
    if (iScope == METACT_SCOPE_TYPE)
        return GetResRef(oActor);
    string sUUID = GetObjectUUID(oActor);
    if (sUUID == "")
    {
        ForceRefreshObjectUUID(oActor);
        sUUID = GetObjectUUID(oActor);
    }
    return sUUID;
}

int METACT_FindProfile(object oPC, int iScope, string sKey)
{
    json jProfiles = METACT_GetProfiles(oPC);
    int iIndex;
    for (iIndex = 0; iIndex < JsonGetLength(jProfiles); iIndex++)
    {
        json jProfile = JsonArrayGet(jProfiles, iIndex);
        if (JsonGetInt(JsonObjectGet(jProfile, "scope")) == iScope && JsonGetString(JsonObjectGet(jProfile, "key")) == sKey)
            return iIndex;
    }
    return -1;
}

int METACT_EnsureProfile(object oPC, object oActor, int iScope)
{
    if (oActor == oPC)
        iScope = METACT_SCOPE_PC;
    string sKey = METACT_GetProfileKey(oActor, iScope);
    int iProfile = METACT_FindProfile(oPC, iScope, sKey);
    if (iProfile >= 0)
        return iProfile;
    json jProfile = JsonObject();
    jProfile = JsonObjectSet(jProfile, "scope", JsonInt(iScope));
    jProfile = JsonObjectSet(jProfile, "key", JsonString(sKey));
    jProfile = JsonObjectSet(jProfile, "label", JsonString(oActor == oPC ? METACT_GetText(METACT_TEXT_PROFILE_PC, oPC) : GetName(oActor)));
    jProfile = JsonObjectSet(jProfile, "active", JsonInt(0));
    jProfile = JsonObjectSet(jProfile, "tactics", JsonArrayInsert(JsonArray(), METACT_NewTactic(oPC)));
    json jDatabase = METACT_GetDatabase(oPC);
    json jProfiles = JsonArrayInsert(JsonObjectGet(jDatabase, "profiles"), jProfile);
    METACT_SaveDatabase(oPC, JsonObjectSet(jDatabase, "profiles", jProfiles));
    return JsonGetLength(jProfiles) - 1;
}

int METACT_FindRuntimeProfile(object oPC, object oActor)
{
    if (oActor == oPC)
        return METACT_FindProfile(oPC, METACT_SCOPE_PC, "pc");
    int iProfile = METACT_FindProfile(oPC, METACT_SCOPE_EXACT, METACT_GetProfileKey(oActor, METACT_SCOPE_EXACT));
    if (iProfile >= 0)
        return iProfile;
    return METACT_FindProfile(oPC, METACT_SCOPE_TYPE, GetResRef(oActor));
}

object METACT_GetGroupMember(object oPC, int iIndex)
{
    return MEMORIA_GetGroupMember(oPC, METACT_LOCAL_GROUP_MEMBER, iIndex);
}

int METACT_GetGroupCount(object oPC)
{
    return MEMORIA_GetGroupCount(oPC, METACT_LOCAL_GROUP_COUNT);
}

int METACT_IsGroupCreature(object oCreature, object oPC)
{
    return MEMORIA_IsPartyCreature(oCreature, oPC);
}

int METACT_IsGroupCached(object oPC, object oCreature)
{
    return MEMORIA_IsGroupMemberCached(oPC, oCreature, METACT_LOCAL_GROUP_COUNT, METACT_LOCAL_GROUP_MEMBER);
}

void METACT_AddGroupMember(object oPC, object oCreature)
{
    MEMORIA_AddGroupMember(oPC, oCreature, METACT_LOCAL_GROUP_COUNT, METACT_LOCAL_GROUP_MEMBER, METACT_MAX_GROUP);
}

void METACT_BuildGroupCache(object oPC)
{
    MEMORIA_BuildGroupCache(oPC, METACT_LOCAL_GROUP_COUNT, METACT_LOCAL_GROUP_MEMBER, METACT_MAX_GROUP);
}

void METACT_InstallHook()
{
    object oModule = GetModule();
    if (!GetLocalInt(oModule, METACT_LOCAL_ESI_GUI) && ESI_InjectToObject(oModule, METACT_ESI_KEY, EVENT_SCRIPT_MODULE_ON_PLAYER_GUIEVENT, "metact_guievt", ESI_INJECTION_PLACEMENT_FIRST))
        SetLocalInt(oModule, METACT_LOCAL_ESI_GUI, TRUE);
    if (!GetLocalInt(oModule, METACT_LOCAL_ESI_TARGET) && ESI_InjectToObject(oModule, METACT_ESI_KEY, EVENT_SCRIPT_MODULE_ON_PLAYER_TARGET, "metact_target", ESI_INJECTION_PLACEMENT_FIRST))
        SetLocalInt(oModule, METACT_LOCAL_ESI_TARGET, TRUE);
}
