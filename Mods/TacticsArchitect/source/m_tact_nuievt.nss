#include "m_tact_ui"

void M_TACT_SelectActor(object oPC, int iToken)
{
    int iIndex = JsonGetInt(NuiGetBind(oPC, iToken, "actor_sel"));
    object oActor = M_TACT_GetGroupMember(oPC, iIndex);
    if (!GetIsObjectValid(oActor)) return;
    SetLocalObject(oPC, M_TACT_LOCAL_ACTOR, oActor);
    SetLocalInt(oPC, M_TACT_LOCAL_SCOPE, oActor == oPC ? M_TACT_SCOPE_PC : M_TACT_SCOPE_EXACT);
    SetLocalInt(oPC, M_TACT_LOCAL_TACTIC, -1);
    SetLocalInt(oPC, M_TACT_LOCAL_RULE, -1);
    SetLocalInt(oPC, M_TACT_LOCAL_RULE_PAGE, 0);
    M_TACT_RefreshMain(oPC, iToken);
}

void M_TACT_SetDebug(object oPC, int iToken)
{
    M_TACT_SetDebugEnabled(oPC, JsonGetInt(NuiGetBind(oPC, iToken, "debug_enabled")));
}

void M_TACT_SelectScope(object oPC, int iToken)
{
    object oActor = GetLocalObject(oPC, M_TACT_LOCAL_ACTOR);
    if (!GetIsObjectValid(oActor) || oActor == oPC) return;
    int iScope = JsonGetInt(NuiGetBind(oPC, iToken, "scope_sel"));
    if (iScope != M_TACT_SCOPE_EXACT && iScope != M_TACT_SCOPE_TYPE) return;
    SetLocalInt(oPC, M_TACT_LOCAL_SCOPE, iScope);
    SetLocalInt(oPC, M_TACT_LOCAL_TACTIC, -1);
    SetLocalInt(oPC, M_TACT_LOCAL_RULE, -1);
    SetLocalInt(oPC, M_TACT_LOCAL_RULE_PAGE, 0);
    M_TACT_RefreshMain(oPC, iToken);
}

void M_TACT_SelectTactic(object oPC, int iToken)
{
    int iTactic = JsonGetInt(NuiGetBind(oPC, iToken, "tactic_sel"));
    json jProfile = M_TACT_GetSelectedProfile(oPC);
    json jTactics = JsonObjectGet(jProfile, "tactics");
    if (iTactic < 0 || iTactic >= JsonGetLength(jTactics)) return;
    SetLocalInt(oPC, M_TACT_LOCAL_TACTIC, iTactic);
    SetLocalInt(oPC, M_TACT_LOCAL_RULE, -1);
    SetLocalInt(oPC, M_TACT_LOCAL_RULE_PAGE, 0);
    jProfile = JsonObjectSet(jProfile, "active", JsonInt(iTactic));
    M_TACT_SetProfile(oPC, GetLocalInt(oPC, M_TACT_LOCAL_PROFILE), jProfile);
    M_TACT_RefreshMain(oPC, iToken);
}

void M_TACT_SetTacticEnabled(object oPC, int iToken)
{
    json jTactic = M_TACT_GetSelectedTactic(oPC);
    jTactic = JsonObjectSet(jTactic, "enabled", JsonBool(JsonGetInt(NuiGetBind(oPC, iToken, "tactic_enabled"))));
    M_TACT_SaveSelectedTactic(oPC, jTactic);
}

void M_TACT_NewTacticForProfile(object oPC, int iToken)
{
    int iProfile = GetLocalInt(oPC, M_TACT_LOCAL_PROFILE);
    json jProfile = M_TACT_GetProfile(oPC, iProfile);
    json jTactics = JsonArrayInsert(JsonObjectGet(jProfile, "tactics"), M_TACT_NewTactic(oPC));
    int iTactic = JsonGetLength(jTactics) - 1;
    jProfile = JsonObjectSet(jProfile, "tactics", jTactics);
    jProfile = JsonObjectSet(jProfile, "active", JsonInt(iTactic));
    M_TACT_SetProfile(oPC, iProfile, jProfile);
    SetLocalInt(oPC, M_TACT_LOCAL_TACTIC, iTactic);
    SetLocalInt(oPC, M_TACT_LOCAL_RULE, -1);
    SetLocalInt(oPC, M_TACT_LOCAL_RULE_PAGE, 0);
    M_TACT_RefreshMain(oPC, iToken);
}

