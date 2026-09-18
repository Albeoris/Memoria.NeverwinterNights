#include "metact_picker"
#include "metact_meta"
#include "memoria_nui"
#include "nw_inc_nui"

const string METACT_WINDOW_MAIN = "metact_main_74c2";
const string METACT_WINDOW_RULE = "metact_rule_74c2";
const string METACT_WINDOW_PICKER = "metact_pick_74c2";
const string METACT_WINDOW_PRIORITY = "metact_priority_74c2";
const string METACT_WINDOW_ACTION = "metact_action_74c2";
const string METACT_LOCAL_RULE_TEMP = "METACT_UI_RULE_TEMP";
const string METACT_LOCAL_PICKER_FILTERED = "METACT_UI_PICK_FILTER";
const string METACT_LOCAL_ACTION_HIDDEN = "METACT_UI_ACTION_HIDDEN";
const int METACT_RULE_PAGE_SIZE = 20;
const int METACT_TARGET_AUTO = 0;
const int METACT_TARGET_SELF = 1;
const int METACT_TARGET_ENEMY = 2;
const int METACT_TARGET_ALLY = 3;
const int METACT_TARGET_CLUSTER = 4;
const int METACT_TARGET_ENEMY_LOW = 5;
const int METACT_TARGET_ENEMY_HIGH = 6;
const float METACT_NUI_SCROLLBAR_SIZE = 16.0f;
const float METACT_NUI_WINDOW_HORIZONTAL_INSET = 24.0f;
const float METACT_NUI_WINDOW_VERTICAL_INSET = 49.0f;
const float METACT_NUI_GROUP_INSET = 8.0f;

float METACT_GetWindowWidth(object oPC)
{
    int iWidth = GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_WIDTH);
    int iScale = GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_SCALE);
    if (iWidth <= 0 || iScale <= 0) return 1100.0f;
    return IntToFloat(iWidth) * 90.0f / IntToFloat(iScale);
}

float METACT_GetWindowHeight(object oPC)
{
    int iHeight = GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_HEIGHT);
    int iScale = GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_SCALE);
    if (iHeight <= 0 || iScale <= 0) return 650.0f;
    return IntToFloat(iHeight) * 90.0f / IntToFloat(iScale);
}

json METACT_Label(string sText)
{
    return NuiLabel(JsonString(sText), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_MIDDLE));
}

json METACT_Header(string sText)
{
    return NuiStyleForegroundColor(NuiLabel(JsonString(sText), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE)), NuiColor(225, 190, 95));
}

json METACT_IconButton(string sIcon, string sId, string sTooltip)
{
    return MEMORIA_NUI_Help(NuiId(NuiButtonImage(JsonString(sIcon)), sId), JsonString(sTooltip));
}

json METACT_ComboEntries2(object oPC, string sKeyA, string sKeyB)
{
    json jEntries = JsonArray();
    jEntries = JsonArrayInsert(jEntries, NuiComboEntry(METACT_GetText(sKeyA, oPC), 0));
    return JsonArrayInsert(jEntries, NuiComboEntry(METACT_GetText(sKeyB, oPC), 1));
}

json METACT_ComboEntries3(object oPC, string sKeyA, string sKeyB, string sKeyC)
{
    json jEntries = METACT_ComboEntries2(oPC, sKeyA, sKeyB);
    return JsonArrayInsert(jEntries, NuiComboEntry(METACT_GetText(sKeyC, oPC), 2));
}

json METACT_ComboEntries4(object oPC, string sKeyA, string sKeyB, string sKeyC, string sKeyD)
{
    json jEntries = METACT_ComboEntries3(oPC, sKeyA, sKeyB, sKeyC);
    return JsonArrayInsert(jEntries, NuiComboEntry(METACT_GetText(sKeyD, oPC), 3));
}

json METACT_ConditionEntries(object oPC)
{
    json jEntries = JsonArray();
    jEntries = JsonArrayInsert(jEntries, NuiComboEntry(METACT_GetText(METACT_TEXT_COND_ALWAYS, oPC), 0));
    jEntries = JsonArrayInsert(jEntries, NuiComboEntry(METACT_GetText(METACT_TEXT_COND_ENEMIES, oPC), 1));
    jEntries = JsonArrayInsert(jEntries, NuiComboEntry(METACT_GetText(METACT_TEXT_COND_CLUSTER, oPC), 2));
    jEntries = JsonArrayInsert(jEntries, NuiComboEntry(METACT_GetText(METACT_TEXT_COND_HEALTH, oPC), 3));
    jEntries = JsonArrayInsert(jEntries, NuiComboEntry(METACT_GetText(METACT_TEXT_COND_NO_SUMMON, oPC), 4));
    jEntries = JsonArrayInsert(jEntries, NuiComboEntry(METACT_GetText(METACT_TEXT_COND_NO_FAMILIAR, oPC), 5));
    return JsonArrayInsert(jEntries, NuiComboEntry(METACT_GetText(METACT_TEXT_COND_ENEMY_RATING, oPC), 6));
}

json METACT_RatingEntries()
{
    json jEntries = JsonArray();
    int iRating;
    for (iRating = 0; iRating <= 6; iRating++) jEntries = JsonArrayInsert(jEntries, NuiComboEntry(GetStringByStrRef(6416 + iRating), iRating));
    return jEntries;
}

json METACT_FriendlyFirePolicyEntries(object oPC)
{
    return METACT_ComboEntries4(oPC, METACT_TEXT_FRIENDLY_FIRE_UNRESTRICTED, METACT_TEXT_FRIENDLY_FIRE_PRECAST, METACT_TEXT_FRIENDLY_FIRE_DURING_CAST, METACT_TEXT_FRIENDLY_FIRE_STATIONARY);
}

json METACT_NewAction()
{
    json jAction = JsonObject();
    jAction = JsonObjectSet(jAction, "enabled", JsonBool(TRUE));
    jAction = JsonObjectSet(jAction, "kind", JsonString(""));
    jAction = JsonObjectSet(jAction, "spell", JsonInt(-1));
    jAction = JsonObjectSet(jAction, "feat", JsonInt(-1));
    jAction = JsonObjectSet(jAction, "feat_name", JsonString(""));
    jAction = JsonObjectSet(jAction, "feat_icon", JsonString(""));
    jAction = JsonObjectSet(jAction, "feat_target_self", JsonBool(FALSE));
    jAction = JsonObjectSet(jAction, "class", JsonInt(CLASS_TYPE_INVALID));
    jAction = JsonObjectSet(jAction, "level", JsonInt(-1));
    jAction = JsonObjectSet(jAction, "metamagic", JsonInt(METAMAGIC_NONE));
    jAction = JsonObjectSet(jAction, "domain", JsonInt(0));
    jAction = JsonObjectSet(jAction, "source", JsonString("any"));
    jAction = JsonObjectSet(jAction, "item_resref", JsonString(""));
    jAction = JsonObjectSet(jAction, "item_uuid", JsonString(""));
    jAction = JsonObjectSet(jAction, "item_name", JsonString(""));
    jAction = JsonObjectSet(jAction, "item_icon", JsonString(""));
    jAction = JsonObjectSet(jAction, "item_property", JsonInt(-1));
    jAction = JsonObjectSet(jAction, "target", JsonString("auto"));
    jAction = JsonObjectSet(jAction, "move", JsonBool(TRUE));
    jAction = JsonObjectSet(jAction, "friendly_fire", JsonBool(FALSE));
    jAction = JsonObjectSet(jAction, "aoe_safety", JsonInt(METACT_AOE_SAFETY_SAFE));
    jAction = JsonObjectSet(jAction, "target_priorities", JsonArray());
    return jAction;
}

json METACT_NewRule()
{
    json jCondition = JsonObject();
    jCondition = JsonObjectSet(jCondition, "kind", JsonString("always"));
    jCondition = JsonObjectSet(jCondition, "value", JsonInt(1));
    jCondition = JsonObjectSet(jCondition, "radius", JsonFloat(20.0f));
    jCondition = JsonObjectSet(jCondition, "subject", JsonString("self"));
    jCondition = JsonObjectSet(jCondition, "comparison", JsonString("min"));
    json jRule = JsonObject();
    jRule = JsonObjectSet(jRule, "enabled", JsonBool(TRUE));
    jRule = JsonObjectSet(jRule, "condition", jCondition);
    jRule = JsonObjectSet(jRule, "actions", JsonArray());
    jRule = JsonObjectSet(jRule, "target_priorities", JsonArray());
    return jRule;
}

string METACT_PriorityKindFromIndex(int iKind)
{
    return iKind == 0 ? "caster" : iKind == 1 ? "attacker" : iKind == 2 ? "rating" : "health";
}

int METACT_PriorityKindToIndex(string sKind)
{
    return sKind == "caster" ? 0 : sKind == "attacker" ? 1 : sKind == "rating" || sKind == "rating_high" || sKind == "rating_low" ? 2 : 3;
}

string METACT_PriorityCategory(string sKind)
{
    if (sKind == "rating_high" || sKind == "rating_low") return "rating";
    if (sKind == "health_high" || sKind == "health_low") return "health";
    return sKind;
}

int METACT_HasPriorityKind(json jPriorities, string sKind, int iExcept)
{
    int iIndex;
    for (iIndex = 0; iIndex < JsonGetLength(jPriorities); iIndex++)
    {
        json jPriority = JsonArrayGet(jPriorities, iIndex);
        if (iIndex != iExcept && METACT_PriorityCategory(JsonGetString(JsonObjectGet(jPriority, "kind"))) == METACT_PriorityCategory(sKind)) return TRUE;
    }
    return FALSE;
}

json METACT_NewPriority(json jPriorities)
{
    if (JsonGetType(jPriorities) != JSON_TYPE_ARRAY) jPriorities = JsonArray();
    int iKind;
    for (iKind = 0; iKind < 4 && METACT_HasPriorityKind(jPriorities, METACT_PriorityKindFromIndex(iKind), -1); iKind++);
    if (iKind >= 4) iKind = 0;
    json jPriority = JsonObject();
    jPriority = JsonObjectSet(jPriority, "kind", JsonString(METACT_PriorityKindFromIndex(iKind)));
    jPriority = JsonObjectSet(jPriority, "comparison", JsonString(iKind == 3 ? "max" : "min"));
    jPriority = JsonObjectSet(jPriority, "value", JsonInt(iKind == 3 ? 50 : 3));
    jPriority = JsonObjectSet(jPriority, "subject", JsonString("pc"));
    jPriority = JsonObjectSet(jPriority, "subject_name", JsonString(""));
    return JsonObjectSet(jPriority, "enabled", JsonBool(TRUE));
}

string METACT_PriorityLabel(object oPC, json jPriority)
{
    string sKind = JsonGetString(JsonObjectGet(jPriority, "kind"));
    if (sKind == "rating_high") return METACT_GetText(METACT_TEXT_PRIORITY_RATING_HIGH, oPC);
    if (sKind == "rating_low") return METACT_GetText(METACT_TEXT_PRIORITY_RATING_LOW, oPC);
    if (sKind == "health_high") return METACT_GetText(METACT_TEXT_PRIORITY_HEALTH_HIGH, oPC);
    if (sKind == "health_low") return METACT_GetText(METACT_TEXT_PRIORITY_HEALTH_LOW, oPC);
    if (sKind == "caster") return METACT_GetText(METACT_TEXT_PRIORITY_CASTER, oPC);
    if (sKind == "attacker")
    {
        string sName = JsonGetString(JsonObjectGet(jPriority, "subject")) == "pc" ? METACT_GetText(METACT_TEXT_PROFILE_PC, oPC) : JsonGetString(JsonObjectGet(jPriority, "subject_name"));
        return METACT_GetText(METACT_TEXT_PRIORITY_ATTACKER, oPC) + ": " + sName;
    }
    string sComparison = METACT_GetText(JsonGetString(JsonObjectGet(jPriority, "comparison")) == "max" ? METACT_TEXT_AT_MOST : METACT_TEXT_AT_LEAST, oPC);
    int iValue = JsonGetInt(JsonObjectGet(jPriority, "value"));
    if (sKind == "rating") return METACT_GetText(METACT_TEXT_PRIORITY_RATING, oPC) + ": " + sComparison + " " + GetStringByStrRef(6416 + iValue);
    return METACT_GetText(METACT_TEXT_PRIORITY_HEALTH, oPC) + ": " + sComparison + " " + IntToString(iValue) + "%";
}

