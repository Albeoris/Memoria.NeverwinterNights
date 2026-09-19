#include "metact_ui"

void METACT_SelectActor(object oPC, int iToken)
{
    int iIndex = JsonGetInt(NuiGetBind(oPC, iToken, "actor_sel"));
    object oActor = METACT_GetGroupMember(oPC, iIndex);
    if (!GetIsObjectValid(oActor)) return;
    SetLocalObject(oPC, METACT_LOCAL_ACTOR, oActor);
    SetLocalInt(oPC, METACT_LOCAL_SCOPE, oActor == oPC ? METACT_SCOPE_PC : METACT_SCOPE_EXACT);
    SetLocalInt(oPC, METACT_LOCAL_TACTIC, -1);
    SetLocalInt(oPC, METACT_LOCAL_RULE, -1);
    SetLocalInt(oPC, METACT_LOCAL_RULE_PAGE, 0);
    METACT_RefreshMain(oPC, iToken);
}

void METACT_SetDebug(object oPC, int iToken)
{
    METACT_SetDebugEnabled(oPC, JsonGetInt(NuiGetBind(oPC, iToken, "debug_enabled")));
}

void METACT_SelectScope(object oPC, int iToken)
{
    object oActor = GetLocalObject(oPC, METACT_LOCAL_ACTOR);
    if (!GetIsObjectValid(oActor) || oActor == oPC) return;
    int iScope = JsonGetInt(NuiGetBind(oPC, iToken, "scope_sel"));
    if (iScope != METACT_SCOPE_EXACT && iScope != METACT_SCOPE_TYPE) return;
    SetLocalInt(oPC, METACT_LOCAL_SCOPE, iScope);
    SetLocalInt(oPC, METACT_LOCAL_TACTIC, -1);
    SetLocalInt(oPC, METACT_LOCAL_RULE, -1);
    SetLocalInt(oPC, METACT_LOCAL_RULE_PAGE, 0);
    METACT_RefreshMain(oPC, iToken);
}

void METACT_SelectTactic(object oPC, int iToken)
{
    int iTactic = JsonGetInt(NuiGetBind(oPC, iToken, "tactic_sel"));
    json jProfile = METACT_GetSelectedProfile(oPC);
    json jTactics = JsonObjectGet(jProfile, "tactics");
    if (iTactic < 0 || iTactic >= JsonGetLength(jTactics)) return;
    SetLocalInt(oPC, METACT_LOCAL_TACTIC, iTactic);
    SetLocalInt(oPC, METACT_LOCAL_RULE, -1);
    SetLocalInt(oPC, METACT_LOCAL_RULE_PAGE, 0);
    jProfile = JsonObjectSet(jProfile, "active", JsonInt(iTactic));
    METACT_SetProfile(oPC, GetLocalInt(oPC, METACT_LOCAL_PROFILE), jProfile);
    METACT_RefreshMain(oPC, iToken);
}

void METACT_SetTacticEnabled(object oPC, int iToken)
{
    json jTactic = METACT_GetSelectedTactic(oPC);
    jTactic = JsonObjectSet(jTactic, "enabled", JsonBool(JsonGetInt(NuiGetBind(oPC, iToken, "tactic_enabled"))));
    METACT_SaveSelectedTactic(oPC, jTactic);
}

void METACT_NewTacticForProfile(object oPC, int iToken)
{
    int iProfile = GetLocalInt(oPC, METACT_LOCAL_PROFILE);
    json jProfile = METACT_GetProfile(oPC, iProfile);
    json jTactics = JsonArrayInsert(JsonObjectGet(jProfile, "tactics"), METACT_NewTactic(oPC));
    int iTactic = JsonGetLength(jTactics) - 1;
    jProfile = JsonObjectSet(jProfile, "tactics", jTactics);
    jProfile = JsonObjectSet(jProfile, "active", JsonInt(iTactic));
    METACT_SetProfile(oPC, iProfile, jProfile);
    SetLocalInt(oPC, METACT_LOCAL_TACTIC, iTactic);
    SetLocalInt(oPC, METACT_LOCAL_RULE, -1);
    SetLocalInt(oPC, METACT_LOCAL_RULE_PAGE, 0);
    METACT_RefreshMain(oPC, iToken);
}