void M_TACT_DeleteTactic(object oPC, int iToken)
{
    int iProfile = GetLocalInt(oPC, M_TACT_LOCAL_PROFILE);
    json jProfile = M_TACT_GetProfile(oPC, iProfile);
    json jTactics = JsonObjectGet(jProfile, "tactics");
    int iTactic = GetLocalInt(oPC, M_TACT_LOCAL_TACTIC);
    if (JsonGetLength(jTactics) <= 1) return;
    jTactics = JsonArrayDel(jTactics, iTactic);
    if (iTactic >= JsonGetLength(jTactics)) iTactic = JsonGetLength(jTactics) - 1;
    jProfile = JsonObjectSet(jProfile, "tactics", jTactics);
    jProfile = JsonObjectSet(jProfile, "active", JsonInt(iTactic));
    M_TACT_SetProfile(oPC, iProfile, jProfile);
    SetLocalInt(oPC, M_TACT_LOCAL_TACTIC, iTactic);
    SetLocalInt(oPC, M_TACT_LOCAL_RULE, -1);
    SetLocalInt(oPC, M_TACT_LOCAL_RULE_PAGE, 0);
    M_TACT_RefreshMain(oPC, iToken);
}

void M_TACT_RenameTactic(object oPC, int iToken)
{
    json jName = NuiGetBind(oPC, iToken, "tactic_name");
    if (JsonGetType(jName) != JSON_TYPE_STRING || M_TACT_JsonSearchText(jName) == "") return;
    json jTactic = JsonObjectSet(M_TACT_GetSelectedTactic(oPC), "name", jName);
    M_TACT_SaveSelectedTactic(oPC, jTactic);
    M_TACT_RefreshMain(oPC, iToken);
}

int M_TACT_GetClickedRule(object oPC)
{
    return NuiGetEventArrayIndex();
}

int M_TACT_GetClickedAction()
{
    return NuiGetEventArrayIndex();
}

int M_TACT_GetClickedPriority()
{
    return NuiGetEventArrayIndex();
}

void M_TACT_RefreshPriorityOwner(object oPC)
{
    int iScope = GetLocalInt(oPC, M_TACT_LOCAL_PRIORITY_SCOPE);
    int iOwner = NuiFindWindow(oPC, iScope == M_TACT_PRIORITY_SCOPE_ACTION ? M_TACT_WINDOW_ACTION : iScope == M_TACT_PRIORITY_SCOPE_RULE ? M_TACT_WINDOW_RULE : M_TACT_WINDOW_MAIN);
    if (iOwner <= 0) return;
    if (iScope == M_TACT_PRIORITY_SCOPE_ACTION) M_TACT_RefreshActionEditor(oPC, iOwner);
    else if (iScope == M_TACT_PRIORITY_SCOPE_RULE) M_TACT_RefreshRuleEditor(oPC, iOwner);
    else M_TACT_RefreshMain(oPC, iOwner);
}

void M_TACT_OpenScopedPriorityEditor(object oPC, int iScope, int iPriority)
{
    SetLocalInt(oPC, M_TACT_LOCAL_PRIORITY_SCOPE, iScope);
    M_TACT_OpenPriorityEditor(oPC, iPriority);
}

void M_TACT_SavePriority(object oPC, int iToken)
{
    int iPriority = GetLocalInt(oPC, M_TACT_LOCAL_PRIORITY);
    string sKind = M_TACT_PriorityKindFromIndex(JsonGetInt(NuiGetBind(oPC, iToken, "priority_kind")));
    json jPriorities = M_TACT_GetEditablePriorities(oPC);
    if (M_TACT_HasPriorityKind(jPriorities, sKind, iPriority))
    {
        SendMessageToPC(oPC, M_TACT_GetText(M_TACT_TEXT_INVALID, oPC));
        return;
    }
    json jPriority = GetLocalJson(oPC, M_TACT_LOCAL_PRIORITY_TEMP);
    jPriority = JsonObjectSet(jPriority, "kind", JsonString(sKind));
    jPriority = JsonObjectSet(jPriority, "enabled", JsonBool(JsonGetInt(NuiGetBind(oPC, iToken, "priority_enabled"))));
    jPriorities = iPriority >= 0 && iPriority < JsonGetLength(jPriorities) ? JsonArraySet(jPriorities, iPriority, jPriority) : JsonArrayInsert(jPriorities, jPriority);
    M_TACT_SaveEditablePriorities(oPC, jPriorities);
    DeleteLocalJson(oPC, M_TACT_LOCAL_PRIORITY_TEMP);
    NuiDestroy(oPC, iToken);
    M_TACT_RefreshPriorityOwner(oPC);
}