json METACT_PriorityEntries(object oPC)
{
    json jEntries = JsonArray();
    jEntries = JsonArrayInsert(jEntries, NuiComboEntry(METACT_GetText(METACT_TEXT_PRIORITY_CASTER, oPC), 0));
    jEntries = JsonArrayInsert(jEntries, NuiComboEntry(METACT_GetText(METACT_TEXT_PRIORITY_ATTACKER, oPC), 1));
    jEntries = JsonArrayInsert(jEntries, NuiComboEntry(METACT_GetText(METACT_TEXT_PRIORITY_RATING, oPC), 2));
    jEntries = JsonArrayInsert(jEntries, NuiComboEntry(METACT_GetText(METACT_TEXT_PRIORITY_HEALTH, oPC), 3));
    return jEntries;
}

json METACT_PriorityTargetEntries(object oPC)
{
    json jEntries = JsonArrayInsert(JsonArray(), NuiComboEntry(METACT_GetText(METACT_TEXT_PROFILE_PC, oPC), 0));
    int iIndex;
    for (iIndex = 1; iIndex <= METACT_GetGroupCount(oPC); iIndex++)
    {
        object oMember = METACT_GetGroupMember(oPC, iIndex);
        if (GetIsObjectValid(oMember) && oMember != oPC)
            jEntries = JsonArrayInsert(jEntries, NuiComboEntry(GetName(oMember), iIndex));
    }
    return jEntries;
}

int METACT_GetPriorityTargetIndex(object oPC, json jPriority)
{
    string sSubject = JsonGetString(JsonObjectGet(jPriority, "subject"));
    if (sSubject == "pc" || sSubject == "")
        return 0;
    int iIndex;
    for (iIndex = 1; iIndex <= METACT_GetGroupCount(oPC); iIndex++)
    {
        object oMember = METACT_GetGroupMember(oPC, iIndex);
        if (GetIsObjectValid(oMember) && GetObjectUUID(oMember) == sSubject)
            return iIndex;
    }
    return 0;
}

json METACT_GetSelectedProfile(object oPC)
{
    return METACT_GetProfile(oPC, GetLocalInt(oPC, METACT_LOCAL_PROFILE));
}

json METACT_GetSelectedTactic(object oPC)
{
    return JsonArrayGet(JsonObjectGet(METACT_GetSelectedProfile(oPC), "tactics"), GetLocalInt(oPC, METACT_LOCAL_TACTIC));
}

void METACT_SaveSelectedTactic(object oPC, json jTactic)
{
    int iProfile = GetLocalInt(oPC, METACT_LOCAL_PROFILE);
    int iTactic = GetLocalInt(oPC, METACT_LOCAL_TACTIC);
    json jProfile = METACT_GetProfile(oPC, iProfile);
    json jTactics = JsonArraySet(JsonObjectGet(jProfile, "tactics"), iTactic, jTactic);
    jProfile = JsonObjectSet(jProfile, "tactics", jTactics);
    jProfile = JsonObjectSet(jProfile, "active", JsonInt(iTactic));
    METACT_SetProfile(oPC, iProfile, jProfile);
}

json METACT_GetSelectedRule(object oPC)
{
    json jRules = JsonObjectGet(METACT_GetSelectedTactic(oPC), "rules");
    int iRule = GetLocalInt(oPC, METACT_LOCAL_RULE);
    return iRule >= 0 && iRule < JsonGetLength(jRules) ? JsonArrayGet(jRules, iRule) : JsonNull();
}

void METACT_SaveSelectedRule(object oPC, json jRule)
{
    json jTactic = METACT_GetSelectedTactic(oPC);
    json jRules = JsonObjectGet(jTactic, "rules");
    int iRule = GetLocalInt(oPC, METACT_LOCAL_RULE);
    if (iRule < 0 || iRule >= JsonGetLength(jRules)) return;
    METACT_SaveSelectedTactic(oPC, JsonObjectSet(jTactic, "rules", JsonArraySet(jRules, iRule, jRule)));
}

json METACT_GetPrioritiesForScope(object oPC, int iScope)
{
    json jOwner = iScope == METACT_PRIORITY_SCOPE_ACTION ? GetLocalJson(oPC, METACT_LOCAL_ACTION_TEMP) : iScope == METACT_PRIORITY_SCOPE_RULE ? GetLocalJson(oPC, METACT_LOCAL_RULE_TEMP) : METACT_GetSelectedTactic(oPC);
    json jPriorities = JsonObjectGet(jOwner, "target_priorities");
    return JsonGetType(jPriorities) == JSON_TYPE_ARRAY ? jPriorities : JsonArray();
}

json METACT_GetEditablePriorities(object oPC)
{
    return METACT_GetPrioritiesForScope(oPC, GetLocalInt(oPC, METACT_LOCAL_PRIORITY_SCOPE));
}

void METACT_SaveEditablePriorities(object oPC, json jPriorities)
{
    int iScope = GetLocalInt(oPC, METACT_LOCAL_PRIORITY_SCOPE);
    if (iScope == METACT_PRIORITY_SCOPE_ACTION) SetLocalJson(oPC, METACT_LOCAL_ACTION_TEMP, JsonObjectSet(GetLocalJson(oPC, METACT_LOCAL_ACTION_TEMP), "target_priorities", jPriorities));
    else if (iScope == METACT_PRIORITY_SCOPE_RULE) SetLocalJson(oPC, METACT_LOCAL_RULE_TEMP, JsonObjectSet(GetLocalJson(oPC, METACT_LOCAL_RULE_TEMP), "target_priorities", jPriorities));
    else METACT_SaveSelectedTactic(oPC, JsonObjectSet(METACT_GetSelectedTactic(oPC), "target_priorities", jPriorities));
}

string METACT_ActionLabel(object oPC, json jAction)
{
    string sKind = JsonGetString(JsonObjectGet(jAction, "kind"));
    if (sKind == "spell") return MEMORIA_GetSpellName(JsonGetInt(JsonObjectGet(jAction, "spell")));
    if (sKind == "feat") return JsonGetString(JsonObjectGet(jAction, "feat_name"));
    if (sKind == "equip") return METACT_GetText(METACT_TEXT_EQUIP_ITEM, oPC) + ": " + JsonGetString(JsonObjectGet(jAction, "item_name"));
    if (sKind == "familiar") return METACT_GetText(METACT_TEXT_SUMMON_FAMILIAR, oPC);
    if (sKind == "attack") return METACT_GetText(METACT_TEXT_BASIC_ATTACK, oPC);
    return METACT_GetText(METACT_TEXT_UNCONFIGURED, oPC);
}

string METACT_ActionIcon(json jAction)
{
    string sKind = JsonGetString(JsonObjectGet(jAction, "kind"));
    if (sKind == "spell") return METACT_GetSpellIcon(JsonGetInt(JsonObjectGet(jAction, "spell")));
    if (sKind == "feat") return JsonGetString(JsonObjectGet(jAction, "feat_icon"));
    if (sKind == "equip")
    {
        string sIcon = JsonGetString(JsonObjectGet(jAction, "item_icon"));
        return sIcon == "" ? "ir_equip_r" : sIcon;
    }
    if (sKind == "familiar") return "ife_familiar";
    if (sKind == "attack") return "ir_attack";
    return "nui_test";
}

string METACT_ConditionLabel(object oPC, json jCondition)
{
    string sKind = JsonGetString(JsonObjectGet(jCondition, "kind"));
    int iValue = JsonGetInt(JsonObjectGet(jCondition, "value"));
    if (sKind == "always" || sKind == "") return METACT_GetText(METACT_TEXT_COND_ALWAYS, oPC);
    if (sKind == "enemies") return METACT_GetText(METACT_TEXT_COND_ENEMIES, oPC) + " >= " + IntToString(iValue);
    if (sKind == "cluster") return METACT_GetText(METACT_TEXT_COND_CLUSTER, oPC) + " >= " + IntToString(iValue);
    if (sKind == "health") return METACT_GetText(JsonGetString(JsonObjectGet(jCondition, "subject")) == "ally" ? METACT_TEXT_COND_ALLY_HP : METACT_TEXT_COND_SELF_HP, oPC) + " " + IntToString(iValue) + "%";
    if (sKind == "no_summon") return METACT_GetText(METACT_TEXT_COND_NO_SUMMON, oPC);
    if (sKind == "no_familiar") return METACT_GetText(METACT_TEXT_COND_NO_FAMILIAR, oPC);
    if (sKind == "enemy_rating") return METACT_GetText(JsonGetString(JsonObjectGet(jCondition, "comparison")) == "max" ? METACT_TEXT_COND_ENEMY_RATING_MAX : METACT_TEXT_COND_ENEMY_RATING_MIN, oPC) + ": " + GetStringByStrRef(6416 + iValue);
    return METACT_GetText(METACT_TEXT_INVALID, oPC);
}

json METACT_BuildRulesPanel(object oPC, float fHeight)
{
    json jPanel = JsonArray();
    jPanel = JsonArrayInsert(jPanel, NuiHeight(METACT_Header(METACT_GetText(METACT_TEXT_RULES, oPC)), 24.0f));
    json jRuleTemplate = JsonArray();
    jRuleTemplate = JsonArrayInsert(jRuleTemplate, NuiListTemplateCell(MEMORIA_NUI_Help(NuiId(NuiButtonSelect(NuiBind("rule_summary"), NuiBind("rule_selected")), "rule_select"), NuiBind("rule_tooltip")), 0.0f, TRUE));
    jRuleTemplate = JsonArrayInsert(jRuleTemplate, NuiListTemplateCell(METACT_IconButton("ir_action", "rule_edit", METACT_GetText(METACT_TEXT_EDIT, oPC)), 28.0f, FALSE));
    jRuleTemplate = JsonArrayInsert(jRuleTemplate, NuiListTemplateCell(METACT_IconButton("gui_spl_btn_up", "rule_up", METACT_GetText(METACT_TEXT_UP, oPC)), 28.0f, FALSE));
    jRuleTemplate = JsonArrayInsert(jRuleTemplate, NuiListTemplateCell(METACT_IconButton("gui_spl_btn_down", "rule_down", METACT_GetText(METACT_TEXT_DOWN, oPC)), 28.0f, FALSE));
    jPanel = JsonArrayInsert(jPanel, NuiHeight(NuiList(jRuleTemplate, NuiBind("rule_count"), 32.0f, TRUE, NUI_SCROLLBARS_Y), fHeight - 54.0f));
    json jBottom = JsonArray();
    jBottom = JsonArrayInsert(jBottom, NuiWidth(MEMORIA_NUI_Help(NuiId(NuiButton(JsonString("+")), "rule_add"), JsonString(METACT_GetText(METACT_TEXT_ADD_RULE, oPC))), 30.0f));
    jBottom = JsonArrayInsert(jBottom, NuiSpacer());
    jPanel = JsonArrayInsert(jPanel, NuiHeight(NuiRow(jBottom), 30.0f));
    return NuiCol(jPanel);
}