void METACT_DeleteTactic(object oPC, int iToken)
{
    int iProfile = GetLocalInt(oPC, METACT_LOCAL_PROFILE);
    json jProfile = METACT_GetProfile(oPC, iProfile);
    json jTactics = JsonObjectGet(jProfile, "tactics");
    int iTactic = GetLocalInt(oPC, METACT_LOCAL_TACTIC);
    if (JsonGetLength(jTactics) <= 1) return;
    jTactics = JsonArrayDel(jTactics, iTactic);
    if (iTactic >= JsonGetLength(jTactics)) iTactic = JsonGetLength(jTactics) - 1;
    jProfile = JsonObjectSet(jProfile, "tactics", jTactics);
    jProfile = JsonObjectSet(jProfile, "active", JsonInt(iTactic));
    METACT_SetProfile(oPC, iProfile, jProfile);
    SetLocalInt(oPC, METACT_LOCAL_TACTIC, iTactic);
    SetLocalInt(oPC, METACT_LOCAL_RULE, -1);
    SetLocalInt(oPC, METACT_LOCAL_RULE_PAGE, 0);
    METACT_RefreshMain(oPC, iToken);
}

void METACT_RenameTactic(object oPC, int iToken)
{
    json jName = NuiGetBind(oPC, iToken, "tactic_name");
    if (JsonGetType(jName) != JSON_TYPE_STRING || METACT_JsonSearchText(jName) == "") return;
    json jTactic = JsonObjectSet(METACT_GetSelectedTactic(oPC), "name", jName);
    METACT_SaveSelectedTactic(oPC, jTactic);
    METACT_RefreshMain(oPC, iToken);
}

int METACT_GetClickedRule(object oPC)
{
    return NuiGetEventArrayIndex();
}

int METACT_GetClickedAction()
{
    return NuiGetEventArrayIndex();
}

int METACT_GetClickedPriority()
{
    return NuiGetEventArrayIndex();
}

void METACT_RefreshPriorityOwner(object oPC)
{
    int iScope = GetLocalInt(oPC, METACT_LOCAL_PRIORITY_SCOPE);
    int iOwner = NuiFindWindow(oPC, iScope == METACT_PRIORITY_SCOPE_ACTION ? METACT_WINDOW_ACTION : iScope == METACT_PRIORITY_SCOPE_RULE ? METACT_WINDOW_RULE : METACT_WINDOW_MAIN);
    if (iOwner <= 0) return;
    if (iScope == METACT_PRIORITY_SCOPE_ACTION) METACT_RefreshActionEditor(oPC, iOwner);
    else if (iScope == METACT_PRIORITY_SCOPE_RULE) METACT_RefreshRuleEditor(oPC, iOwner);
    else METACT_RefreshMain(oPC, iOwner);
}

void METACT_OpenScopedPriorityEditor(object oPC, int iScope, int iPriority)
{
    SetLocalInt(oPC, METACT_LOCAL_PRIORITY_SCOPE, iScope);
    METACT_OpenPriorityEditor(oPC, iPriority);
}

void METACT_SavePriority(object oPC, int iToken)
{
    int iPriority = GetLocalInt(oPC, METACT_LOCAL_PRIORITY);
    int iKind = JsonGetInt(NuiGetBind(oPC, iToken, "priority_kind"));
    string sKind = METACT_PriorityKindFromIndex(iKind);
    json jPriorities = METACT_GetEditablePriorities(oPC);
    if (METACT_HasPriorityKind(jPriorities, sKind, iPriority))
    {
        SendMessageToPC(oPC, METACT_GetText(METACT_TEXT_INVALID, oPC));
        return;
    }
    json jPriority = GetLocalJson(oPC, METACT_LOCAL_PRIORITY_TEMP);
    jPriority = JsonObjectSet(jPriority, "kind", JsonString(sKind));
    int iComparison = JsonGetInt(NuiGetBind(oPC, iToken, iKind == 3 ? "priority_health_comparison" : "priority_comparison"));
    jPriority = JsonObjectSet(jPriority, "comparison", JsonString(iComparison == 1 ? "max" : "min"));
    if (iKind == 2)
        jPriority = JsonObjectSet(jPriority, "value", NuiGetBind(oPC, iToken, "priority_rating"));
    else if (iKind == 3)
    {
        string sHealth = JsonGetString(NuiGetBind(oPC, iToken, "priority_health"));
        int iHealth = StringToInt(sHealth);
        if (JsonGetLength(RegExpMatch("^[0-9]+$", sHealth)) == 0 || iHealth < 1 || iHealth > 100)
        {
            SendMessageToPC(oPC, METACT_GetText(METACT_TEXT_INVALID, oPC));
            return;
        }
        jPriority = JsonObjectSet(jPriority, "value", JsonInt(iHealth));
    }
    if (iKind == 1)
    {
        int iTarget = JsonGetInt(NuiGetBind(oPC, iToken, "priority_target"));
        object oTarget = iTarget == 0 ? oPC : METACT_GetGroupMember(oPC, iTarget);
        if (!GetIsObjectValid(oTarget))
        {
            SendMessageToPC(oPC, METACT_GetText(METACT_TEXT_INVALID, oPC));
            return;
        }
        string sSubject = "pc";
        if (oTarget != oPC)
        {
            sSubject = GetObjectUUID(oTarget);
            if (sSubject == "")
            {
                ForceRefreshObjectUUID(oTarget);
                sSubject = GetObjectUUID(oTarget);
            }
            if (sSubject == "")
            {
                SendMessageToPC(oPC, METACT_GetText(METACT_TEXT_INVALID, oPC));
                return;
            }
        }
        jPriority = JsonObjectSet(jPriority, "subject", JsonString(sSubject));
        jPriority = JsonObjectSet(jPriority, "subject_name", JsonString(oTarget == oPC ? "" : GetName(oTarget)));
    }
    jPriority = JsonObjectSet(jPriority, "enabled", JsonBool(JsonGetInt(NuiGetBind(oPC, iToken, "priority_enabled"))));
    jPriorities = iPriority >= 0 && iPriority < JsonGetLength(jPriorities) ? JsonArraySet(jPriorities, iPriority, jPriority) : JsonArrayInsert(jPriorities, jPriority);
    METACT_SaveEditablePriorities(oPC, jPriorities);
    DeleteLocalJson(oPC, METACT_LOCAL_PRIORITY_TEMP);
    NuiDestroy(oPC, iToken);
    METACT_RefreshPriorityOwner(oPC);
}

