// Tactics Architect (METACT) - persistent model, integration and party registry.
#include "esi_lib"
#include "memoria_core"
#include "memoria_group"
#include "memoria_item"
#include "memoria_locale"
#include "memoria_loc"

const string METACT_VERSION = "0.7.1";
const string METACT_LOC_PREFIX = "metact";
const string METACT_ESI_KEY_GUI = "metact.module.gui";
const string METACT_ESI_KEY_TARGET = "metact.module.target";
const string METACT_LOCAL_DATABASE = "METACT_DATABASE_V1";
const string METACT_LOCAL_STORAGE_READY = "METACT_STORAGE_READY";
const string METACT_LOCAL_STORAGE_SYNCED = "METACT_STORAGE_SYNCED";
const string METACT_LOCAL_INSTALLED = "METACT_INSTALLED";
const string METACT_LOCAL_LANGUAGE = "METACT_LANGUAGE";
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

const string METACT_TEXT_INSTALLED = "installed";
const string METACT_TEXT_TITLE = "title";
const string METACT_TEXT_PROFILE = "profile";
const string METACT_TEXT_SCOPE = "scope";
const string METACT_TEXT_SCOPE_EXACT = "scope_exact";
const string METACT_TEXT_SCOPE_TYPE = "scope_type";
const string METACT_TEXT_TACTIC = "tactic";
const string METACT_TEXT_NEW = "new";
const string METACT_TEXT_DELETE = "delete";
const string METACT_TEXT_ENABLED = "enabled";
const string METACT_TEXT_TACTIC_NAME = "tactic_name";
const string METACT_TEXT_RENAME = "rename";
const string METACT_TEXT_ACTION = "action";
const string METACT_TEXT_CONDITION = "condition";
const string METACT_TEXT_UP = "up";
const string METACT_TEXT_DOWN = "down";
const string METACT_TEXT_EDIT = "edit";
const string METACT_TEXT_ADD_RULE = "add_rule";
const string METACT_TEXT_CLOSE = "close";
const string METACT_TEXT_RULE_EDITOR = "rule_editor";
const string METACT_TEXT_CHOOSE_ACTION = "choose_action";
const string METACT_TEXT_CHOOSE_CONDITION = "choose_condition";
const string METACT_TEXT_ADVANCED = "advanced";
const string METACT_TEXT_ALLOW_MOVEMENT = "allow_movement";
const string METACT_TEXT_FRIENDLY_FIRE = "friendly_fire";
const string METACT_TEXT_SOURCE = "source";
const string METACT_TEXT_SOURCE_ANY = "source_any";
const string METACT_TEXT_SOURCE_SPELL = "source_spell";
const string METACT_TEXT_SOURCE_ITEM = "source_item";
const string METACT_TEXT_TARGET = "target";
const string METACT_TEXT_TARGET_AUTO = "target_auto";
const string METACT_TEXT_TARGET_SELF = "target_self";
const string METACT_TEXT_TARGET_ENEMY = "target_enemy";
const string METACT_TEXT_TARGET_ALLY = "target_ally";
const string METACT_TEXT_TARGET_CLUSTER = "target_cluster";
const string METACT_TEXT_COND_ALWAYS = "cond_always";
const string METACT_TEXT_COND_ENEMIES = "cond_enemies";
const string METACT_TEXT_COND_CLUSTER = "cond_cluster";
const string METACT_TEXT_COND_SELF_HP = "cond_self_hp";
const string METACT_TEXT_COND_ALLY_HP = "cond_ally_hp";
const string METACT_TEXT_COND_NO_SUMMON = "cond_no_summon";
const string METACT_TEXT_COND_NO_FAMILIAR = "cond_no_familiar";
const string METACT_TEXT_THRESHOLD = "threshold";
const string METACT_TEXT_RADIUS = "radius";
const string METACT_TEXT_SAVE = "save";
const string METACT_TEXT_CANCEL = "cancel";
const string METACT_TEXT_PICKER = "picker";
const string METACT_TEXT_SEARCH = "search";
const string METACT_TEXT_PREVIOUS = "previous";
const string METACT_TEXT_NEXT = "next";
const string METACT_TEXT_CHOOSE = "choose";
const string METACT_TEXT_SUMMON_FAMILIAR = "summon_familiar";
const string METACT_TEXT_BASIC_ATTACK = "basic_attack";
const string METACT_TEXT_SELECT_POWER = "select_power";
const string METACT_TEXT_UNCONFIGURED = "unconfigured";
const string METACT_TEXT_DEFAULT_TACTIC = "default_tactic";
const string METACT_TEXT_NO_RULES = "no_rules";
const string METACT_TEXT_PROFILE_PC = "profile_pc";
const string METACT_TEXT_INVALID = "invalid";
const string METACT_TEXT_TARGET_ENEMY_LOW = "target_enemy_low";
const string METACT_TEXT_TARGET_ENEMY_HIGH = "target_enemy_high";
const string METACT_TEXT_COND_ENEMY_RATING_MIN = "cond_enemy_rating_min";
const string METACT_TEXT_COND_ENEMY_RATING_MAX = "cond_enemy_rating_max";
const string METACT_TEXT_TARGET_PRIORITIES = "target_priorities";
const string METACT_TEXT_ADD_PRIORITY = "add_priority";
const string METACT_TEXT_PRIORITY_EDITOR = "priority_editor";
const string METACT_TEXT_PRIORITY_CASTER = "priority_caster";
const string METACT_TEXT_PRIORITY_RATING_HIGH = "priority_rating_high";
const string METACT_TEXT_PRIORITY_RATING_LOW = "priority_rating_low";
const string METACT_TEXT_PRIORITY_HEALTH_LOW = "priority_health_low";
const string METACT_TEXT_PRIORITY_HEALTH_HIGH = "priority_health_high";
const string METACT_TEXT_PRIORITY_DEFAULT = "priority_default";
const string METACT_TEXT_PRIORITY_KIND = "priority_kind";
const string METACT_TEXT_RULES = "rules";
const string METACT_TEXT_DEBUG = "debug";
const string METACT_TEXT_INSPECT_TARGET = "inspect_target";
const string METACT_TEXT_INSPECT_PROMPT = "inspect_prompt";
const string METACT_TEXT_INSPECT_CANCELLED = "inspect_cancelled";
const string METACT_TEXT_AREA_FROM_SPELL = "area_from_spell";
const string METACT_TEXT_FRIENDLY_FIRE_UNRESTRICTED = "friendly_fire_unrestricted";
const string METACT_TEXT_FRIENDLY_FIRE_PRECAST = "friendly_fire_precast";
const string METACT_TEXT_FRIENDLY_FIRE_DURING_CAST = "friendly_fire_during_cast";
const string METACT_TEXT_FRIENDLY_FIRE_STATIONARY = "friendly_fire_stationary";
const string METACT_TEXT_ACTIONS = "actions";
const string METACT_TEXT_GLOBAL_PRIORITIES = "global_priorities";
const string METACT_TEXT_LOCAL_PRIORITIES = "local_priorities";
const string METACT_TEXT_ACTION_EDITOR = "action_editor";
const string METACT_TEXT_ADD_ACTION = "add_action";
const string METACT_TEXT_COND_ENEMY_RATING = "cond_enemy_rating";
const string METACT_TEXT_COMPARISON = "comparison";
const string METACT_TEXT_AT_LEAST = "at_least";
const string METACT_TEXT_AT_MOST = "at_most";
const string METACT_TEXT_COND_HEALTH = "cond_health";
const string METACT_TEXT_SUBJECT = "subject";
const string METACT_TEXT_SUBJECT_SELF = "subject_self";
const string METACT_TEXT_SUBJECT_ALLY = "subject_ally";
const string METACT_TEXT_CLUSTER_HINT = "cluster_hint";
const string METACT_TEXT_TARGET_BY_PRIORITIES = "target_by_priorities";
const string METACT_TEXT_NO_ACTIONS = "no_actions";
const string METACT_TEXT_ACTION_PRIORITIES = "action_priorities";
const string METACT_TEXT_RULE_PRIORITY_FALLBACK = "rule_priority_fallback";
const string METACT_TEXT_ACTION_PRIORITY_FALLBACK = "action_priority_fallback";
const string METACT_TEXT_FRIENDLY_FIRE_UNRESTRICTED_HELP = "friendly_fire_unrestricted_help";
const string METACT_TEXT_FRIENDLY_FIRE_PRECAST_HELP = "friendly_fire_precast_help";
const string METACT_TEXT_FRIENDLY_FIRE_DURING_CAST_HELP = "friendly_fire_during_cast_help";
const string METACT_TEXT_FRIENDLY_FIRE_STATIONARY_HELP = "friendly_fire_stationary_help";
const string METACT_TEXT_EQUIP_ITEM = "equip_item";
const string METACT_TEXT_EQUIPPABLE_ITEMS = "equippable_items";
const string METACT_TEXT_ABILITIES = "abilities";