json METACT_BuildActionsPanel(object oPC, float fHeight)
{
    json jPanel = JsonArray();
    jPanel = JsonArrayInsert(jPanel, NuiHeight(METACT_Header(METACT_GetText(METACT_TEXT_ACTIONS, oPC)), 24.0f));
    json jActionTemplate = JsonArray();
    jActionTemplate = JsonArrayInsert(jActionTemplate, NuiListTemplateCell(MEMORIA_NUI_Help(NuiId(NuiButton(NuiBind("action_summary")), "action_edit"), NuiBind("action_tooltip")), 0.0f, TRUE));
    jActionTemplate = JsonArrayInsert(jActionTemplate, NuiListTemplateCell(METACT_IconButton("gui_spl_btn_up", "action_up", METACT_GetText(METACT_TEXT_UP, oPC)), 28.0f, FALSE));
    jActionTemplate = JsonArrayInsert(jActionTemplate, NuiListTemplateCell(METACT_IconButton("gui_spl_btn_down", "action_down", METACT_GetText(METACT_TEXT_DOWN, oPC)), 28.0f, FALSE));
    jPanel = JsonArrayInsert(jPanel, NuiHeight(NuiList(jActionTemplate, NuiBind("action_count"), 32.0f, TRUE, NUI_SCROLLBARS_Y), fHeight - 54.0f));
    json jBottom = JsonArray();
    jBottom = JsonArrayInsert(jBottom, NuiWidth(METACT_IconButton("ir_splbook", "action_add_spell", METACT_GetText(METACT_TEXT_SOURCE_SPELL, oPC)), 30.0f));
    jBottom = JsonArrayInsert(jBottom, NuiWidth(METACT_IconButton("ife_alertness", "action_add_feat", METACT_GetText(METACT_TEXT_ABILITIES, oPC)), 30.0f));
    jBottom = JsonArrayInsert(jBottom, NuiWidth(METACT_IconButton("ir_inventory", "action_add_item", METACT_GetText(METACT_TEXT_SOURCE_ITEM, oPC)), 30.0f));
    jBottom = JsonArrayInsert(jBottom, NuiWidth(METACT_IconButton("ir_equip_r", "action_add_equip", METACT_GetText(METACT_TEXT_EQUIP_ITEM, oPC)), 30.0f));
    jBottom = JsonArrayInsert(jBottom, NuiWidth(METACT_IconButton("ir_attack", "action_add_attack", METACT_GetText(METACT_TEXT_BASIC_ATTACK, oPC)), 30.0f));
    jBottom = JsonArrayInsert(jBottom, NuiSpacer());
    jPanel = JsonArrayInsert(jPanel, NuiHeight(NuiRow(jBottom), 30.0f));
    return NuiEnabled(NuiCol(jPanel), NuiBind("actions_enabled"));
}

json METACT_BuildPrioritiesPanel(object oPC, float fHeight)
{
    json jPanel = JsonArray();
    jPanel = JsonArrayInsert(jPanel, NuiHeight(METACT_Header(METACT_GetText(METACT_TEXT_TARGET_PRIORITIES, oPC)), 24.0f));
    jPanel = JsonArrayInsert(jPanel, NuiHeight(NuiStyleForegroundColor(NuiLabel(NuiBind("priority_scope_label"), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_MIDDLE)), NuiColor(150, 150, 150)), 30.0f));
    json jPriorityTemplate = JsonArray();
    jPriorityTemplate = JsonArrayInsert(jPriorityTemplate, NuiListTemplateCell(MEMORIA_NUI_Help(NuiId(NuiButton(NuiBind("priority_summary")), "priority_edit"), NuiBind("priority_tooltip")), 0.0f, TRUE));
    jPriorityTemplate = JsonArrayInsert(jPriorityTemplate, NuiListTemplateCell(METACT_IconButton("gui_spl_btn_up", "priority_up", METACT_GetText(METACT_TEXT_UP, oPC)), 28.0f, FALSE));
    jPriorityTemplate = JsonArrayInsert(jPriorityTemplate, NuiListTemplateCell(METACT_IconButton("gui_spl_btn_down", "priority_down", METACT_GetText(METACT_TEXT_DOWN, oPC)), 28.0f, FALSE));
    jPanel = JsonArrayInsert(jPanel, NuiHeight(NuiList(jPriorityTemplate, NuiBind("priority_count"), 32.0f, TRUE, NUI_SCROLLBARS_Y), fHeight - 114.0f));
    jPanel = JsonArrayInsert(jPanel, NuiHeight(NuiStyleForegroundColor(NuiLabel(NuiBind("priority_fallback_label"), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_MIDDLE)), NuiColor(150, 150, 150)), 30.0f));
    json jBottom = JsonArray();
    jBottom = JsonArrayInsert(jBottom, NuiWidth(MEMORIA_NUI_Help(NuiId(NuiButton(JsonString("+")), "priority_add"), JsonString(METACT_GetText(METACT_TEXT_ADD_PRIORITY, oPC))), 30.0f));
    jBottom = JsonArrayInsert(jBottom, NuiSpacer());
    jPanel = JsonArrayInsert(jPanel, NuiHeight(NuiRow(jBottom), 30.0f));
    return NuiCol(jPanel);
}

void METACT_RefreshPrioritiesPanel(object oPC, int iToken, int iScope)
{
    string sScopeKey = iScope == METACT_PRIORITY_SCOPE_ACTION ? METACT_TEXT_ACTION_PRIORITIES : iScope == METACT_PRIORITY_SCOPE_RULE ? METACT_TEXT_LOCAL_PRIORITIES : METACT_TEXT_GLOBAL_PRIORITIES;
    string sFallbackKey = iScope == METACT_PRIORITY_SCOPE_ACTION ? METACT_TEXT_ACTION_PRIORITY_FALLBACK : iScope == METACT_PRIORITY_SCOPE_RULE ? METACT_TEXT_RULE_PRIORITY_FALLBACK : METACT_TEXT_PRIORITY_DEFAULT;
    NuiSetBind(oPC, iToken, "priority_scope_label", JsonString(METACT_GetText(sScopeKey, oPC)));
    NuiSetBind(oPC, iToken, "priority_fallback_label", JsonString(METACT_GetText(sFallbackKey, oPC)));
    json jPriorities = METACT_GetPrioritiesForScope(oPC, iScope);
    json jPrioritySummaries = JsonArray();
    json jPriorityTooltips = JsonArray();
    int iIndex;
    for (iIndex = 0; iIndex < JsonGetLength(jPriorities); iIndex++)
    {
        json jPriority = JsonArrayGet(jPriorities, iIndex);
        string sPriority = METACT_PriorityLabel(oPC, jPriority);
        jPrioritySummaries = JsonArrayInsert(jPrioritySummaries, JsonString((JsonGetInt(JsonObjectGet(jPriority, "enabled")) ? "[x] " : "[ ] ") + IntToString(iIndex + 1) + ".  " + sPriority));
        jPriorityTooltips = JsonArrayInsert(jPriorityTooltips, JsonString(METACT_GetText(METACT_TEXT_EDIT, oPC) + ": " + sPriority));
    }
    NuiSetBind(oPC, iToken, "priority_summary", jPrioritySummaries);
    NuiSetBind(oPC, iToken, "priority_tooltip", jPriorityTooltips);
    NuiSetBind(oPC, iToken, "priority_count", JsonInt(JsonGetLength(jPriorities)));
}

json METACT_BuildMainWindow(object oPC)
{
    float fWidth = METACT_GetWindowWidth(oPC);
    float fHeight = METACT_GetWindowHeight(oPC);
    json jColumn = JsonArray();
    json jActorRow = JsonArray();
    jActorRow = JsonArrayInsert(jActorRow, NuiWidth(METACT_Label(METACT_GetText(METACT_TEXT_PROFILE, oPC)), 120.0f));
    jActorRow = JsonArrayInsert(jActorRow, NuiWidth(NuiCombo(NuiBind("actor_entries"), NuiBind("actor_sel")), fWidth >= 1000.0f ? 320.0f : fWidth - 145.0f));
    if (fWidth >= 1000.0f) jActorRow = JsonArrayInsert(jActorRow, NuiWidth(METACT_Label(METACT_GetText(METACT_TEXT_SCOPE, oPC)), 150.0f));
    if (fWidth >= 1000.0f) jActorRow = JsonArrayInsert(jActorRow, NuiWidth(NuiCombo(NuiBind("scope_entries"), NuiBind("scope_sel")), 320.0f));
    jActorRow = JsonArrayInsert(jActorRow, NuiSpacer());
    jColumn = JsonArrayInsert(jColumn, NuiHeight(NuiRow(jActorRow), 28.0f));
    if (fWidth < 1000.0f)
    {
        json jScopeRow = JsonArray();
        jScopeRow = JsonArrayInsert(jScopeRow, NuiWidth(METACT_Label(METACT_GetText(METACT_TEXT_SCOPE, oPC)), 120.0f));
        jScopeRow = JsonArrayInsert(jScopeRow, NuiWidth(NuiCombo(NuiBind("scope_entries"), NuiBind("scope_sel")), fWidth - 145.0f));
        jScopeRow = JsonArrayInsert(jScopeRow, NuiSpacer());
        jColumn = JsonArrayInsert(jColumn, NuiHeight(NuiRow(jScopeRow), 28.0f));
    }
    json jTacticRow = JsonArray();
    jTacticRow = JsonArrayInsert(jTacticRow, NuiWidth(METACT_Label(METACT_GetText(METACT_TEXT_TACTIC, oPC)), 120.0f));
    jTacticRow = JsonArrayInsert(jTacticRow, NuiWidth(NuiCombo(NuiBind("tactic_entries"), NuiBind("tactic_sel")), 320.0f));
    jTacticRow = JsonArrayInsert(jTacticRow, NuiWidth(MEMORIA_NUI_Help(NuiId(NuiButton(JsonString("+")), "tactic_new"), JsonString(METACT_GetText(METACT_TEXT_NEW, oPC))), 28.0f));
    jTacticRow = JsonArrayInsert(jTacticRow, NuiWidth(METACT_IconButton("nui_close", "tactic_delete", METACT_GetText(METACT_TEXT_DELETE, oPC)), 28.0f));
    jTacticRow = JsonArrayInsert(jTacticRow, NuiWidth(NuiCheck(JsonString(METACT_GetText(METACT_TEXT_ENABLED, oPC)), NuiBind("tactic_enabled")), 120.0f));
    jTacticRow = JsonArrayInsert(jTacticRow, NuiSpacer());
    jColumn = JsonArrayInsert(jColumn, NuiHeight(NuiRow(jTacticRow), 28.0f));
    json jNameRow = JsonArray();
    jNameRow = JsonArrayInsert(jNameRow, NuiWidth(METACT_Label(METACT_GetText(METACT_TEXT_TACTIC_NAME, oPC)), 140.0f));
    jNameRow = JsonArrayInsert(jNameRow, NuiWidth(NuiTextEdit(JsonString(""), NuiBind("tactic_name"), 80, FALSE), fWidth - 225.0f));
    jNameRow = JsonArrayInsert(jNameRow, NuiWidth(NuiId(NuiButton(JsonString("OK")), "tactic_rename"), 52.0f));
    jColumn = JsonArrayInsert(jColumn, NuiHeight(NuiRow(jNameRow), 28.0f));
    json jDebugRow = JsonArray();
    jDebugRow = JsonArrayInsert(jDebugRow, NuiWidth(NuiCheck(JsonString(METACT_GetText(METACT_TEXT_DEBUG, oPC)), NuiBind("debug_enabled")), 220.0f));
    jDebugRow = JsonArrayInsert(jDebugRow, NuiWidth(NuiId(NuiButton(JsonString(METACT_GetText(METACT_TEXT_INSPECT_TARGET, oPC))), "debug_target"), 260.0f));
    jDebugRow = JsonArrayInsert(jDebugRow, NuiSpacer());
    jColumn = JsonArrayInsert(jColumn, NuiHeight(NuiRow(jDebugRow), 28.0f));
    float fContentHeight = fHeight - (fWidth >= 1000.0f ? 183.0f : 211.0f);
    if (fWidth >= 800.0f)
    {
        float fContentWidth = fWidth - 24.0f;
        float fGap = 8.0f;
        float fRulesWidth = (fContentWidth - fGap * 2.0f) * 0.28f;
        float fActionsWidth = (fContentWidth - fGap * 2.0f) * 0.42f;
        float fPrioritiesWidth = fContentWidth - fRulesWidth - fActionsWidth - fGap * 2.0f;
        json jContent = JsonArray();
        jContent = JsonArrayInsert(jContent, NuiWidth(METACT_BuildRulesPanel(oPC, fContentHeight), fRulesWidth));
        jContent = JsonArrayInsert(jContent, NuiWidth(METACT_Label(""), fGap));
        jContent = JsonArrayInsert(jContent, NuiWidth(METACT_BuildActionsPanel(oPC, fContentHeight), fActionsWidth));
        jContent = JsonArrayInsert(jContent, NuiWidth(METACT_Label(""), fGap));
        jContent = JsonArrayInsert(jContent, NuiWidth(METACT_BuildPrioritiesPanel(oPC, fContentHeight), fPrioritiesWidth));
        jColumn = JsonArrayInsert(jColumn, NuiHeight(NuiRow(jContent), fContentHeight));
    }
    else
    {
        float fSectionHeight = fContentHeight / 3.0f;
        jColumn = JsonArrayInsert(jColumn, NuiHeight(METACT_BuildRulesPanel(oPC, fSectionHeight), fSectionHeight));
        jColumn = JsonArrayInsert(jColumn, NuiHeight(METACT_BuildActionsPanel(oPC, fSectionHeight), fSectionHeight));
        jColumn = JsonArrayInsert(jColumn, NuiHeight(METACT_BuildPrioritiesPanel(oPC, fContentHeight - fSectionHeight * 2.0f), fContentHeight - fSectionHeight * 2.0f));
    }
    return NuiWindow(NuiCol(jColumn), JsonString(METACT_GetText(METACT_TEXT_TITLE, oPC)), NuiRect(-1.0f, -1.0f, fWidth, fHeight), JsonBool(FALSE), JsonBool(FALSE), JsonBool(TRUE), JsonBool(FALSE), JsonBool(TRUE));
}