void METACT_MovePriority(object oPC, int iPriority, int iDirection)
{
    json jPriorities = METACT_GetEditablePriorities(oPC);
    int iOther = iPriority + iDirection;
    if (JsonGetType(jPriorities) != JSON_TYPE_ARRAY || iPriority < 0 || iPriority >= JsonGetLength(jPriorities) || iOther < 0 || iOther >= JsonGetLength(jPriorities)) return;
    json jStored = JsonArrayGet(jPriorities, iPriority);
    jPriorities = JsonArraySet(jPriorities, iPriority, JsonArrayGet(jPriorities, iOther));
    jPriorities = JsonArraySet(jPriorities, iOther, jStored);
    METACT_SaveEditablePriorities(oPC, jPriorities);
    SetLocalInt(oPC, METACT_LOCAL_PRIORITY, iOther);
    METACT_RefreshPriorityOwner(oPC);
}

void METACT_MoveScopedPriority(object oPC, int iScope, int iPriority, int iDirection)
{
    SetLocalInt(oPC, METACT_LOCAL_PRIORITY_SCOPE, iScope);
    METACT_MovePriority(oPC, iPriority, iDirection);
}

void METACT_MoveEditedPriority(object oPC, int iToken, int iDirection)
{
    METACT_MovePriority(oPC, GetLocalInt(oPC, METACT_LOCAL_PRIORITY), iDirection);
    METACT_RefreshPriorityEditor(oPC, iToken);
}

void METACT_DeleteEditedPriority(object oPC, int iToken)
{
    int iPriority = GetLocalInt(oPC, METACT_LOCAL_PRIORITY);
    json jPriorities = METACT_GetEditablePriorities(oPC);
    if (JsonGetType(jPriorities) != JSON_TYPE_ARRAY || iPriority < 0 || iPriority >= JsonGetLength(jPriorities)) return;
    METACT_SaveEditablePriorities(oPC, JsonArrayDel(jPriorities, iPriority));
    DeleteLocalJson(oPC, METACT_LOCAL_PRIORITY_TEMP);
    NuiDestroy(oPC, iToken);
    METACT_RefreshPriorityOwner(oPC);
}

void METACT_MoveRule(object oPC, int iRule, int iDirection)
{
    json jTactic = METACT_GetSelectedTactic(oPC);
    json jRules = JsonObjectGet(jTactic, "rules");
    int iOther = iRule + iDirection;
    if (iRule < 0 || iRule >= JsonGetLength(jRules) || iOther < 0 || iOther >= JsonGetLength(jRules)) return;
    json jStored = JsonArrayGet(jRules, iRule);
    jRules = JsonArraySet(jRules, iRule, JsonArrayGet(jRules, iOther));
    jRules = JsonArraySet(jRules, iOther, jStored);
    METACT_SaveSelectedTactic(oPC, JsonObjectSet(jTactic, "rules", jRules));
    SetLocalInt(oPC, METACT_LOCAL_RULE, iOther);
    int iMain = NuiFindWindow(oPC, METACT_WINDOW_MAIN);
    if (iMain > 0) METACT_RefreshMain(oPC, iMain);
}