string METACT_GetLanguage(object oPC)
{
    return MEMORIA_GetLanguage(oPC, METACT_LOCAL_LANGUAGE);
}

string METACT_GetText(string sKey, object oPC)
{
    return MEMORIA_LOC_GetText(METACT_LOC_PREFIX, METACT_GetLanguage(oPC), sKey);
}

string METACT_GetFriendlyFireHelpKey(int iPolicy)
{
    return iPolicy == METACT_AOE_SAFETY_SAFE ? METACT_TEXT_FRIENDLY_FIRE_PRECAST_HELP
         : iPolicy == METACT_AOE_SAFETY_VERY_SAFE ? METACT_TEXT_FRIENDLY_FIRE_DURING_CAST_HELP
         : iPolicy == METACT_AOE_SAFETY_STATIONARY ? METACT_TEXT_FRIENDLY_FIRE_STATIONARY_HELP
         : METACT_TEXT_FRIENDLY_FIRE_UNRESTRICTED_HELP;
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
    ESI_InjectToObject(oModule, METACT_ESI_KEY_GUI, EVENT_SCRIPT_MODULE_ON_PLAYER_GUIEVENT, "metact_guievt", ESI_INJECTION_PLACEMENT_FIRST);
    ESI_InjectToObject(oModule, METACT_ESI_KEY_TARGET, EVENT_SCRIPT_MODULE_ON_PLAYER_TARGET, "metact_target", ESI_INJECTION_PLACEMENT_FIRST);
}