void METACT_RefreshMain(object oPC, int iToken)
{
    METACT_BuildGroupCache(oPC);
    json jActors = JsonArray();
    int iIndex;
    for (iIndex = 1; iIndex <= METACT_GetGroupCount(oPC); iIndex++)
        jActors = JsonArrayInsert(jActors, NuiComboEntry(METACT_GetGroupMember(oPC, iIndex) == oPC ? METACT_GetText(METACT_TEXT_PROFILE_PC, oPC) : GetName(METACT_GetGroupMember(oPC, iIndex)), iIndex));
    NuiSetBind(oPC, iToken, "actor_entries", jActors);
    NuiSetBind(oPC, iToken, "scope_entries", JsonArrayInsert(JsonArrayInsert(JsonArray(), NuiComboEntry(METACT_GetText(METACT_TEXT_SCOPE_EXACT, oPC), METACT_SCOPE_EXACT)), NuiComboEntry(METACT_GetText(METACT_TEXT_SCOPE_TYPE, oPC), METACT_SCOPE_TYPE)));
    object oActor = GetLocalObject(oPC, METACT_LOCAL_ACTOR);
    if (!GetIsObjectValid(oActor) || !METACT_IsGroupCached(oPC, oActor))
    {
        oActor = oPC;
        SetLocalObject(oPC, METACT_LOCAL_ACTOR, oActor);
        SetLocalInt(oPC, METACT_LOCAL_SCOPE, METACT_SCOPE_PC);
    }
    int iActorIndex = 1;
    for (iIndex = 1; iIndex <= METACT_GetGroupCount(oPC); iIndex++)
    {
        if (METACT_GetGroupMember(oPC, iIndex) == oActor)
            iActorIndex = iIndex;
    }
    NuiSetBind(oPC, iToken, "actor_sel", JsonInt(iActorIndex));
    int iScope = oActor == oPC ? METACT_SCOPE_PC : GetLocalInt(oPC, METACT_LOCAL_SCOPE);
    if (iScope != METACT_SCOPE_EXACT && iScope != METACT_SCOPE_TYPE && iScope != METACT_SCOPE_PC)
        iScope = METACT_SCOPE_EXACT;
    NuiSetBind(oPC, iToken, "scope_sel", JsonInt(iScope == METACT_SCOPE_PC ? METACT_SCOPE_EXACT : iScope));
    int iProfile = METACT_EnsureProfile(oPC, oActor, iScope);
    SetLocalInt(oPC, METACT_LOCAL_PROFILE, iProfile);
    json jProfile = METACT_GetProfile(oPC, iProfile);
    json jTactics = JsonObjectGet(jProfile, "tactics");
    int iTactic = GetLocalInt(oPC, METACT_LOCAL_TACTIC);
    if (iTactic < 0 || iTactic >= JsonGetLength(jTactics))
        iTactic = JsonGetInt(JsonObjectGet(jProfile, "active"));
    if (iTactic < 0 || iTactic >= JsonGetLength(jTactics))
        iTactic = 0;
    SetLocalInt(oPC, METACT_LOCAL_TACTIC, iTactic);
    json jTacticEntries = JsonArray();
    for (iIndex = 0; iIndex < JsonGetLength(jTactics); iIndex++)
        jTacticEntries = JsonArrayInsert(jTacticEntries, NuiComboEntry(JsonGetString(JsonObjectGet(JsonArrayGet(jTactics, iIndex), "name")), iIndex));
    NuiSetBind(oPC, iToken, "tactic_entries", jTacticEntries);
    NuiSetBind(oPC, iToken, "tactic_sel", JsonInt(iTactic));
    json jTactic = JsonArrayGet(jTactics, iTactic);
    NuiSetBind(oPC, iToken, "tactic_name", JsonObjectGet(jTactic, "name"));
    NuiSetBind(oPC, iToken, "tactic_enabled", JsonBool(JsonGetInt(JsonObjectGet(jTactic, "enabled"))));
    NuiSetBind(oPC, iToken, "debug_enabled", JsonBool(METACT_GetDebugEnabled(oPC)));
    json jRules = JsonObjectGet(jTactic, "rules");
    int iRule = GetLocalInt(oPC, METACT_LOCAL_RULE);
    if (JsonGetLength(jRules) == 0) iRule = -1;
    else if (iRule < 0 || iRule >= JsonGetLength(jRules)) iRule = 0;
    SetLocalInt(oPC, METACT_LOCAL_RULE, iRule);
    NuiSetBind(oPC, iToken, "actions_enabled", JsonBool(iRule >= 0));
    json jSummaries = JsonArray();
    json jSelected = JsonArray();
    json jTooltips = JsonArray();
    for (iIndex = 0; iIndex < JsonGetLength(jRules); iIndex++)
    {
        json jRule = JsonArrayGet(jRules, iIndex);
        string sCondition = METACT_ConditionLabel(oPC, JsonObjectGet(jRule, "condition"));
        int iActionCount = JsonGetLength(JsonObjectGet(jRule, "actions"));
        jSummaries = JsonArrayInsert(jSummaries, JsonString((JsonGetInt(JsonObjectGet(jRule, "enabled")) ? "[x] " : "[ ] ") + IntToString(iIndex + 1) + ". " + sCondition + " (" + IntToString(iActionCount) + ")"));
        jSelected = JsonArrayInsert(jSelected, JsonBool(iIndex == iRule));
        jTooltips = JsonArrayInsert(jTooltips, JsonString(METACT_GetText(METACT_TEXT_EDIT, oPC) + ": " + sCondition));
    }
    NuiSetBind(oPC, iToken, "rule_summary", jSummaries);
    NuiSetBind(oPC, iToken, "rule_selected", jSelected);
    NuiSetBind(oPC, iToken, "rule_tooltip", jTooltips);
    NuiSetBind(oPC, iToken, "rule_count", JsonInt(JsonGetLength(jRules)));
    json jActions = iRule >= 0 ? JsonObjectGet(JsonArrayGet(jRules, iRule), "actions") : JsonArray();
    if (JsonGetType(jActions) != JSON_TYPE_ARRAY) jActions = JsonArray();
    json jActionSummaries = JsonArray();
    json jActionTooltips = JsonArray();
    for (iIndex = 0; iIndex < JsonGetLength(jActions); iIndex++)
    {
        json jAction = JsonArrayGet(jActions, iIndex);
        string sAction = METACT_ActionLabel(oPC, jAction);
        jActionSummaries = JsonArrayInsert(jActionSummaries, JsonString((JsonGetInt(JsonObjectGet(jAction, "enabled")) ? "[x] " : "[ ] ") + IntToString(iIndex + 1) + ". " + sAction));
        jActionTooltips = JsonArrayInsert(jActionTooltips, JsonString(METACT_GetText(METACT_TEXT_EDIT, oPC) + ": " + sAction));
    }
    NuiSetBind(oPC, iToken, "action_summary", jActionSummaries);
    NuiSetBind(oPC, iToken, "action_tooltip", jActionTooltips);
    NuiSetBind(oPC, iToken, "action_count", JsonInt(JsonGetLength(jActions)));
    METACT_RefreshPrioritiesPanel(oPC, iToken, METACT_PRIORITY_SCOPE_GLOBAL);
}

void METACT_OpenMain(object oPC)
{
    int iOld = NuiFindWindow(oPC, METACT_WINDOW_MAIN);
    if (iOld > 0) NuiDestroy(oPC, iOld);
    METACT_BuildGroupCache(oPC);
    SetLocalObject(oPC, METACT_LOCAL_ACTOR, oPC);
    SetLocalInt(oPC, METACT_LOCAL_SCOPE, METACT_SCOPE_PC);
    SetLocalInt(oPC, METACT_LOCAL_TACTIC, -1);
    SetLocalInt(oPC, METACT_LOCAL_RULE, -1);
    SetLocalInt(oPC, METACT_LOCAL_RULE_PAGE, 0);
    int iToken = MEMORIA_NUI_Create(oPC, METACT_BuildMainWindow(oPC), METACT_WINDOW_MAIN, "metact_nuievt");
    if (iToken <= 0) return;
    METACT_RefreshMain(oPC, iToken);
    NuiSetBindWatch(oPC, iToken, "actor_sel", TRUE);
    NuiSetBindWatch(oPC, iToken, "scope_sel", TRUE);
    NuiSetBindWatch(oPC, iToken, "tactic_sel", TRUE);
    NuiSetBindWatch(oPC, iToken, "tactic_enabled", TRUE);
    NuiSetBindWatch(oPC, iToken, "debug_enabled", TRUE);
}

json METACT_BuildPriorityDetails(object oPC, int iKind)
{
    json jDetails = JsonArray();
    if (iKind == 1)
    {
        jDetails = JsonArrayInsert(jDetails, NuiWidth(METACT_Label(METACT_GetText(METACT_TEXT_TARGET, oPC)), 120.0f));
        jDetails = JsonArrayInsert(jDetails, NuiWidth(NuiCombo(METACT_PriorityTargetEntries(oPC), NuiBind("priority_target")), 390.0f));
    }
    else if (iKind == 2)
    {
        jDetails = JsonArrayInsert(jDetails, NuiWidth(METACT_Label(METACT_GetText(METACT_TEXT_COMPARISON, oPC)), 95.0f));
        jDetails = JsonArrayInsert(jDetails, NuiWidth(NuiCombo(METACT_ComboEntries2(oPC, METACT_TEXT_AT_LEAST, METACT_TEXT_AT_MOST), NuiBind("priority_comparison")), 135.0f));
        jDetails = JsonArrayInsert(jDetails, NuiWidth(METACT_Label(METACT_GetText(METACT_TEXT_THRESHOLD, oPC)), 85.0f));
        jDetails = JsonArrayInsert(jDetails, NuiWidth(NuiCombo(METACT_RatingEntries(), NuiBind("priority_rating")), 195.0f));
    }
    else if (iKind == 3)
    {
        jDetails = JsonArrayInsert(jDetails, NuiWidth(METACT_Label(METACT_GetText(METACT_TEXT_COMPARISON, oPC)), 95.0f));
        jDetails = JsonArrayInsert(jDetails, NuiWidth(NuiCombo(METACT_ComboEntries2(oPC, METACT_TEXT_AT_LEAST, METACT_TEXT_AT_MOST), NuiBind("priority_health_comparison")), 135.0f));
        jDetails = JsonArrayInsert(jDetails, NuiWidth(METACT_Label(METACT_GetText(METACT_TEXT_THRESHOLD, oPC)), 85.0f));
        jDetails = JsonArrayInsert(jDetails, NuiWidth(NuiTextEdit(JsonString("50"), NuiBind("priority_health"), 3, FALSE), 70.0f));
        jDetails = JsonArrayInsert(jDetails, NuiWidth(METACT_Label("%"), 25.0f));
    }
    return NuiRow(jDetails);
}