void METACT_DeleteEditedRule(object oPC, int iToken)
{
    int iRule = GetLocalInt(oPC, METACT_LOCAL_RULE);
    json jTactic = METACT_GetSelectedTactic(oPC);
    json jRules = JsonObjectGet(jTactic, "rules");
    if (iRule < 0 || iRule >= JsonGetLength(jRules)) return;
    METACT_SaveSelectedTactic(oPC, JsonObjectSet(jTactic, "rules", JsonArrayDel(jRules, iRule)));
    DeleteLocalJson(oPC, METACT_LOCAL_RULE_TEMP);
    NuiDestroy(oPC, iToken);
    int iMain = NuiFindWindow(oPC, METACT_WINDOW_MAIN);
    if (iMain > 0) METACT_RefreshMain(oPC, iMain);
}

string METACT_SourceFromIndex(int iSource)
{
    return iSource == 1 ? "spell" : iSource == 2 ? "item" : "any";
}

void METACT_SaveRule(object oPC, int iToken)
{
    json jRule = GetLocalJson(oPC, METACT_LOCAL_RULE_TEMP);
    string sValue = RegExpReplace(",", JsonGetString(NuiGetBind(oPC, iToken, "condition_value")), ".");
    string sRadius = RegExpReplace(",", JsonGetString(NuiGetBind(oPC, iToken, "condition_radius")), ".");
    int iCondition = JsonGetInt(NuiGetBind(oPC, iToken, "condition_sel"));
    int bRating = iCondition == 6;
    int bCombatState = iCondition == 7;
    int bUsesValue = iCondition >= 1 && iCondition <= 3;
    int bUsesRadius = iCondition == 1 || iCondition == 3 || iCondition == 6;
    int iValue = bRating ? JsonGetInt(NuiGetBind(oPC, iToken, "rating_sel")) : bCombatState ? JsonGetInt(NuiGetBind(oPC, iToken, "combat_state_sel")) : bUsesValue ? StringToInt(sValue) : 1;
    float fRadius = StringToFloat(sRadius);
    if (fRadius <= 0.0f) fRadius = 20.0f;
    if ((bRating && (iValue < 0 || iValue > 6)) || (bCombatState && iValue != 0 && iValue != 1) || (bUsesValue && (iValue < 1 || iValue > 100)) || (bUsesRadius && (fRadius < 0.1f || fRadius > 100.0f)))
    {
        SendMessageToPC(oPC, METACT_GetText(METACT_TEXT_INVALID, oPC));
        return;
    }
    jRule = JsonObjectSet(jRule, "enabled", JsonBool(JsonGetInt(NuiGetBind(oPC, iToken, "rule_enabled"))));
    json jCondition = JsonObjectGet(jRule, "condition");
    jCondition = JsonObjectSet(jCondition, "kind", JsonString(METACT_IndexToCondition(iCondition)));
    jCondition = JsonObjectSet(jCondition, "value", JsonInt(iValue));
    jCondition = JsonObjectSet(jCondition, "radius", JsonFloat(fRadius));
    jCondition = JsonObjectSet(jCondition, "comparison", JsonString(JsonGetInt(NuiGetBind(oPC, iToken, "comparison_sel")) == 1 ? "max" : "min"));
    jCondition = JsonObjectSet(jCondition, "subject", JsonString(JsonGetInt(NuiGetBind(oPC, iToken, "subject_sel")) == 1 ? "ally" : "self"));
    jRule = JsonObjectSet(jRule, "condition", jCondition);
    json jTactic = METACT_GetSelectedTactic(oPC);
    json jRules = JsonObjectGet(jTactic, "rules");
    int iRule = GetLocalInt(oPC, METACT_LOCAL_RULE);
    jRules = iRule >= 0 && iRule < JsonGetLength(jRules) ? JsonArraySet(jRules, iRule, jRule) : JsonArrayInsert(jRules, jRule);
    if (iRule < 0) SetLocalInt(oPC, METACT_LOCAL_RULE, JsonGetLength(jRules) - 1);
    METACT_SaveSelectedTactic(oPC, JsonObjectSet(jTactic, "rules", jRules));
    DeleteLocalJson(oPC, METACT_LOCAL_RULE_TEMP);
    NuiDestroy(oPC, iToken);
    int iMain = NuiFindWindow(oPC, METACT_WINDOW_MAIN);
    if (iMain > 0) METACT_RefreshMain(oPC, iMain);
}