void M_TACT_MovePriority(object oPC, int iPriority, int iDirection)
{
    json jPriorities = M_TACT_GetEditablePriorities(oPC);
    int iOther = iPriority + iDirection;
    if (JsonGetType(jPriorities) != JSON_TYPE_ARRAY || iPriority < 0 || iPriority >= JsonGetLength(jPriorities) || iOther < 0 || iOther >= JsonGetLength(jPriorities)) return;
    json jStored = JsonArrayGet(jPriorities, iPriority);
    jPriorities = JsonArraySet(jPriorities, iPriority, JsonArrayGet(jPriorities, iOther));
    jPriorities = JsonArraySet(jPriorities, iOther, jStored);
    M_TACT_SaveEditablePriorities(oPC, jPriorities);
    SetLocalInt(oPC, M_TACT_LOCAL_PRIORITY, iOther);
    M_TACT_RefreshPriorityOwner(oPC);
}

void M_TACT_MoveScopedPriority(object oPC, int iScope, int iPriority, int iDirection)
{
    SetLocalInt(oPC, M_TACT_LOCAL_PRIORITY_SCOPE, iScope);
    M_TACT_MovePriority(oPC, iPriority, iDirection);
}

void M_TACT_MoveEditedPriority(object oPC, int iToken, int iDirection)
{
    M_TACT_MovePriority(oPC, GetLocalInt(oPC, M_TACT_LOCAL_PRIORITY), iDirection);
    M_TACT_RefreshPriorityEditor(oPC, iToken);
}

void M_TACT_DeleteEditedPriority(object oPC, int iToken)
{
    int iPriority = GetLocalInt(oPC, M_TACT_LOCAL_PRIORITY);
    json jPriorities = M_TACT_GetEditablePriorities(oPC);
    if (JsonGetType(jPriorities) != JSON_TYPE_ARRAY || iPriority < 0 || iPriority >= JsonGetLength(jPriorities)) return;
    M_TACT_SaveEditablePriorities(oPC, JsonArrayDel(jPriorities, iPriority));
    DeleteLocalJson(oPC, M_TACT_LOCAL_PRIORITY_TEMP);
    NuiDestroy(oPC, iToken);
    M_TACT_RefreshPriorityOwner(oPC);
}

void M_TACT_MoveRule(object oPC, int iRule, int iDirection)
{
    json jTactic = M_TACT_GetSelectedTactic(oPC);
    json jRules = JsonObjectGet(jTactic, "rules");
    int iOther = iRule + iDirection;
    if (iRule < 0 || iRule >= JsonGetLength(jRules) || iOther < 0 || iOther >= JsonGetLength(jRules)) return;
    json jStored = JsonArrayGet(jRules, iRule);
    jRules = JsonArraySet(jRules, iRule, JsonArrayGet(jRules, iOther));
    jRules = JsonArraySet(jRules, iOther, jStored);
    M_TACT_SaveSelectedTactic(oPC, JsonObjectSet(jTactic, "rules", jRules));
    SetLocalInt(oPC, M_TACT_LOCAL_RULE, iOther);
    int iMain = NuiFindWindow(oPC, M_TACT_WINDOW_MAIN);
    if (iMain > 0) M_TACT_RefreshMain(oPC, iMain);
}

void M_TACT_DeleteEditedRule(object oPC, int iToken)
{
    int iRule = GetLocalInt(oPC, M_TACT_LOCAL_RULE);
    json jTactic = M_TACT_GetSelectedTactic(oPC);
    json jRules = JsonObjectGet(jTactic, "rules");
    if (iRule < 0 || iRule >= JsonGetLength(jRules)) return;
    M_TACT_SaveSelectedTactic(oPC, JsonObjectSet(jTactic, "rules", JsonArrayDel(jRules, iRule)));
    DeleteLocalJson(oPC, M_TACT_LOCAL_RULE_TEMP);
    NuiDestroy(oPC, iToken);
    int iMain = NuiFindWindow(oPC, M_TACT_WINDOW_MAIN);
    if (iMain > 0) M_TACT_RefreshMain(oPC, iMain);
}

string M_TACT_SourceFromIndex(int iSource)
{
    return iSource == 1 ? "spell" : iSource == 2 ? "item" : "any";
}