json METACT_BuildPriorityWindow(object oPC)
{
    float fWidth = 560.0f;
    float fHeight = 224.0f;
    json jRoot = JsonArray();
    json jKind = JsonArray();
    jKind = JsonArrayInsert(jKind, NuiWidth(METACT_Label(METACT_GetText(METACT_TEXT_PRIORITY_KIND, oPC)), 120.0f));
    jKind = JsonArrayInsert(jKind, NuiWidth(NuiCombo(NuiBind("priority_entries"), NuiBind("priority_kind")), 390.0f));
    jRoot = JsonArrayInsert(jRoot, NuiHeight(NuiRow(jKind), 30.0f));
    jRoot = JsonArrayInsert(jRoot, NuiHeight(NuiId(NuiGroup(METACT_BuildPriorityDetails(oPC, 0), FALSE, NUI_SCROLLBARS_NONE), "priority_details"), 36.0f));
    jRoot = JsonArrayInsert(jRoot, NuiHeight(NuiCheck(JsonString(METACT_GetText(METACT_TEXT_ENABLED, oPC)), NuiBind("priority_enabled")), 28.0f));
    json jOperations = JsonArray();
    jOperations = JsonArrayInsert(jOperations, NuiWidth(NuiVisible(METACT_IconButton("gui_spl_btn_up", "priority_move_up", METACT_GetText(METACT_TEXT_UP, oPC)), NuiBind("priority_existing")), 32.0f));
    jOperations = JsonArrayInsert(jOperations, NuiWidth(NuiVisible(METACT_IconButton("gui_spl_btn_down", "priority_move_down", METACT_GetText(METACT_TEXT_DOWN, oPC)), NuiBind("priority_existing")), 32.0f));
    jOperations = JsonArrayInsert(jOperations, NuiWidth(NuiVisible(METACT_IconButton("nui_close", "priority_remove", METACT_GetText(METACT_TEXT_DELETE, oPC)), NuiBind("priority_existing")), 32.0f));
    jOperations = JsonArrayInsert(jOperations, NuiSpacer());
    jRoot = JsonArrayInsert(jRoot, NuiHeight(NuiRow(jOperations), 32.0f));
    json jButtons = JsonArray();
    jButtons = JsonArrayInsert(jButtons, NuiWidth(NuiId(NuiButton(JsonString(METACT_GetText(METACT_TEXT_SAVE, oPC))), "priority_save"), 120.0f));
    jButtons = JsonArrayInsert(jButtons, NuiSpacer());
    jButtons = JsonArrayInsert(jButtons, NuiWidth(NuiId(NuiButton(JsonString(METACT_GetText(METACT_TEXT_CANCEL, oPC))), "priority_cancel"), 120.0f));
    jRoot = JsonArrayInsert(jRoot, NuiHeight(NuiRow(jButtons), 32.0f));
    return NuiWindow(NuiCol(jRoot), JsonString(METACT_GetText(METACT_TEXT_PRIORITY_EDITOR, oPC)), NuiRect(-1.0f, -1.0f, fWidth, fHeight), JsonBool(FALSE), JsonBool(FALSE), JsonBool(TRUE), JsonBool(FALSE), JsonBool(TRUE));
}

void METACT_RefreshPriorityMode(object oPC, int iToken)
{
    int iKind = JsonGetInt(NuiGetBind(oPC, iToken, "priority_kind"));
    NuiSetGroupLayout(oPC, iToken, "priority_details", METACT_BuildPriorityDetails(oPC, iKind));
}

void METACT_RefreshPriorityEditor(object oPC, int iToken)
{
    json jPriority = GetLocalJson(oPC, METACT_LOCAL_PRIORITY_TEMP);
    string sKind = JsonGetString(JsonObjectGet(jPriority, "kind"));
    string sComparison = JsonGetString(JsonObjectGet(jPriority, "comparison"));
    if (sComparison == "") sComparison = sKind == "rating_low" || sKind == "health_low" ? "max" : "min";
    int iRating = JsonGetInt(JsonObjectGet(jPriority, "value"));
    if (METACT_PriorityCategory(sKind) != "rating" || JsonGetType(JsonObjectGet(jPriority, "value")) != JSON_TYPE_INTEGER || iRating < 0 || iRating > 6) iRating = 3;
    int iHealth = JsonGetInt(JsonObjectGet(jPriority, "value"));
    if (METACT_PriorityCategory(sKind) != "health" || iHealth < 1 || iHealth > 100) iHealth = 50;
    NuiSetBind(oPC, iToken, "priority_entries", METACT_PriorityEntries(oPC));
    NuiSetBind(oPC, iToken, "priority_kind", JsonInt(METACT_PriorityKindToIndex(sKind)));
    NuiSetBind(oPC, iToken, "priority_target", JsonInt(METACT_GetPriorityTargetIndex(oPC, jPriority)));
    NuiSetBind(oPC, iToken, "priority_comparison", JsonInt(sComparison == "max" ? 1 : 0));
    NuiSetBind(oPC, iToken, "priority_health_comparison", JsonInt(sComparison == "max" ? 1 : 0));
    NuiSetBind(oPC, iToken, "priority_rating", JsonInt(iRating));
    NuiSetBind(oPC, iToken, "priority_health", JsonString(IntToString(iHealth)));
    NuiSetBind(oPC, iToken, "priority_enabled", JsonBool(JsonGetInt(JsonObjectGet(jPriority, "enabled"))));
    NuiSetBind(oPC, iToken, "priority_existing", JsonBool(GetLocalInt(oPC, METACT_LOCAL_PRIORITY) >= 0));
    METACT_RefreshPriorityMode(oPC, iToken);
}

void METACT_OpenPriorityEditor(object oPC, int iPriority)
{
    json jPriorities = METACT_GetEditablePriorities(oPC);
    if (iPriority < 0 && JsonGetLength(jPriorities) >= 4)
    {
        SendMessageToPC(oPC, METACT_GetText(METACT_TEXT_INVALID, oPC));
        return;
    }
    json jPriority = iPriority >= 0 && iPriority < JsonGetLength(jPriorities) ? JsonArrayGet(jPriorities, iPriority) : METACT_NewPriority(jPriorities);
    SetLocalInt(oPC, METACT_LOCAL_PRIORITY, iPriority);
    SetLocalJson(oPC, METACT_LOCAL_PRIORITY_TEMP, jPriority);
    int iOld = NuiFindWindow(oPC, METACT_WINDOW_PRIORITY);
    if (iOld > 0) NuiDestroy(oPC, iOld);
    int iToken = MEMORIA_NUI_Create(oPC, METACT_BuildPriorityWindow(oPC), METACT_WINDOW_PRIORITY, "metact_nuievt");
    if (iToken > 0)
    {
        METACT_RefreshPriorityEditor(oPC, iToken);
        NuiSetBindWatch(oPC, iToken, "priority_kind", TRUE);
    }
}

json METACT_BuildActionPanel(object oPC, float fPanelWidth)
{
    json jAction = JsonArray();
    jAction = JsonArrayInsert(jAction, NuiHeight(METACT_Header(METACT_GetText(METACT_TEXT_ACTION, oPC)), 24.0f));
    json jActionRow = JsonArray();
    jActionRow = JsonArrayInsert(jActionRow, NuiWidth(MEMORIA_NUI_Help(NuiImage(NuiBind("action_icon"), JsonInt(NUI_ASPECT_FIT), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE)), NuiBind("action_label")), 40.0f));
    jActionRow = JsonArrayInsert(jActionRow, NuiWidth(METACT_Label(""), 8.0f));
    jActionRow = JsonArrayInsert(jActionRow, NuiWidth(NuiLabel(NuiBind("action_label"), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_MIDDLE)), fPanelWidth - 65.0f));
    jAction = JsonArrayInsert(jAction, NuiHeight(NuiRow(jActionRow), 40.0f));
    json jSourceButtons = JsonArray();
    jSourceButtons = JsonArrayInsert(jSourceButtons, NuiWidth(METACT_IconButton("ir_splbook", "choose_spell", METACT_GetText(METACT_TEXT_SOURCE_SPELL, oPC)), 36.0f));
    jSourceButtons = JsonArrayInsert(jSourceButtons, NuiWidth(METACT_IconButton("ife_alertness", "choose_feat", METACT_GetText(METACT_TEXT_ABILITIES, oPC)), 36.0f));
    jSourceButtons = JsonArrayInsert(jSourceButtons, NuiWidth(METACT_IconButton("ir_inventory", "choose_item", METACT_GetText(METACT_TEXT_SOURCE_ITEM, oPC)), 36.0f));
    jSourceButtons = JsonArrayInsert(jSourceButtons, NuiWidth(METACT_IconButton("ir_equip_r", "choose_equip", METACT_GetText(METACT_TEXT_EQUIP_ITEM, oPC)), 36.0f));
    jSourceButtons = JsonArrayInsert(jSourceButtons, NuiWidth(METACT_IconButton("ir_attack", "choose_attack", METACT_GetText(METACT_TEXT_BASIC_ATTACK, oPC)), 36.0f));
    jSourceButtons = JsonArrayInsert(jSourceButtons, NuiSpacer());
    jAction = JsonArrayInsert(jAction, NuiHeight(NuiRow(jSourceButtons), 36.0f));
    jAction = JsonArrayInsert(jAction, NuiHeight(METACT_Label(METACT_GetText(METACT_TEXT_TARGET, oPC)), 20.0f));
    jAction = JsonArrayInsert(jAction, NuiHeight(NuiCombo(NuiBind("target_entries"), NuiBind("target_sel")), 28.0f));
    jAction = JsonArrayInsert(jAction, NuiHeight(METACT_Label(METACT_GetText(METACT_TEXT_SOURCE, oPC)), 20.0f));
    jAction = JsonArrayInsert(jAction, NuiHeight(NuiCombo(METACT_ComboEntries3(oPC, METACT_TEXT_SOURCE_ANY, METACT_TEXT_SOURCE_SPELL, METACT_TEXT_SOURCE_ITEM), NuiBind("source_sel")), 28.0f));
    jAction = JsonArrayInsert(jAction, NuiHeight(NuiCheck(JsonString(METACT_GetText(METACT_TEXT_ALLOW_MOVEMENT, oPC)), NuiBind("allow_move")), 26.0f));
    json jFriendlyFire = JsonArray();
    jFriendlyFire = JsonArrayInsert(jFriendlyFire, NuiHeight(METACT_Label(METACT_GetText(METACT_TEXT_FRIENDLY_FIRE, oPC)), 20.0f));
    jFriendlyFire = JsonArrayInsert(jFriendlyFire, NuiHeight(NuiCombo(METACT_FriendlyFirePolicyEntries(oPC), NuiBind("friendly_fire_policy")), 28.0f));
    jFriendlyFire = JsonArrayInsert(jFriendlyFire, NuiHeight(NuiStyleForegroundColor(NuiLabel(NuiBind("friendly_fire_policy_help"), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_TOP)), NuiColor(150, 150, 150)), 68.0f));
    jAction = JsonArrayInsert(jAction, NuiHeight(NuiVisible(NuiCol(jFriendlyFire), NuiBind("show_friendly_fire")), 116.0f));
    return NuiCol(jAction);
}