void METACT_SaveAction(object oPC, int iToken)
{
    json jAction = GetLocalJson(oPC, METACT_LOCAL_ACTION_TEMP);
    if (JsonGetString(JsonObjectGet(jAction, "kind")) == "") { SendMessageToPC(oPC, METACT_GetText(METACT_TEXT_SELECT_POWER, oPC)); return; }
    jAction = JsonObjectSet(jAction, "enabled", JsonBool(JsonGetInt(NuiGetBind(oPC, iToken, "action_enabled"))));
    jAction = JsonObjectSet(jAction, "target", JsonString(METACT_IndexToTarget(JsonGetInt(NuiGetBind(oPC, iToken, "target_sel")))));
    jAction = JsonObjectSet(jAction, "source", JsonString(METACT_SourceFromIndex(JsonGetInt(NuiGetBind(oPC, iToken, "source_sel")))));
    jAction = JsonObjectSet(jAction, "move", JsonBool(JsonGetInt(NuiGetBind(oPC, iToken, "allow_move"))));
    int iFriendlyFirePolicy = JsonGetInt(NuiGetBind(oPC, iToken, "friendly_fire_policy"));
    if (iFriendlyFirePolicy < 0 || iFriendlyFirePolicy > 3) iFriendlyFirePolicy = 1;
    jAction = JsonObjectSet(jAction, "friendly_fire", JsonBool(iFriendlyFirePolicy == 0));
    jAction = JsonObjectSet(jAction, "aoe_safety", JsonInt(iFriendlyFirePolicy == 0 ? METACT_AOE_SAFETY_SAFE : iFriendlyFirePolicy));
    json jRule = METACT_GetSelectedRule(oPC);
    json jActions = JsonObjectGet(jRule, "actions");
    int iAction = GetLocalInt(oPC, METACT_LOCAL_ACTION);
    jActions = iAction >= 0 && iAction < JsonGetLength(jActions) ? JsonArraySet(jActions, iAction, jAction) : JsonArrayInsert(jActions, jAction);
    METACT_SaveSelectedRule(oPC, JsonObjectSet(jRule, "actions", jActions));
    DeleteLocalJson(oPC, METACT_LOCAL_ACTION_TEMP);
    NuiDestroy(oPC, iToken);
    int iMain = NuiFindWindow(oPC, METACT_WINDOW_MAIN);
    if (iMain > 0) METACT_RefreshMain(oPC, iMain);
}

void METACT_SelectSpecialAction(object oPC, int iToken, string sKind)
{
    json jAction = GetLocalJson(oPC, METACT_LOCAL_ACTION_TEMP);
    jAction = JsonObjectSet(jAction, "kind", JsonString(sKind));
    jAction = JsonObjectSet(jAction, "spell", JsonInt(-1));
    jAction = JsonObjectSet(jAction, "target", JsonString(sKind == "familiar" ? "self" : "auto"));
    SetLocalJson(oPC, METACT_LOCAL_ACTION_TEMP, jAction);
    METACT_RefreshActionEditor(oPC, iToken);
}

void METACT_SelectCandidate(object oPC, int iToken, int iSlot)
{
    json jFiltered = GetLocalJson(oPC, METACT_LOCAL_PICKER_FILTERED);
    int iIndex = GetLocalInt(oPC, METACT_LOCAL_PICKER_PAGE) * METACT_PICKER_PAGE_SIZE + iSlot;
    if (iIndex < 0 || iIndex >= JsonGetLength(jFiltered)) return;
    json jCandidate = JsonArrayGet(jFiltered, iIndex);
    json jAction = GetLocalJson(oPC, METACT_LOCAL_ACTION_TEMP);
    string sCandidateType = JsonGetString(JsonObjectGet(jCandidate, "type"));
    jAction = JsonObjectSet(jAction, "kind", JsonString(sCandidateType == "equip" ? "equip" : sCandidateType == "feat" ? "feat" : "spell"));
    jAction = JsonObjectSet(jAction, "feat", sCandidateType == "feat" ? JsonObjectGet(jCandidate, "feat") : JsonInt(-1));
    jAction = JsonObjectSet(jAction, "feat_name", sCandidateType == "feat" ? JsonObjectGet(jCandidate, "name") : JsonString(""));
    jAction = JsonObjectSet(jAction, "feat_icon", sCandidateType == "feat" ? JsonObjectGet(jCandidate, "icon") : JsonString(""));
    jAction = JsonObjectSet(jAction, "feat_target_self", sCandidateType == "feat" ? JsonObjectGet(jCandidate, "target_self") : JsonBool(FALSE));
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
    if (sCandidateType == "equip" || (sCandidateType == "feat" && JsonGetInt(JsonObjectGet(jCandidate, "target_self")))) jAction = JsonObjectSet(jAction, "target", JsonString("self"));
    SetLocalJson(oPC, METACT_LOCAL_ACTION_TEMP, jAction);
    DeleteLocalJson(oPC, METACT_LOCAL_PICKER);
    DeleteLocalJson(oPC, METACT_LOCAL_PICKER_FILTERED);
    DeleteLocalString(oPC, METACT_LOCAL_PICKER_MODE);
    NuiDestroy(oPC, iToken);
    METACT_ShowActionEditor(oPC);
}