void M_TACT_SaveRule(object oPC, int iToken)
{
    json jRule = GetLocalJson(oPC, M_TACT_LOCAL_RULE_TEMP);
    string sValue = RegExpReplace(",", JsonGetString(NuiGetBind(oPC, iToken, "condition_value")), ".");
    string sRadius = RegExpReplace(",", JsonGetString(NuiGetBind(oPC, iToken, "condition_radius")), ".");
    int iCondition = JsonGetInt(NuiGetBind(oPC, iToken, "condition_sel"));
    int bRating = iCondition == 6;
    int bUsesValue = iCondition >= 1 && iCondition <= 3;
    int bUsesRadius = iCondition == 1 || iCondition == 3 || iCondition == 6;
    int iValue = bRating ? JsonGetInt(NuiGetBind(oPC, iToken, "rating_sel")) : bUsesValue ? StringToInt(sValue) : 1;
    float fRadius = StringToFloat(sRadius);
    if (fRadius <= 0.0f) fRadius = 20.0f;
    if ((bRating && (iValue < 0 || iValue > 6)) || (bUsesValue && (iValue < 1 || iValue > 100)) || (bUsesRadius && (fRadius < 0.1f || fRadius > 100.0f)))
    {
        SendMessageToPC(oPC, M_TACT_GetText(M_TACT_TEXT_INVALID, oPC));
        return;
    }
    jRule = JsonObjectSet(jRule, "enabled", JsonBool(JsonGetInt(NuiGetBind(oPC, iToken, "rule_enabled"))));
    json jCondition = JsonObjectGet(jRule, "condition");
    jCondition = JsonObjectSet(jCondition, "kind", JsonString(M_TACT_IndexToCondition(iCondition)));
    jCondition = JsonObjectSet(jCondition, "value", JsonInt(iValue));
    jCondition = JsonObjectSet(jCondition, "radius", JsonFloat(fRadius));
    jCondition = JsonObjectSet(jCondition, "comparison", JsonString(JsonGetInt(NuiGetBind(oPC, iToken, "comparison_sel")) == 1 ? "max" : "min"));
    jCondition = JsonObjectSet(jCondition, "subject", JsonString(JsonGetInt(NuiGetBind(oPC, iToken, "subject_sel")) == 1 ? "ally" : "self"));
    jRule = JsonObjectSet(jRule, "condition", jCondition);
    json jTactic = M_TACT_GetSelectedTactic(oPC);
    json jRules = JsonObjectGet(jTactic, "rules");
    int iRule = GetLocalInt(oPC, M_TACT_LOCAL_RULE);
    jRules = iRule >= 0 && iRule < JsonGetLength(jRules) ? JsonArraySet(jRules, iRule, jRule) : JsonArrayInsert(jRules, jRule);
    if (iRule < 0) SetLocalInt(oPC, M_TACT_LOCAL_RULE, JsonGetLength(jRules) - 1);
    M_TACT_SaveSelectedTactic(oPC, JsonObjectSet(jTactic, "rules", jRules));
    DeleteLocalJson(oPC, M_TACT_LOCAL_RULE_TEMP);
    NuiDestroy(oPC, iToken);
    int iMain = NuiFindWindow(oPC, M_TACT_WINDOW_MAIN);
    if (iMain > 0) M_TACT_RefreshMain(oPC, iMain);
}

void M_TACT_SaveAction(object oPC, int iToken)
{
    json jAction = GetLocalJson(oPC, M_TACT_LOCAL_ACTION_TEMP);
    if (JsonGetString(JsonObjectGet(jAction, "kind")) == "") { SendMessageToPC(oPC, M_TACT_GetText(M_TACT_TEXT_SELECT_POWER, oPC)); return; }
    jAction = JsonObjectSet(jAction, "enabled", JsonBool(JsonGetInt(NuiGetBind(oPC, iToken, "action_enabled"))));
    jAction = JsonObjectSet(jAction, "target", JsonString(M_TACT_IndexToTarget(JsonGetInt(NuiGetBind(oPC, iToken, "target_sel")))));
    jAction = JsonObjectSet(jAction, "source", JsonString(M_TACT_SourceFromIndex(JsonGetInt(NuiGetBind(oPC, iToken, "source_sel")))));
    jAction = JsonObjectSet(jAction, "move", JsonBool(JsonGetInt(NuiGetBind(oPC, iToken, "allow_move"))));
    int iFriendlyFirePolicy = JsonGetInt(NuiGetBind(oPC, iToken, "friendly_fire_policy"));
    if (iFriendlyFirePolicy < 0 || iFriendlyFirePolicy > 3) iFriendlyFirePolicy = 1;
    jAction = JsonObjectSet(jAction, "friendly_fire", JsonBool(iFriendlyFirePolicy == 0));
    jAction = JsonObjectSet(jAction, "aoe_safety", JsonInt(iFriendlyFirePolicy == 0 ? M_TACT_AOE_SAFETY_SAFE : iFriendlyFirePolicy));
    json jRule = M_TACT_GetSelectedRule(oPC);
    json jActions = JsonObjectGet(jRule, "actions");
    int iAction = GetLocalInt(oPC, M_TACT_LOCAL_ACTION);
    jActions = iAction >= 0 && iAction < JsonGetLength(jActions) ? JsonArraySet(jActions, iAction, jAction) : JsonArrayInsert(jActions, jAction);
    M_TACT_SaveSelectedRule(oPC, JsonObjectSet(jRule, "actions", jActions));
    DeleteLocalJson(oPC, M_TACT_LOCAL_ACTION_TEMP);
    NuiDestroy(oPC, iToken);
    int iMain = NuiFindWindow(oPC, M_TACT_WINDOW_MAIN);
    if (iMain > 0) M_TACT_RefreshMain(oPC, iMain);
}