json METACT_BuildConditionPanel(object oPC)
{
    json jCondition = JsonArray();
    jCondition = JsonArrayInsert(jCondition, NuiHeight(METACT_Header(METACT_GetText(METACT_TEXT_CONDITION, oPC)), 24.0f));
    jCondition = JsonArrayInsert(jCondition, NuiHeight(NuiCombo(METACT_ConditionEntries(oPC), NuiBind("condition_sel")), 30.0f));
    json jConditionRating = JsonArray();
    jConditionRating = JsonArrayInsert(jConditionRating, NuiHeight(METACT_Label(METACT_GetText(METACT_TEXT_COMPARISON, oPC)), 20.0f));
    jConditionRating = JsonArrayInsert(jConditionRating, NuiHeight(NuiCombo(METACT_ComboEntries2(oPC, METACT_TEXT_AT_LEAST, METACT_TEXT_AT_MOST), NuiBind("comparison_sel")), 28.0f));
    jConditionRating = JsonArrayInsert(jConditionRating, NuiHeight(METACT_Label(METACT_GetText(METACT_TEXT_THRESHOLD, oPC)), 20.0f));
    jConditionRating = JsonArrayInsert(jConditionRating, NuiHeight(NuiCombo(METACT_RatingEntries(), NuiBind("rating_sel")), 28.0f));
    jCondition = JsonArrayInsert(jCondition, NuiHeight(NuiVisible(NuiCol(jConditionRating), NuiBind("show_condition_rating")), 96.0f));
    json jConditionSubject = JsonArray();
    jConditionSubject = JsonArrayInsert(jConditionSubject, NuiHeight(METACT_Label(METACT_GetText(METACT_TEXT_SUBJECT, oPC)), 20.0f));
    jConditionSubject = JsonArrayInsert(jConditionSubject, NuiHeight(NuiCombo(METACT_ComboEntries2(oPC, METACT_TEXT_SUBJECT_SELF, METACT_TEXT_SUBJECT_ALLY), NuiBind("subject_sel")), 28.0f));
    jCondition = JsonArrayInsert(jCondition, NuiHeight(NuiVisible(NuiCol(jConditionSubject), NuiBind("show_condition_subject")), 48.0f));
    json jConditionValues = JsonArray();
    jConditionValues = JsonArrayInsert(jConditionValues, NuiHeight(METACT_Label(METACT_GetText(METACT_TEXT_THRESHOLD, oPC)), 20.0f));
    jConditionValues = JsonArrayInsert(jConditionValues, NuiHeight(NuiTextEdit(JsonString("1"), NuiBind("condition_value"), 4, FALSE), 28.0f));
    jCondition = JsonArrayInsert(jCondition, NuiHeight(NuiVisible(NuiCol(jConditionValues), NuiBind("show_condition_values")), 48.0f));
    json jConditionRadius = JsonArray();
    jConditionRadius = JsonArrayInsert(jConditionRadius, NuiHeight(METACT_Label(METACT_GetText(METACT_TEXT_RADIUS, oPC)), 20.0f));
    jConditionRadius = JsonArrayInsert(jConditionRadius, NuiHeight(NuiTextEdit(JsonString("20"), NuiBind("condition_radius"), 8, FALSE), 28.0f));
    jCondition = JsonArrayInsert(jCondition, NuiHeight(NuiVisible(NuiCol(jConditionRadius), NuiBind("show_condition_radius")), 48.0f));
    jCondition = JsonArrayInsert(jCondition, NuiHeight(NuiVisible(NuiStyleForegroundColor(METACT_Label(METACT_GetText(METACT_TEXT_CLUSTER_HINT, oPC)), NuiColor(150, 150, 150)), NuiBind("show_condition_cluster_hint")), 44.0f));
    return NuiCol(jCondition);
}

json METACT_BuildRuleWindow(object oPC)
{
    float fWidth = METACT_GetWindowWidth(oPC);
    float fHeight = METACT_GetWindowHeight(oPC);
    float fContentWidth = fWidth - METACT_NUI_WINDOW_HORIZONTAL_INSET;
    float fGap = 8.0f;
    float fConditionWidth = (fContentWidth - fGap) * 0.56f;
    float fPrioritiesWidth = fContentWidth - fConditionWidth - fGap;
    float fContentHeight = fHeight - 139.0f;
    json jRoot = JsonArray();
    jRoot = JsonArrayInsert(jRoot, NuiHeight(NuiCheck(JsonString(METACT_GetText(METACT_TEXT_ENABLED, oPC)), NuiBind("rule_enabled")), 26.0f));
    json jContent = JsonArray();
    jContent = JsonArrayInsert(jContent, NuiWidth(NuiGroup(METACT_BuildConditionPanel(oPC), TRUE, NUI_SCROLLBARS_Y), fConditionWidth));
    jContent = JsonArrayInsert(jContent, NuiWidth(METACT_Label(""), fGap));
    jContent = JsonArrayInsert(jContent, NuiWidth(NuiGroup(METACT_BuildPrioritiesPanel(oPC, fContentHeight - METACT_NUI_GROUP_INSET), TRUE, NUI_SCROLLBARS_NONE), fPrioritiesWidth));
    jRoot = JsonArrayInsert(jRoot, NuiHeight(NuiRow(jContent), fContentHeight));
    json jButtons = JsonArray();
    jButtons = JsonArrayInsert(jButtons, NuiWidth(NuiVisible(METACT_IconButton("nui_close", "rule_remove", METACT_GetText(METACT_TEXT_DELETE, oPC)), NuiBind("rule_existing")), 32.0f));
    jButtons = JsonArrayInsert(jButtons, NuiWidth(NuiId(NuiButton(JsonString(METACT_GetText(METACT_TEXT_SAVE, oPC))), "rule_save"), 120.0f));
    jButtons = JsonArrayInsert(jButtons, NuiSpacer());
    jButtons = JsonArrayInsert(jButtons, NuiWidth(NuiId(NuiButton(JsonString(METACT_GetText(METACT_TEXT_CANCEL, oPC))), "rule_cancel"), 120.0f));
    jRoot = JsonArrayInsert(jRoot, NuiHeight(NuiRow(jButtons), 32.0f));
    return NuiWindow(NuiCol(jRoot), JsonString(METACT_GetText(METACT_TEXT_RULE_EDITOR, oPC)), NuiRect(-1.0f, -1.0f, fWidth, fHeight), JsonBool(FALSE), JsonBool(FALSE), JsonBool(TRUE), JsonBool(FALSE), JsonBool(TRUE));
}

json METACT_BuildActionWindow(object oPC)
{
    float fWidth = METACT_GetWindowWidth(oPC);
    float fHeight = METACT_GetWindowHeight(oPC);
    float fContentWidth = fWidth - METACT_NUI_WINDOW_HORIZONTAL_INSET;
    float fGap = 8.0f;
    float fActionWidth = (fContentWidth - fGap) * 0.56f;
    float fPrioritiesWidth = fContentWidth - fActionWidth - fGap;
    float fActionPanelWidth = fActionWidth - METACT_NUI_GROUP_INSET - METACT_NUI_SCROLLBAR_SIZE;
    float fContentHeight = fHeight - 139.0f;
    json jRoot = JsonArray();
    jRoot = JsonArrayInsert(jRoot, NuiHeight(NuiCheck(JsonString(METACT_GetText(METACT_TEXT_ENABLED, oPC)), NuiBind("action_enabled")), 26.0f));
    json jContent = JsonArray();
    jContent = JsonArrayInsert(jContent, NuiWidth(NuiGroup(METACT_BuildActionPanel(oPC, fActionPanelWidth), TRUE, NUI_SCROLLBARS_Y), fActionWidth));
    jContent = JsonArrayInsert(jContent, NuiWidth(METACT_Label(""), fGap));
    jContent = JsonArrayInsert(jContent, NuiWidth(NuiGroup(METACT_BuildPrioritiesPanel(oPC, fContentHeight - METACT_NUI_GROUP_INSET), TRUE, NUI_SCROLLBARS_NONE), fPrioritiesWidth));
    jRoot = JsonArrayInsert(jRoot, NuiHeight(NuiRow(jContent), fContentHeight));
    json jButtons = JsonArray();
    jButtons = JsonArrayInsert(jButtons, NuiWidth(NuiVisible(METACT_IconButton("nui_close", "action_remove", METACT_GetText(METACT_TEXT_DELETE, oPC)), NuiBind("action_existing")), 32.0f));
    jButtons = JsonArrayInsert(jButtons, NuiWidth(NuiId(NuiButton(JsonString(METACT_GetText(METACT_TEXT_SAVE, oPC))), "action_save"), 120.0f));
    jButtons = JsonArrayInsert(jButtons, NuiSpacer());
    jButtons = JsonArrayInsert(jButtons, NuiWidth(NuiId(NuiButton(JsonString(METACT_GetText(METACT_TEXT_CANCEL, oPC))), "action_cancel"), 120.0f));
    jRoot = JsonArrayInsert(jRoot, NuiHeight(NuiRow(jButtons), 32.0f));
    return NuiWindow(NuiCol(jRoot), JsonString(METACT_GetText(METACT_TEXT_ACTION_EDITOR, oPC)), NuiRect(-1.0f, -1.0f, fWidth, fHeight), JsonBool(FALSE), JsonBool(FALSE), JsonBool(TRUE), JsonBool(FALSE), JsonBool(TRUE));
}

int METACT_TargetToIndex(string sTarget)
{
    if (sTarget == "self") return METACT_TARGET_SELF;
    if (sTarget == "enemy") return METACT_TARGET_ENEMY;
    if (sTarget == "ally") return METACT_TARGET_ALLY;
    if (sTarget == "cluster") return METACT_TARGET_CLUSTER;
    if (sTarget == "enemy_low") return METACT_TARGET_ENEMY_LOW;
    if (sTarget == "enemy_high") return METACT_TARGET_ENEMY_HIGH;
    return METACT_TARGET_AUTO;
}

string METACT_IndexToTarget(int iTarget)
{
    return iTarget == METACT_TARGET_SELF ? "self" : iTarget == METACT_TARGET_ENEMY ? "enemy" : iTarget == METACT_TARGET_ALLY ? "ally" : iTarget == METACT_TARGET_CLUSTER ? "cluster" : iTarget == METACT_TARGET_ENEMY_LOW ? "enemy_low" : iTarget == METACT_TARGET_ENEMY_HIGH ? "enemy_high" : "auto";
}

json METACT_TargetEntries(object oPC, json jAction, json jRule)
{
    json jEntries = JsonArray();
    string sKind = JsonGetString(JsonObjectGet(jAction, "kind"));
    if (sKind == "") return JsonArrayInsert(jEntries, NuiComboEntry(METACT_GetText(METACT_TEXT_TARGET_AUTO, oPC), METACT_TARGET_AUTO));
    if (sKind == "familiar" || sKind == "equip" || (sKind == "feat" && JsonGetInt(JsonObjectGet(jAction, "feat_target_self")))) return JsonArrayInsert(jEntries, NuiComboEntry(METACT_GetText(METACT_TEXT_TARGET_SELF, oPC), METACT_TARGET_SELF));
    if (sKind == "attack") return JsonArrayInsert(jEntries, NuiComboEntry(METACT_GetText(METACT_TEXT_TARGET_BY_PRIORITIES, oPC), METACT_TARGET_AUTO));
    int iSpell = JsonGetInt(JsonObjectGet(jAction, "spell"));
    if (METACT_GetSpellRole(iSpell) == METACT_ROLE_SUMMON || Get2DAString("spells", "Range", iSpell) == "P") return JsonArrayInsert(jEntries, NuiComboEntry(METACT_GetText(METACT_TEXT_TARGET_SELF, oPC), METACT_TARGET_SELF));
    if (METACT_IsSpellHostile(iSpell) && METACT_IsSpellArea(iSpell)) return JsonArrayInsert(jEntries, NuiComboEntry(METACT_GetText(METACT_TEXT_TARGET_CLUSTER, oPC), METACT_TARGET_CLUSTER));
    if (METACT_IsSpellHostile(iSpell)) return JsonArrayInsert(jEntries, NuiComboEntry(METACT_GetText(METACT_TEXT_TARGET_BY_PRIORITIES, oPC), METACT_TARGET_AUTO));
    if (!METACT_IsSpellHostile(iSpell))
    {
        jEntries = JsonArrayInsert(jEntries, NuiComboEntry(METACT_GetText(METACT_TEXT_TARGET_SELF, oPC), METACT_TARGET_SELF));
        return JsonArrayInsert(jEntries, NuiComboEntry(METACT_GetText(METACT_TEXT_TARGET_ALLY, oPC), METACT_TARGET_ALLY));
    }
    return jEntries;
}