void METACT_SelectRule(object oPC, int iToken, int iRule)
{
    json jRules = JsonObjectGet(METACT_GetSelectedTactic(oPC), "rules");
    if (iRule < 0 || iRule >= JsonGetLength(jRules)) return;
    SetLocalInt(oPC, METACT_LOCAL_RULE, iRule);
    METACT_RefreshMain(oPC, iToken);
}

void METACT_MoveAction(object oPC, int iAction, int iDirection)
{
    json jRule = METACT_GetSelectedRule(oPC);
    json jActions = JsonObjectGet(jRule, "actions");
    int iOther = iAction + iDirection;
    if (iAction < 0 || iAction >= JsonGetLength(jActions) || iOther < 0 || iOther >= JsonGetLength(jActions)) return;
    json jStored = JsonArrayGet(jActions, iAction);
    jActions = JsonArraySet(jActions, iAction, JsonArrayGet(jActions, iOther));
    jActions = JsonArraySet(jActions, iOther, jStored);
    METACT_SaveSelectedRule(oPC, JsonObjectSet(jRule, "actions", jActions));
    int iMain = NuiFindWindow(oPC, METACT_WINDOW_MAIN);
    if (iMain > 0) METACT_RefreshMain(oPC, iMain);
}

void METACT_DeleteEditedAction(object oPC, int iToken)
{
    int iAction = GetLocalInt(oPC, METACT_LOCAL_ACTION);
    json jRule = METACT_GetSelectedRule(oPC);
    json jActions = JsonObjectGet(jRule, "actions");
    if (iAction < 0 || iAction >= JsonGetLength(jActions)) return;
    METACT_SaveSelectedRule(oPC, JsonObjectSet(jRule, "actions", JsonArrayDel(jActions, iAction)));
    DeleteLocalJson(oPC, METACT_LOCAL_ACTION_TEMP);
    NuiDestroy(oPC, iToken);
    int iMain = NuiFindWindow(oPC, METACT_WINDOW_MAIN);
    if (iMain > 0) METACT_RefreshMain(oPC, iMain);
}

void METACT_StartNewAction(object oPC, string sKind)
{
    if (JsonGetType(METACT_GetSelectedRule(oPC)) != JSON_TYPE_OBJECT) return;
    METACT_OpenActionEditor(oPC, -1);
    int iActionWindow = NuiFindWindow(oPC, METACT_WINDOW_ACTION);
    if (sKind == "spell" || sKind == "item" || sKind == "equip" || sKind == "feat") METACT_OpenPicker(oPC, sKind);
    else if (iActionWindow > 0) METACT_SelectSpecialAction(oPC, iActionWindow, sKind);
}

void METACT_HandleWatch(object oPC, int iToken, string sWindow, string sElement)
{
    if (sWindow == METACT_WINDOW_MAIN)
    {
        if (sElement == "actor_sel") METACT_SelectActor(oPC, iToken);
        else if (sElement == "scope_sel") METACT_SelectScope(oPC, iToken);
        else if (sElement == "tactic_sel") METACT_SelectTactic(oPC, iToken);
        else if (sElement == "tactic_enabled") METACT_SetTacticEnabled(oPC, iToken);
        else if (sElement == "debug_enabled") METACT_SetDebug(oPC, iToken);
    }
    else if (sWindow == METACT_WINDOW_PICKER && sElement == "picker_search")
    {
        SetLocalInt(oPC, METACT_LOCAL_PICKER_PAGE, 0);
        METACT_RefreshPicker(oPC, iToken);
    }
    else if (sWindow == METACT_WINDOW_RULE && sElement == "condition_sel") METACT_RefreshConditionMode(oPC, iToken);
    else if (sWindow == METACT_WINDOW_PRIORITY && sElement == "priority_kind") METACT_RefreshPriorityMode(oPC, iToken);
    else if (sWindow == METACT_WINDOW_ACTION && sElement == "friendly_fire_policy")
    {
        int iPolicy = JsonGetInt(NuiGetBind(oPC, iToken, "friendly_fire_policy"));
        if (iPolicy < 0 || iPolicy > 3) iPolicy = 1;
        NuiSetBind(oPC, iToken, "friendly_fire_policy_help", JsonString(METACT_GetText(METACT_GetFriendlyFireHelpKey(iPolicy), oPC)));
    }
}