void M_TACT_SelectSpecialAction(object oPC, int iToken, string sKind)
{
    json jAction = GetLocalJson(oPC, M_TACT_LOCAL_ACTION_TEMP);
    jAction = JsonObjectSet(jAction, "kind", JsonString(sKind));
    jAction = JsonObjectSet(jAction, "spell", JsonInt(-1));
    jAction = JsonObjectSet(jAction, "target", JsonString(sKind == "familiar" ? "self" : "auto"));
    SetLocalJson(oPC, M_TACT_LOCAL_ACTION_TEMP, jAction);
    M_TACT_RefreshActionEditor(oPC, iToken);
}

void M_TACT_SelectCandidate(object oPC, int iToken, int iSlot)
{
    json jFiltered = GetLocalJson(oPC, M_TACT_LOCAL_PICKER_FILTERED);
    int iIndex = GetLocalInt(oPC, M_TACT_LOCAL_PICKER_PAGE) * M_TACT_PICKER_PAGE_SIZE + iSlot;
    if (iIndex < 0 || iIndex >= JsonGetLength(jFiltered)) return;
    json jCandidate = JsonArrayGet(jFiltered, iIndex);
    json jAction = GetLocalJson(oPC, M_TACT_LOCAL_ACTION_TEMP);
    string sCandidateType = JsonGetString(JsonObjectGet(jCandidate, "type"));
    jAction = JsonObjectSet(jAction, "kind", JsonString(sCandidateType == "equip" ? "equip" : "spell"));
    jAction = JsonObjectSet(jAction, "spell", JsonObjectGet(jCandidate, "spell"));
    jAction = JsonObjectSet(jAction, "class", JsonObjectGet(jCandidate, "class"));
    jAction = JsonObjectSet(jAction, "level", JsonObjectGet(jCandidate, "level"));
    jAction = JsonObjectSet(jAction, "metamagic", JsonObjectGet(jCandidate, "metamagic"));
    jAction = JsonObjectSet(jAction, "domain", JsonObjectGet(jCandidate, "domain"));
    jAction = JsonObjectSet(jAction, "item_resref", JsonObjectGet(jCandidate, "item_resref"));
    jAction = JsonObjectSet(jAction, "item_uuid", sCandidateType == "equip" ? JsonObjectGet(jCandidate, "item_uuid") : JsonString(""));
    jAction = JsonObjectSet(jAction, "item_name", sCandidateType == "equip" ? JsonObjectGet(jCandidate, "name") : JsonString(""));
    jAction = JsonObjectSet(jAction, "item_icon", sCandidateType == "equip" ? JsonObjectGet(jCandidate, "icon") : JsonString(""));
    jAction = JsonObjectSet(jAction, "item_property", JsonObjectGet(jCandidate, "item_property"));
    jAction = JsonObjectSet(jAction, "source", JsonString(sCandidateType == "item" || sCandidateType == "equip" ? "item" : "spell"));
    if (sCandidateType == "equip") jAction = JsonObjectSet(jAction, "target", JsonString("self"));
    SetLocalJson(oPC, M_TACT_LOCAL_ACTION_TEMP, jAction);
    DeleteLocalJson(oPC, M_TACT_LOCAL_PICKER);
    DeleteLocalJson(oPC, M_TACT_LOCAL_PICKER_FILTERED);
    DeleteLocalString(oPC, M_TACT_LOCAL_PICKER_MODE);
    NuiDestroy(oPC, iToken);
    int iActionWindow = NuiFindWindow(oPC, M_TACT_WINDOW_ACTION);
    if (iActionWindow > 0) M_TACT_RefreshActionEditor(oPC, iActionWindow);
}

void M_TACT_SelectRule(object oPC, int iToken, int iRule)
{
    json jRules = JsonObjectGet(M_TACT_GetSelectedTactic(oPC), "rules");
    if (iRule < 0 || iRule >= JsonGetLength(jRules)) return;
    SetLocalInt(oPC, M_TACT_LOCAL_RULE, iRule);
    M_TACT_RefreshMain(oPC, iToken);
}