int METACT_IsTargetAvailable(json jEntries, int iTarget)
{
    int iIndex;
    for (iIndex = 0; iIndex < JsonGetLength(jEntries); iIndex++)
    {
        if (JsonGetInt(JsonArrayGet(JsonArrayGet(jEntries, iIndex), 1)) == iTarget) return TRUE;
    }
    return FALSE;
}

int METACT_ConditionToIndex(string sKind)
{
    if (sKind == "enemies") return 1;
    if (sKind == "cluster") return 2;
    if (sKind == "health") return 3;
    if (sKind == "no_summon") return 4;
    if (sKind == "no_familiar") return 5;
    if (sKind == "enemy_rating") return 6;
    return 0;
}

string METACT_IndexToCondition(int iKind)
{
    return iKind == 1 ? "enemies" : iKind == 2 ? "cluster" : iKind == 3 ? "health" : iKind == 4 ? "no_summon" : iKind == 5 ? "no_familiar" : iKind == 6 ? "enemy_rating" : "always";
}

void METACT_RefreshConditionMode(object oPC, int iToken)
{
    int iCondition = JsonGetInt(NuiGetBind(oPC, iToken, "condition_sel"));
    NuiSetBind(oPC, iToken, "show_condition_values", JsonBool(iCondition >= 1 && iCondition <= 3));
    NuiSetBind(oPC, iToken, "show_condition_radius", JsonBool(iCondition == 1 || iCondition == 3));
    NuiSetBind(oPC, iToken, "show_condition_subject", JsonBool(iCondition == 3));
    NuiSetBind(oPC, iToken, "show_condition_rating", JsonBool(iCondition == 6));
    NuiSetBind(oPC, iToken, "show_condition_cluster_hint", JsonBool(iCondition == 2));
}

void METACT_RefreshRuleEditor(object oPC, int iToken)
{
    json jRule = GetLocalJson(oPC, METACT_LOCAL_RULE_TEMP);
    json jCondition = JsonObjectGet(jRule, "condition");
    NuiSetBind(oPC, iToken, "rule_enabled", JsonBool(JsonGetInt(JsonObjectGet(jRule, "enabled"))));
    NuiSetBind(oPC, iToken, "condition_sel", JsonInt(METACT_ConditionToIndex(JsonGetString(JsonObjectGet(jCondition, "kind")))));
    NuiSetBind(oPC, iToken, "condition_value", JsonString(IntToString(JsonGetInt(JsonObjectGet(jCondition, "value")))));
    NuiSetBind(oPC, iToken, "condition_radius", JsonString(FloatToString(JsonGetFloat(JsonObjectGet(jCondition, "radius")), 0, 1)));
    int iRating = JsonGetString(JsonObjectGet(jCondition, "kind")) == "enemy_rating" ? JsonGetInt(JsonObjectGet(jCondition, "value")) : 2;
    if (iRating < 0 || iRating > 6) iRating = 2;
    NuiSetBind(oPC, iToken, "rating_sel", JsonInt(iRating));
    NuiSetBind(oPC, iToken, "comparison_sel", JsonInt(JsonGetString(JsonObjectGet(jCondition, "comparison")) == "max" ? 1 : 0));
    NuiSetBind(oPC, iToken, "subject_sel", JsonInt(JsonGetString(JsonObjectGet(jCondition, "subject")) == "ally" ? 1 : 0));
    METACT_RefreshConditionMode(oPC, iToken);
    NuiSetBind(oPC, iToken, "rule_existing", JsonBool(GetLocalInt(oPC, METACT_LOCAL_RULE) >= 0));
    METACT_RefreshPrioritiesPanel(oPC, iToken, METACT_PRIORITY_SCOPE_RULE);
}

void METACT_RefreshActionEditor(object oPC, int iToken)
{
    json jAction = GetLocalJson(oPC, METACT_LOCAL_ACTION_TEMP);
    json jRule = METACT_GetSelectedRule(oPC);
    NuiSetBind(oPC, iToken, "action_enabled", JsonBool(JsonGetInt(JsonObjectGet(jAction, "enabled"))));
    NuiSetBind(oPC, iToken, "action_label", JsonString(METACT_ActionLabel(oPC, jAction)));
    NuiSetBind(oPC, iToken, "action_icon", JsonString(METACT_ActionIcon(jAction)));
    json jTargetEntries = METACT_TargetEntries(oPC, jAction, jRule);
    int iTarget = METACT_TargetToIndex(JsonGetString(JsonObjectGet(jAction, "target")));
    if (!METACT_IsTargetAvailable(jTargetEntries, iTarget)) iTarget = JsonGetInt(JsonArrayGet(JsonArrayGet(jTargetEntries, 0), 1));
    NuiSetBind(oPC, iToken, "target_entries", jTargetEntries);
    NuiSetBind(oPC, iToken, "target_sel", JsonInt(iTarget));
    string sSource = JsonGetString(JsonObjectGet(jAction, "source"));
    NuiSetBind(oPC, iToken, "source_sel", JsonInt(sSource == "spell" ? 1 : sSource == "item" ? 2 : 0));
    NuiSetBind(oPC, iToken, "allow_move", JsonBool(JsonGetInt(JsonObjectGet(jAction, "move"))));
    int iAoeSafety = JsonGetInt(JsonObjectGet(jAction, "aoe_safety"));
    if (iAoeSafety < METACT_AOE_SAFETY_SAFE || iAoeSafety > METACT_AOE_SAFETY_STATIONARY) iAoeSafety = METACT_AOE_SAFETY_SAFE;
    int iFriendlyFirePolicy = JsonGetInt(JsonObjectGet(jAction, "friendly_fire")) ? 0 : iAoeSafety;
    NuiSetBind(oPC, iToken, "friendly_fire_policy", JsonInt(iFriendlyFirePolicy));
    NuiSetBind(oPC, iToken, "friendly_fire_policy_help", JsonString(METACT_GetText(METACT_GetFriendlyFireHelpKey(iFriendlyFirePolicy), oPC)));
    int iSpell = JsonGetInt(JsonObjectGet(jAction, "spell"));
    NuiSetBind(oPC, iToken, "show_friendly_fire", JsonBool(iSpell >= 0 && METACT_IsSpellHostile(iSpell) && METACT_IsSpellArea(iSpell) && METACT_CanSpellHitAllies(iSpell)));
    NuiSetBind(oPC, iToken, "action_existing", JsonBool(GetLocalInt(oPC, METACT_LOCAL_ACTION) >= 0));
    METACT_RefreshPrioritiesPanel(oPC, iToken, METACT_PRIORITY_SCOPE_ACTION);
}

void METACT_StoreActionEditorState(object oPC, int iToken)
{
    json jAction = GetLocalJson(oPC, METACT_LOCAL_ACTION_TEMP);
    if (iToken <= 0 || JsonGetType(jAction) != JSON_TYPE_OBJECT) return;
    jAction = JsonObjectSet(jAction, "enabled", JsonBool(JsonGetInt(NuiGetBind(oPC, iToken, "action_enabled"))));
    jAction = JsonObjectSet(jAction, "target", JsonString(METACT_IndexToTarget(JsonGetInt(NuiGetBind(oPC, iToken, "target_sel")))));
    int iSource = JsonGetInt(NuiGetBind(oPC, iToken, "source_sel"));
    jAction = JsonObjectSet(jAction, "source", JsonString(iSource == 1 ? "spell" : iSource == 2 ? "item" : "any"));
    jAction = JsonObjectSet(jAction, "move", JsonBool(JsonGetInt(NuiGetBind(oPC, iToken, "allow_move"))));
    int iFriendlyFirePolicy = JsonGetInt(NuiGetBind(oPC, iToken, "friendly_fire_policy"));
    if (iFriendlyFirePolicy < 0 || iFriendlyFirePolicy > 3) iFriendlyFirePolicy = 1;
    jAction = JsonObjectSet(jAction, "friendly_fire", JsonBool(iFriendlyFirePolicy == 0));
    jAction = JsonObjectSet(jAction, "aoe_safety", JsonInt(iFriendlyFirePolicy == 0 ? METACT_AOE_SAFETY_SAFE : iFriendlyFirePolicy));
    SetLocalJson(oPC, METACT_LOCAL_ACTION_TEMP, jAction);
}

void METACT_OpenRuleEditor(object oPC, int iRule)
{
    json jRules = JsonObjectGet(METACT_GetSelectedTactic(oPC), "rules");
    json jRule = iRule >= 0 && iRule < JsonGetLength(jRules) ? JsonArrayGet(jRules, iRule) : METACT_NewRule();
    SetLocalInt(oPC, METACT_LOCAL_RULE, iRule);
    SetLocalJson(oPC, METACT_LOCAL_RULE_TEMP, jRule);
    SetLocalInt(oPC, METACT_LOCAL_PRIORITY_SCOPE, METACT_PRIORITY_SCOPE_RULE);
    int iOld = NuiFindWindow(oPC, METACT_WINDOW_RULE);
    if (iOld > 0) NuiDestroy(oPC, iOld);
    int iToken = MEMORIA_NUI_Create(oPC, METACT_BuildRuleWindow(oPC), METACT_WINDOW_RULE, "metact_nuievt");
    if (iToken > 0)
    {
        METACT_RefreshRuleEditor(oPC, iToken);
        NuiSetBindWatch(oPC, iToken, "condition_sel", TRUE);
    }
}

void METACT_ShowActionEditor(object oPC)
{
    if (JsonGetType(GetLocalJson(oPC, METACT_LOCAL_ACTION_TEMP)) != JSON_TYPE_OBJECT) return;
    DeleteLocalInt(oPC, METACT_LOCAL_ACTION_HIDDEN);
    int iOld = NuiFindWindow(oPC, METACT_WINDOW_ACTION);
    if (iOld > 0) NuiDestroy(oPC, iOld);
    int iToken = MEMORIA_NUI_Create(oPC, METACT_BuildActionWindow(oPC), METACT_WINDOW_ACTION, "metact_nuievt");
    if (iToken > 0)
    {
        METACT_RefreshActionEditor(oPC, iToken);
        NuiSetBindWatch(oPC, iToken, "friendly_fire_policy", TRUE);
    }
}

void METACT_OpenActionEditor(object oPC, int iAction)
{
    json jActions = JsonObjectGet(METACT_GetSelectedRule(oPC), "actions");
    json jAction = iAction >= 0 && iAction < JsonGetLength(jActions) ? JsonArrayGet(jActions, iAction) : METACT_NewAction();
    SetLocalInt(oPC, METACT_LOCAL_ACTION, iAction);
    SetLocalJson(oPC, METACT_LOCAL_ACTION_TEMP, jAction);
    SetLocalInt(oPC, METACT_LOCAL_PRIORITY_SCOPE, METACT_PRIORITY_SCOPE_ACTION);
    METACT_ShowActionEditor(oPC);
}

json METACT_PickerSlot(int iSlot, float fWidth)
{
    string sSlot = IntToString(iSlot);
    json jButton = MEMORIA_NUI_Help(NuiId(NuiButtonImage(NuiBind("pick_icon_" + sSlot)), "pick_slot_" + sSlot), NuiBind("pick_tip_" + sSlot));
    return NuiWidth(NuiVisible(jButton, NuiBind("pick_visible_" + sSlot)), fWidth);
}

json METACT_BuildSpellGrid()
{
    json jGrid = JsonArray();
    int iRow;
    for (iRow = 0; iRow < METACT_PICKER_ROWS; iRow++)
    {
        json jIconRow = JsonArray();
        int iColumn;
        for (iColumn = 0; iColumn < METACT_PICKER_COLUMNS; iColumn++) jIconRow = JsonArrayInsert(jIconRow, METACT_PickerSlot(iRow * METACT_PICKER_COLUMNS + iColumn, 40.0f));
        jGrid = JsonArrayInsert(jGrid, NuiHeight(NuiRow(jIconRow), 40.0f));
    }
    return NuiCol(jGrid);
}