void METACT_HandleClick(object oPC, int iToken, string sWindow, string sElement)
{
    if (sWindow == METACT_WINDOW_MAIN)
    {
        if (sElement == "close") NuiDestroy(oPC, iToken);
        else if (sElement == "tactic_new") METACT_NewTacticForProfile(oPC, iToken);
        else if (sElement == "tactic_delete") METACT_DeleteTactic(oPC, iToken);
        else if (sElement == "tactic_rename") METACT_RenameTactic(oPC, iToken);
        else if (sElement == "rule_add") METACT_OpenRuleEditor(oPC, -1);
        else if (sElement == "rule_select") METACT_SelectRule(oPC, iToken, METACT_GetClickedRule(oPC));
        else if (sElement == "rule_edit") { SetLocalInt(oPC, METACT_LOCAL_RULE, METACT_GetClickedRule(oPC)); METACT_OpenRuleEditor(oPC, GetLocalInt(oPC, METACT_LOCAL_RULE)); }
        else if (sElement == "rule_up") METACT_MoveRule(oPC, METACT_GetClickedRule(oPC), -1);
        else if (sElement == "rule_down") METACT_MoveRule(oPC, METACT_GetClickedRule(oPC), 1);
        else if (sElement == "action_edit") METACT_OpenActionEditor(oPC, METACT_GetClickedAction());
        else if (sElement == "action_up") METACT_MoveAction(oPC, METACT_GetClickedAction(), -1);
        else if (sElement == "action_down") METACT_MoveAction(oPC, METACT_GetClickedAction(), 1);
        else if (sElement == "action_add_spell") METACT_StartNewAction(oPC, "spell");
        else if (sElement == "action_add_item") METACT_StartNewAction(oPC, "item");
        else if (sElement == "action_add_equip") METACT_StartNewAction(oPC, "equip");
        else if (sElement == "action_add_feat") METACT_StartNewAction(oPC, "feat");
        else if (sElement == "action_add_attack") METACT_StartNewAction(oPC, "attack");
        else if (sElement == "priority_add") METACT_OpenScopedPriorityEditor(oPC, METACT_PRIORITY_SCOPE_GLOBAL, -1);
        else if (sElement == "priority_edit") METACT_OpenScopedPriorityEditor(oPC, METACT_PRIORITY_SCOPE_GLOBAL, METACT_GetClickedPriority());
        else if (sElement == "priority_up") METACT_MoveScopedPriority(oPC, METACT_PRIORITY_SCOPE_GLOBAL, METACT_GetClickedPriority(), -1);
        else if (sElement == "priority_down") METACT_MoveScopedPriority(oPC, METACT_PRIORITY_SCOPE_GLOBAL, METACT_GetClickedPriority(), 1);
        else if (sElement == "debug_target")
        {
            SetLocalInt(oPC, METACT_LOCAL_DEBUG_TARGETING, TRUE);
            NuiDestroy(oPC, iToken);
            SendMessageToPC(oPC, METACT_GetText(METACT_TEXT_INSPECT_PROMPT, oPC));
            EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE, MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
        }
    }
    else if (sWindow == METACT_WINDOW_PRIORITY)
    {
        if (sElement == "priority_cancel") { DeleteLocalJson(oPC, METACT_LOCAL_PRIORITY_TEMP); NuiDestroy(oPC, iToken); }
        else if (sElement == "priority_save") METACT_SavePriority(oPC, iToken);
        else if (sElement == "priority_move_up") METACT_MoveEditedPriority(oPC, iToken, -1);
        else if (sElement == "priority_move_down") METACT_MoveEditedPriority(oPC, iToken, 1);
        else if (sElement == "priority_remove") METACT_DeleteEditedPriority(oPC, iToken);
    }
    else if (sWindow == METACT_WINDOW_RULE)
    {
        if (sElement == "rule_cancel") { DeleteLocalJson(oPC, METACT_LOCAL_RULE_TEMP); NuiDestroy(oPC, iToken); }
        else if (sElement == "rule_save") METACT_SaveRule(oPC, iToken);
        else if (sElement == "rule_remove") METACT_DeleteEditedRule(oPC, iToken);
        else if (sElement == "priority_add") METACT_OpenScopedPriorityEditor(oPC, METACT_PRIORITY_SCOPE_RULE, -1);
        else if (sElement == "priority_edit") METACT_OpenScopedPriorityEditor(oPC, METACT_PRIORITY_SCOPE_RULE, METACT_GetClickedPriority());
        else if (sElement == "priority_up") METACT_MoveScopedPriority(oPC, METACT_PRIORITY_SCOPE_RULE, METACT_GetClickedPriority(), -1);
        else if (sElement == "priority_down") METACT_MoveScopedPriority(oPC, METACT_PRIORITY_SCOPE_RULE, METACT_GetClickedPriority(), 1);
    }
    else if (sWindow == METACT_WINDOW_ACTION)
    {
        if (sElement == "action_cancel") { DeleteLocalJson(oPC, METACT_LOCAL_ACTION_TEMP); NuiDestroy(oPC, iToken); }
        else if (sElement == "action_save") METACT_SaveAction(oPC, iToken);
        else if (sElement == "action_remove") METACT_DeleteEditedAction(oPC, iToken);
        else if (sElement == "choose_spell") METACT_OpenPicker(oPC, "spell");
        else if (sElement == "choose_item") METACT_OpenPicker(oPC, "item");
        else if (sElement == "choose_equip") METACT_OpenPicker(oPC, "equip");
        else if (sElement == "choose_feat") METACT_OpenPicker(oPC, "feat");
        else if (sElement == "choose_attack") METACT_SelectSpecialAction(oPC, iToken, "attack");
        else if (sElement == "priority_add") METACT_OpenScopedPriorityEditor(oPC, METACT_PRIORITY_SCOPE_ACTION, -1);
        else if (sElement == "priority_edit") METACT_OpenScopedPriorityEditor(oPC, METACT_PRIORITY_SCOPE_ACTION, METACT_GetClickedPriority());
        else if (sElement == "priority_up") METACT_MoveScopedPriority(oPC, METACT_PRIORITY_SCOPE_ACTION, METACT_GetClickedPriority(), -1);
        else if (sElement == "priority_down") METACT_MoveScopedPriority(oPC, METACT_PRIORITY_SCOPE_ACTION, METACT_GetClickedPriority(), 1);
    }
    else if (sWindow == METACT_WINDOW_PICKER)
    {
        if (sElement == "pick_spells") { SetLocalString(oPC, METACT_LOCAL_PICKER_MODE, "spell"); SetLocalInt(oPC, METACT_LOCAL_PICKER_PAGE, 0); METACT_RecreatePicker(oPC, iToken); }
        else if (sElement == "pick_items") { SetLocalString(oPC, METACT_LOCAL_PICKER_MODE, "item"); SetLocalInt(oPC, METACT_LOCAL_PICKER_PAGE, 0); METACT_RecreatePicker(oPC, iToken); }
        else if (sElement == "pick_equip") { SetLocalString(oPC, METACT_LOCAL_PICKER_MODE, "equip"); SetLocalInt(oPC, METACT_LOCAL_PICKER_PAGE, 0); METACT_RecreatePicker(oPC, iToken); }
        else if (sElement == "pick_feats") { SetLocalString(oPC, METACT_LOCAL_PICKER_MODE, "feat"); SetLocalInt(oPC, METACT_LOCAL_PICKER_PAGE, 0); METACT_RecreatePicker(oPC, iToken); }
        else if (sElement == "pick_prev") { SetLocalInt(oPC, METACT_LOCAL_PICKER_PAGE, GetLocalInt(oPC, METACT_LOCAL_PICKER_PAGE) - 1); METACT_RecreatePicker(oPC, iToken); }
        else if (sElement == "pick_next") { SetLocalInt(oPC, METACT_LOCAL_PICKER_PAGE, GetLocalInt(oPC, METACT_LOCAL_PICKER_PAGE) + 1); METACT_RecreatePicker(oPC, iToken); }
        else if (GetSubString(sElement, 0, 10) == "pick_slot_") METACT_SelectCandidate(oPC, iToken, StringToInt(GetSubString(sElement, 10, GetStringLength(sElement) - 10)));
    }
}

