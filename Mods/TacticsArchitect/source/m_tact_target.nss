#include "m_tact_runtime"

string M_TACT_DebugAvailability(object oActor, json jAction, int iSpell)
{
    string sSource = JsonGetString(JsonObjectGet(jAction, "source"));
    int bSpell;
    int bItem;
    if (sSource != "item")
    {
        int iClass = M_TACT_FindCastingClass(oActor, iSpell, JsonGetInt(JsonObjectGet(jAction, "class")), JsonGetInt(JsonObjectGet(jAction, "metamagic")), JsonGetInt(JsonObjectGet(jAction, "domain")));
        bSpell = iClass != CLASS_TYPE_INVALID;
        if (!bSpell && sSource == "any") bSpell = M_TACT_FindAnyCastingVariant(oActor, iSpell);
        DeleteLocalInt(oActor, M_TACT_LOCAL_EVAL_CLASS);
        DeleteLocalInt(oActor, M_TACT_LOCAL_EVAL_METAMAGIC);
        DeleteLocalInt(oActor, M_TACT_LOCAL_EVAL_DOMAIN);
    }
    if (sSource != "spell")
    {
        object oItem = M_TACT_FindCastItem(oActor, jAction, iSpell);
        if (GetIsObjectValid(oItem)) bItem = GetIsItemPropertyValid(M_TACT_FindCastProperty(oItem, JsonGetInt(JsonObjectGet(jAction, "item_property")), iSpell));
    }
    return "spell=" + (bSpell ? "yes" : "no") + ", item=" + (bItem ? "yes" : "no");
}

void M_TACT_DumpTarget(object oPC, object oTarget)
{
    object oActor = GetLocalObject(oPC, M_TACT_LOCAL_ACTOR);
    if (!GetIsObjectValid(oActor) || !M_TACT_IsGroupCreature(oActor, oPC)) oActor = oPC;
    int iRating = M_TACT_GetRelativeEnemyRating(oActor, oTarget);
    SendMessageToPC(oPC, "[M_TACT] TARGET " + GetName(oTarget) + " | actor=" + GetName(oActor) + " | CR=" + FloatToString(GetChallengeRating(oTarget), 0, 2) + " | actor HD=" + IntToString(GetHitDice(oActor)) + " | rating=" + IntToString(iRating) + " | distance=" + FloatToString(GetDistanceBetween(oActor, oTarget), 0, 2) + "m | SR=" + IntToString(GetSpellResistance(oTarget)));
    int iProfile = M_TACT_FindRuntimeProfile(oPC, oActor);
    if (iProfile < 0)
    {
        SendMessageToPC(oPC, "[M_TACT] No active profile for this actor.");
        return;
    }
    json jProfile = M_TACT_GetProfile(oPC, iProfile);
    json jTactic = JsonArrayGet(JsonObjectGet(jProfile, "tactics"), JsonGetInt(JsonObjectGet(jProfile, "active")));
    json jRules = JsonObjectGet(jTactic, "rules");
    int iRule;
    for (iRule = 0; iRule < JsonGetLength(jRules); iRule++)
    {
        json jRule = JsonArrayGet(jRules, iRule);
        if (!JsonGetInt(JsonObjectGet(jRule, "enabled"))) continue;
        int bCondition = M_TACT_MatchesCondition(oActor, oPC, JsonObjectGet(jRule, "condition"));
        json jActions = JsonObjectGet(jRule, "actions");
        int iAction;
        for (iAction = 0; iAction < JsonGetLength(jActions); iAction++)
        {
            json jAction = JsonArrayGet(jActions, iAction);
            if (JsonGetString(JsonObjectGet(jAction, "kind")) != "spell") continue;
            int iSpell = JsonGetInt(JsonObjectGet(jAction, "spell"));
            int iSpellLevel = M_TACT_GetActionSpellLevel(jAction, iSpell);
            int bSensible = M_TACT_IsSpellSensible(oActor, oTarget, iSpell, iSpellLevel);
            string sReason = bSensible ? "accepted" : M_TACT_DebugReasonText(oPC, GetLocalString(oActor, M_TACT_LOCAL_REJECT_REASON));
            SendMessageToPC(oPC, "[M_TACT] #" + IntToString(iRule + 1) + "." + IntToString(iAction + 1) + " " + RegExpReplace("_", Get2DAString("spells", "Label", iSpell), " ") + " | level=" + IntToString(iSpellLevel) + " | condition=" + (bCondition ? "yes" : "no") + " (" + M_TACT_DebugConditionText(oActor, JsonObjectGet(jRule, "condition")) + ") | target=" + sReason + " | " + M_TACT_DebugAvailability(oActor, jAction, iSpell));
        }
    }
}

void main()
{
    object oPC = GetLastPlayerToSelectTarget();
    if (!GetIsObjectValid(oPC) || !GetLocalInt(oPC, M_TACT_LOCAL_DEBUG_TARGETING)) return;
    DeleteLocalInt(oPC, M_TACT_LOCAL_DEBUG_TARGETING);
    object oTarget = GetTargetingModeSelectedObject();
    if (!GetIsObjectValid(oTarget))
    {
        SendMessageToPC(oPC, "[M_TACT] Target inspection cancelled.");
        return;
    }
    M_TACT_DumpTarget(oPC, oTarget);
}