json METACT_BuildItemGrid(object oPC, float fAvailableWidth)
{
    json jFiltered = GetLocalJson(oPC, METACT_LOCAL_PICKER_FILTERED);
    int iStart = GetLocalInt(oPC, METACT_LOCAL_PICKER_PAGE) * METACT_PICKER_PAGE_SIZE;
    int iEnd = iStart + METACT_PICKER_PAGE_SIZE;
    if (iEnd > JsonGetLength(jFiltered)) iEnd = JsonGetLength(jFiltered);
    json jRows = JsonArray();
    json jRow = JsonArray();
    float fUsedWidth;
    float fRowHeight;
    int iIndex;
    for (iIndex = iStart; iIndex < iEnd; iIndex++)
    {
        json jCandidate = JsonArrayGet(jFiltered, iIndex);
        float fItemWidth = IntToFloat(JsonGetInt(JsonObjectGet(jCandidate, "width"))) * 40.0f;
        float fItemHeight = IntToFloat(JsonGetInt(JsonObjectGet(jCandidate, "height"))) * 40.0f;
        if (fUsedWidth > 0.0f && (fUsedWidth + fItemWidth > fAvailableWidth || fItemHeight != fRowHeight))
        {
            jRows = JsonArrayInsert(jRows, NuiHeight(NuiRow(jRow), fRowHeight));
            jRow = JsonArray();
            fUsedWidth = 0.0f;
            fRowHeight = 0.0f;
        }
        if (fUsedWidth == 0.0f) fRowHeight = fItemHeight;
        jRow = JsonArrayInsert(jRow, METACT_PickerSlot(iIndex - iStart, fItemWidth));
        fUsedWidth += fItemWidth;
    }
    if (JsonGetLength(jRow) > 0) jRows = JsonArrayInsert(jRows, NuiHeight(NuiRow(jRow), fRowHeight));
    return NuiCol(jRows);
}

json METACT_BuildPickerWindow(object oPC)
{
    float fWidth = METACT_GetWindowWidth(oPC);
    float fHeight = METACT_GetWindowHeight(oPC);
    json jRoot = JsonArray();
    json jSearch = JsonArray();
    jSearch = JsonArrayInsert(jSearch, NuiWidth(METACT_Label(METACT_GetText(METACT_TEXT_SEARCH, oPC)), 65.0f));
    jSearch = JsonArrayInsert(jSearch, NuiWidth(NuiTextEdit(JsonString(""), NuiBind("picker_search"), 80, FALSE), fWidth - 90.0f));
    jRoot = JsonArrayInsert(jRoot, NuiHeight(NuiRow(jSearch), 30.0f));
    json jModes = JsonArray();
    jModes = JsonArrayInsert(jModes, NuiWidth(METACT_IconButton("ir_splbook", "pick_spells", METACT_GetText(METACT_TEXT_SOURCE_SPELL, oPC)), 40.0f));
    jModes = JsonArrayInsert(jModes, NuiWidth(METACT_IconButton("ife_alertness", "pick_feats", METACT_GetText(METACT_TEXT_ABILITIES, oPC)), 40.0f));
    jModes = JsonArrayInsert(jModes, NuiWidth(METACT_IconButton("ir_inventory", "pick_items", METACT_GetText(METACT_TEXT_SOURCE_ITEM, oPC)), 40.0f));
    jModes = JsonArrayInsert(jModes, NuiWidth(METACT_IconButton("ir_equip_r", "pick_equip", METACT_GetText(METACT_TEXT_EQUIP_ITEM, oPC)), 40.0f));
    jModes = JsonArrayInsert(jModes, NuiWidth(METACT_Label(""), 8.0f));
    jModes = JsonArrayInsert(jModes, NuiWidth(NuiLabel(NuiBind("picker_mode_label"), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_MIDDLE)), fWidth - 195.0f));
    jRoot = JsonArrayInsert(jRoot, NuiHeight(NuiRow(jModes), 40.0f));
    string sPickerMode = GetLocalString(oPC, METACT_LOCAL_PICKER_MODE);
    json jGrid = sPickerMode == "item" || sPickerMode == "equip" ? METACT_BuildItemGrid(oPC, fWidth - 32.0f) : METACT_BuildSpellGrid();
    jRoot = JsonArrayInsert(jRoot, NuiHeight(NuiGroup(jGrid, TRUE, sPickerMode == "item" || sPickerMode == "equip" ? NUI_SCROLLBARS_Y : NUI_SCROLLBARS_NONE), fHeight - 157.0f));
    json jPager = JsonArray();
    jPager = JsonArrayInsert(jPager, NuiWidth(METACT_IconButton("nui_cnt_left", "pick_prev", METACT_GetText(METACT_TEXT_PREVIOUS, oPC)), 30.0f));
    jPager = JsonArrayInsert(jPager, NuiSpacer());
    jPager = JsonArrayInsert(jPager, NuiWidth(NuiLabel(NuiBind("picker_page"), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE)), 70.0f));
    jPager = JsonArrayInsert(jPager, NuiSpacer());
    jPager = JsonArrayInsert(jPager, NuiWidth(METACT_IconButton("nui_cnt_right", "pick_next", METACT_GetText(METACT_TEXT_NEXT, oPC)), 30.0f));
    jRoot = JsonArrayInsert(jRoot, NuiHeight(NuiRow(jPager), 30.0f));
    return NuiWindow(NuiCol(jRoot), JsonString(METACT_GetText(METACT_TEXT_PICKER, oPC)), NuiRect(-1.0f, -1.0f, fWidth, fHeight), JsonBool(FALSE), JsonBool(FALSE), JsonBool(TRUE), JsonBool(FALSE), JsonBool(TRUE));
}

void METACT_RefreshPicker(object oPC, int iToken)
{
    string sMode = GetLocalString(oPC, METACT_LOCAL_PICKER_MODE);
    if (sMode != "item" && sMode != "equip" && sMode != "feat") sMode = "spell";
    json jFiltered = METACT_FilterCandidates(GetLocalJson(oPC, METACT_LOCAL_PICKER), NuiGetBind(oPC, iToken, "picker_search"), sMode);
    SetLocalJson(oPC, METACT_LOCAL_PICKER_FILTERED, jFiltered);
    int iPage = GetLocalInt(oPC, METACT_LOCAL_PICKER_PAGE);
    int iPages = (JsonGetLength(jFiltered) + METACT_PICKER_PAGE_SIZE - 1) / METACT_PICKER_PAGE_SIZE;
    if (iPages < 1) iPages = 1;
    if (iPage >= iPages) iPage = iPages - 1;
    if (iPage < 0) iPage = 0;
    SetLocalInt(oPC, METACT_LOCAL_PICKER_PAGE, iPage);
    int iStart = iPage * METACT_PICKER_PAGE_SIZE;
    int iEnd = iStart + METACT_PICKER_PAGE_SIZE;
    if (iEnd > JsonGetLength(jFiltered)) iEnd = JsonGetLength(jFiltered);
    int iSlot;
    for (iSlot = 0; iSlot < METACT_PICKER_PAGE_SIZE; iSlot++)
    {
        int iIndex = iStart + iSlot;
        string sSlot = IntToString(iSlot);
        int bVisible = iIndex < iEnd;
        NuiSetBind(oPC, iToken, "pick_visible_" + sSlot, JsonBool(bVisible));
        if (bVisible)
        {
            json jCandidate = JsonArrayGet(jFiltered, iIndex);
            NuiSetBind(oPC, iToken, "pick_icon_" + sSlot, JsonObjectGet(jCandidate, "icon"));
            string sName = JsonGetString(JsonObjectGet(jCandidate, "name"));
            string sDetail = JsonGetString(JsonObjectGet(jCandidate, "detail"));
            NuiSetBind(oPC, iToken, "pick_tip_" + sSlot, JsonString(sDetail == "" || sDetail == sName ? sName : sName + ": " + sDetail));
        }
        else
        {
            NuiSetBind(oPC, iToken, "pick_icon_" + sSlot, JsonString("nui_empty"));
            NuiSetBind(oPC, iToken, "pick_tip_" + sSlot, JsonString(""));
        }
    }
    NuiSetBind(oPC, iToken, "picker_mode_label", JsonString(METACT_GetText(sMode == "equip" ? METACT_TEXT_EQUIPPABLE_ITEMS : sMode == "item" ? METACT_TEXT_SOURCE_ITEM : sMode == "feat" ? METACT_TEXT_ABILITIES : METACT_TEXT_SOURCE_SPELL, oPC)));
    NuiSetBind(oPC, iToken, "picker_page", JsonString(IntToString(iPage + 1) + " / " + IntToString(iPages)));
}

void METACT_OpenPicker(object oPC, string sMode)
{
    object oActor = GetLocalObject(oPC, METACT_LOCAL_ACTOR);
    if (!GetIsObjectValid(oActor)) return;
    int iActionWindow = NuiFindWindow(oPC, METACT_WINDOW_ACTION);
    if (iActionWindow > 0)
    {
        METACT_StoreActionEditorState(oPC, iActionWindow);
        SetLocalInt(oPC, METACT_LOCAL_ACTION_HIDDEN, TRUE);
        NuiDestroy(oPC, iActionWindow);
    }
    SetLocalJson(oPC, METACT_LOCAL_PICKER, METACT_EnumerateCandidates(oActor));
    SetLocalString(oPC, METACT_LOCAL_PICKER_MODE, sMode == "equip" ? "equip" : sMode == "item" ? "item" : sMode == "feat" ? "feat" : "spell");
    SetLocalInt(oPC, METACT_LOCAL_PICKER_PAGE, 0);
    SetLocalJson(oPC, METACT_LOCAL_PICKER_FILTERED, METACT_FilterCandidates(GetLocalJson(oPC, METACT_LOCAL_PICKER), JsonString(""), GetLocalString(oPC, METACT_LOCAL_PICKER_MODE)));
    int iOld = NuiFindWindow(oPC, METACT_WINDOW_PICKER);
    if (iOld > 0) NuiDestroy(oPC, iOld);
    int iToken = MEMORIA_NUI_Create(oPC, METACT_BuildPickerWindow(oPC), METACT_WINDOW_PICKER, "metact_nuievt");
    if (iToken <= 0)
    {
        DeleteLocalJson(oPC, METACT_LOCAL_PICKER);
        DeleteLocalJson(oPC, METACT_LOCAL_PICKER_FILTERED);
        DeleteLocalString(oPC, METACT_LOCAL_PICKER_MODE);
        METACT_ShowActionEditor(oPC);
        return;
    }
    NuiSetBind(oPC, iToken, "picker_search", JsonString(""));
    METACT_RefreshPicker(oPC, iToken);
    NuiSetBindWatch(oPC, iToken, "picker_search", TRUE);
}

void METACT_RecreatePicker(object oPC, int iOldToken)
{
    json jSearch = NuiGetBind(oPC, iOldToken, "picker_search");
    json jFiltered = METACT_FilterCandidates(GetLocalJson(oPC, METACT_LOCAL_PICKER), jSearch, GetLocalString(oPC, METACT_LOCAL_PICKER_MODE));
    SetLocalJson(oPC, METACT_LOCAL_PICKER_FILTERED, jFiltered);
    int iPages = (JsonGetLength(jFiltered) + METACT_PICKER_PAGE_SIZE - 1) / METACT_PICKER_PAGE_SIZE;
    if (iPages < 1) iPages = 1;
    int iPage = GetLocalInt(oPC, METACT_LOCAL_PICKER_PAGE);
    if (iPage >= iPages) iPage = iPages - 1;
    if (iPage < 0) iPage = 0;
    SetLocalInt(oPC, METACT_LOCAL_PICKER_PAGE, iPage);
    NuiDestroy(oPC, iOldToken);
    int iToken = MEMORIA_NUI_Create(oPC, METACT_BuildPickerWindow(oPC), METACT_WINDOW_PICKER, "metact_nuievt");
    if (iToken <= 0) return;
    NuiSetBind(oPC, iToken, "picker_search", jSearch);
    METACT_RefreshPicker(oPC, iToken);
    NuiSetBindWatch(oPC, iToken, "picker_search", TRUE);
}