void M_TACT_MoveAction(object oPC, int iAction, int iDirection)
{
    json jRule = M_TACT_GetSelectedRule(oPC);
    json jActions = JsonObjectGet(jRule, "actions");
    int iOther = iAction + iDirection;
    if (iAction < 0 || iAction >= JsonGetLength(jActions) || iOther < 0 || iOther >= JsonGetLength(jActions)) return;
    json jStored = JsonArrayGet(jActions, iAction);
    jActions = JsonArraySet(jActions, iAction, JsonArrayGet(jActions, iOther));
    jActions = JsonArraySet(jActions, iOther, jStored);
    M_TACT_SaveSelectedRule(oPC, JsonObjectSet(jRule, "actions", jActions));
    int iMain = NuiFindWindow(oPC, M_TACT_WINDOW_MAIN);
    if (iMain > 0) M_TACT_RefreshMain(oPC, iMain);
}

void M_TACT_DeleteEditedAction(object oPC, int iToken)
{
    int iAction = GetLocalInt(oPC, M_TACT_LOCAL_ACTION);
    json jRule = M_TACT_GetSelectedRule(oPC);
    json jActions = JsonObjectGet(jRule, "actions");
    if (iAction < 0 || iAction >= JsonGetLength(jActions)) return;
    M_TACT_SaveSelectedRule(oPC, JsonObjectSet(jRule, "actions", JsonArrayDel(jActions, iAction)));
    DeleteLocalJson(oPC, M_TACT_LOCAL_ACTION_TEMP);
    NuiDestroy(oPC, iToken);
    int iMain = NuiFindWindow(oPC, M_TACT_WINDOW_MAIN);
    if (iMain > 0) M_TACT_RefreshMain(oPC, iMain);
}

void M_TACT_StartNewAction(object oPC, string sKind)
{
    if (JsonGetType(M_TACT_GetSelectedRule(oPC)) != JSON_TYPE_OBJECT) { SendMessageToPC(oPC, M_TACT_GetText(M_TACT_TEXT_INVALID, oPC)); return; }
    M_TACT_OpenActionEditor(oPC, -1);
    int iActionWindow = NuiFindWindow(oPC, M_TACT_WINDOW_ACTION);
    if (sKind == "spell" || sKind == "item" || sKind == "equip") M_TACT_OpenPicker(oPC, sKind);
    else if (iActionWindow > 0) M_TACT_SelectSpecialAction(oPC, iActionWindow, sKind);
}

void M_TACT_HandleWatch(object oPC, int iToken, string sWindow, string sElement)
{
    if (sWindow == M_TACT_WINDOW_MAIN)
    {
        if (sElement == "actor_sel") M_TACT_SelectActor(oPC, iToken);
        else if (sElement == "scope_sel") M_TACT_SelectScope(oPC, iToken);
        else if (sElement == "tactic_sel") M_TACT_SelectTactic(oPC, iToken);
        else if (sElement == "tactic_enabled") M_TACT_SetTacticEnabled(oPC, iToken);
        else if (sElement == "debug_enabled") M_TACT_SetDebug(oPC, iToken);
    }
    else if (sWindow == M_TACT_WINDOW_PICKER && sElement == "picker_search")
    {
        SetLocalInt(oPC, M_TACT_LOCAL_PICKER_PAGE, 0);
        M_TACT_RefreshPicker(oPC, iToken);
    }
    else if (sWindow == M_TACT_WINDOW_RULE && sElement == "condition_sel") M_TACT_RefreshConditionMode(oPC, iToken);
    else if (sWindow == M_TACT_WINDOW_ACTION && sElement == "friendly_fire_policy")
    {
        int iPolicy = JsonGetInt(NuiGetBind(oPC, iToken, "friendly_fire_policy"));
        if (iPolicy < 0 || iPolicy > 3) iPolicy = 1;
        NuiSetBind(oPC, iToken, "friendly_fire_policy_help", JsonString(M_TACT_GetText(M_TACT_TEXT_FRIENDLY_FIRE_UNRESTRICTED_HELP + iPolicy, oPC)));
    }
}