void main()
{
    if (MEMORIA_NUI_HandleHelpEvent()) return;
    object oPC = NuiGetEventPlayer();
    int iToken = NuiGetEventWindow();
    string sWindow = NuiGetWindowId(oPC, iToken);
    string sEvent = NuiGetEventType();
    string sElement = NuiGetEventElement();
    if (sEvent == "watch") METACT_HandleWatch(oPC, iToken, sWindow, sElement);
    else if (sEvent == "click") METACT_HandleClick(oPC, iToken, sWindow, sElement);
    else if (sEvent == "close" && sWindow == METACT_WINDOW_PICKER) { DeleteLocalJson(oPC, METACT_LOCAL_PICKER); DeleteLocalJson(oPC, METACT_LOCAL_PICKER_FILTERED); DeleteLocalString(oPC, METACT_LOCAL_PICKER_MODE); METACT_ShowActionEditor(oPC); }
    else if (sEvent == "close" && sWindow == METACT_WINDOW_RULE) DeleteLocalJson(oPC, METACT_LOCAL_RULE_TEMP);
    else if (sEvent == "close" && sWindow == METACT_WINDOW_ACTION) { if (GetLocalInt(oPC, METACT_LOCAL_ACTION_HIDDEN)) DeleteLocalInt(oPC, METACT_LOCAL_ACTION_HIDDEN); else DeleteLocalJson(oPC, METACT_LOCAL_ACTION_TEMP); }
    else if (sEvent == "close" && sWindow == METACT_WINDOW_PRIORITY) DeleteLocalJson(oPC, METACT_LOCAL_PRIORITY_TEMP);
}