void M_TACT_HandleClick(object oPC, int iToken, string sWindow, string sElement)
{
    if (sWindow == M_TACT_WINDOW_MAIN)
    {
        if (sElement == "close") NuiDestroy(oPC, iToken);
        else if (sElement == "tactic_new") M_TACT_NewTacticForProfile(oPC, iToken);
        else if (sElement == "tactic_delete") M_TACT_DeleteTactic(oPC, iToken);
        else if (sElement == "tactic_rename") M_TACT_RenameTactic(oPC, iToken);
        else if (sElement == "rule_add") M_TACT_OpenRuleEditor(oPC, -1);
        else if (sElement == "rule_select") M_TACT_SelectRule(oPC, iToken, M_TACT_GetClickedRule(oPC));
        else if (sElement == "rule_edit") { SetLocalInt(oPC, M_TACT_LOCAL_RULE, M_TACT_GetClickedRule(oPC)); M_TACT_OpenRuleEditor(oPC, GetLocalInt(oPC, M_TACT_LOCAL_RULE)); }
        else if (sElement == "rule_up") M_TACT_MoveRule(oPC, M_TACT_GetClickedRule(oPC), -1);
        else if (sElement == "rule_down") M_TACT_MoveRule(oPC, M_TACT_GetClickedRule(oPC), 1);
        else if (sElement == "action_edit") M_TACT_OpenActionEditor(oPC, M_TACT_GetClickedAction());
        else if (sElement == "action_up") M_TACT_MoveAction(oPC, M_TACT_GetClickedAction(), -1);
        else if (sElement == "action_down") M_TACT_MoveAction(oPC, M_TACT_GetClickedAction(), 1);
        else if (sElement == "action_add_spell") M_TACT_StartNewAction(oPC, "spell");
        else if (sElement == "action_add_item") M_TACT_StartNewAction(oPC, "item");
        else if (sElement == "action_add_equip") M_TACT_StartNewAction(oPC, "equip");
        else if (sElement == "action_add_familiar") M_TACT_StartNewAction(oPC, "familiar");
        else if (sElement == "action_add_attack") M_TACT_StartNewAction(oPC, "attack");
        else if (sElement == "priority_add") M_TACT_OpenScopedPriorityEditor(oPC, M_TACT_PRIORITY_SCOPE_GLOBAL, -1);
        else if (sElement == "priority_edit") M_TACT_OpenScopedPriorityEditor(oPC, M_TACT_PRIORITY_SCOPE_GLOBAL, M_TACT_GetClickedPriority());
        else if (sElement == "priority_up") M_TACT_MoveScopedPriority(oPC, M_TACT_PRIORITY_SCOPE_GLOBAL, M_TACT_GetClickedPriority(), -1);
        else if (sElement == "priority_down") M_TACT_MoveScopedPriority(oPC, M_TACT_PRIORITY_SCOPE_GLOBAL, M_TACT_GetClickedPriority(), 1);
        else if (sElement == "debug_target")
        {
            SetLocalInt(oPC, M_TACT_LOCAL_DEBUG_TARGETING, TRUE);
            NuiDestroy(oPC, iToken);
            SendMessageToPC(oPC, M_TACT_GetText(M_TACT_TEXT_INSPECT_PROMPT, oPC));
            EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE, MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
        }
    }
    else if (sWindow == M_TACT_WINDOW_PRIORITY)
    {
        if (sElement == "priority_cancel") { DeleteLocalJson(oPC, M_TACT_LOCAL_PRIORITY_TEMP); NuiDestroy(oPC, iToken); }
        else if (sElement == "priority_save") M_TACT_SavePriority(oPC, iToken);
        else if (sElement == "priority_move_up") M_TACT_MoveEditedPriority(oPC, iToken, -1);
        else if (sElement == "priority_move_down") M_TACT_MoveEditedPriority(oPC, iToken, 1);
        else if (sElement == "priority_remove") M_TACT_DeleteEditedPriority(oPC, iToken);
    }
    else if (sWindow == M_TACT_WINDOW_RULE)
    {
        if (sElement == "rule_cancel") { DeleteLocalJson(oPC, M_TACT_LOCAL_RULE_TEMP); NuiDestroy(oPC, iToken); }
        else if (sElement == "rule_save") M_TACT_SaveRule(oPC, iToken);
        else if (sElement == "rule_remove") M_TACT_DeleteEditedRule(oPC, iToken);
        else if (sElement == "priority_add") M_TACT_OpenScopedPriorityEditor(oPC, M_TACT_PRIORITY_SCOPE_RULE, -1);
        else if (sElement == "priority_edit") M_TACT_OpenScopedPriorityEditor(oPC, M_TACT_PRIORITY_SCOPE_RULE, M_TACT_GetClickedPriority());
        else if (sElement == "priority_up") M_TACT_MoveScopedPriority(oPC, M_TACT_PRIORITY_SCOPE_RULE, M_TACT_GetClickedPriority(), -1);
        else if (sElement == "priority_down") M_TACT_MoveScopedPriority(oPC, M_TACT_PRIORITY_SCOPE_RULE, M_TACT_GetClickedPriority(), 1);
    }
    else if (sWindow == M_TACT_WINDOW_ACTION)
    {
        if (sElement == "action_cancel") { DeleteLocalJson(oPC, M_TACT_LOCAL_ACTION_TEMP); NuiDestroy(oPC, iToken); }
        else if (sElement == "action_save") M_TACT_SaveAction(oPC, iToken);
        else if (sElement == "action_remove") M_TACT_DeleteEditedAction(oPC, iToken);
        else if (sElement == "choose_spell") M_TACT_OpenPicker(oPC, "spell");
        else if (sElement == "choose_item") M_TACT_OpenPicker(oPC, "item");
        else if (sElement == "choose_equip") M_TACT_OpenPicker(oPC, "equip");
        else if (sElement == "choose_familiar") M_TACT_SelectSpecialAction(oPC, iToken, "familiar");
        else if (sElement == "choose_attack") M_TACT_SelectSpecialAction(oPC, iToken, "attack");
        else if (sElement == "priority_add") M_TACT_OpenScopedPriorityEditor(oPC, M_TACT_PRIORITY_SCOPE_ACTION, -1);
        else if (sElement == "priority_edit") M_TACT_OpenScopedPriorityEditor(oPC, M_TACT_PRIORITY_SCOPE_ACTION, M_TACT_GetClickedPriority());
        else if (sElement == "priority_up") M_TACT_MoveScopedPriority(oPC, M_TACT_PRIORITY_SCOPE_ACTION, M_TACT_GetClickedPriority(), -1);
        else if (sElement == "priority_down") M_TACT_MoveScopedPriority(oPC, M_TACT_PRIORITY_SCOPE_ACTION, M_TACT_GetClickedPriority(), 1);
    }
    else if (sWindow == M_TACT_WINDOW_PICKER)
    {
        if (sElement == "pick_spells") { SetLocalString(oPC, M_TACT_LOCAL_PICKER_MODE, "spell"); SetLocalInt(oPC, M_TACT_LOCAL_PICKER_PAGE, 0); M_TACT_RecreatePicker(oPC, iToken); }
        else if (sElement == "pick_items") { SetLocalString(oPC, M_TACT_LOCAL_PICKER_MODE, "item"); SetLocalInt(oPC, M_TACT_LOCAL_PICKER_PAGE, 0); M_TACT_RecreatePicker(oPC, iToken); }
        else if (sElement == "pick_equip") { SetLocalString(oPC, M_TACT_LOCAL_PICKER_MODE, "equip"); SetLocalInt(oPC, M_TACT_LOCAL_PICKER_PAGE, 0); M_TACT_RecreatePicker(oPC, iToken); }
        else if (sElement == "pick_prev") { SetLocalInt(oPC, M_TACT_LOCAL_PICKER_PAGE, GetLocalInt(oPC, M_TACT_LOCAL_PICKER_PAGE) - 1); M_TACT_RecreatePicker(oPC, iToken); }
        else if (sElement == "pick_next") { SetLocalInt(oPC, M_TACT_LOCAL_PICKER_PAGE, GetLocalInt(oPC, M_TACT_LOCAL_PICKER_PAGE) + 1); M_TACT_RecreatePicker(oPC, iToken); }
        else if (GetSubString(sElement, 0, 10) == "pick_slot_") M_TACT_SelectCandidate(oPC, iToken, StringToInt(GetSubString(sElement, 10, GetStringLength(sElement) - 10)));
    }
}

void main()
{
    object oPC = NuiGetEventPlayer();
    int iToken = NuiGetEventWindow();
    string sWindow = NuiGetWindowId(oPC, iToken);
    string sEvent = NuiGetEventType();
    string sElement = NuiGetEventElement();
    if (sEvent == "watch") M_TACT_HandleWatch(oPC, iToken, sWindow, sElement);
    else if (sEvent == "click") M_TACT_HandleClick(oPC, iToken, sWindow, sElement);
    else if (sEvent == "close" && sWindow == M_TACT_WINDOW_PICKER) { DeleteLocalJson(oPC, M_TACT_LOCAL_PICKER); DeleteLocalJson(oPC, M_TACT_LOCAL_PICKER_FILTERED); DeleteLocalString(oPC, M_TACT_LOCAL_PICKER_MODE); }
    else if (sEvent == "close" && sWindow == M_TACT_WINDOW_RULE) DeleteLocalJson(oPC, M_TACT_LOCAL_RULE_TEMP);
    else if (sEvent == "close" && sWindow == M_TACT_WINDOW_ACTION) DeleteLocalJson(oPC, M_TACT_LOCAL_ACTION_TEMP);
    else if (sEvent == "close" && sWindow == M_TACT_WINDOW_PRIORITY) DeleteLocalJson(oPC, M_TACT_LOCAL_PRIORITY_TEMP);
}
