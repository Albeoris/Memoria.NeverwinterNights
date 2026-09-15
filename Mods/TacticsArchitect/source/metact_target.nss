#include "metact_runtime"

string METACT_DebugAvailability(object oActor, json jAction, int iSpell)
{
    string sSource = JsonGetString(JsonObjectGet(jAction, "source"));
    int bSpell;
    int bItem;
    if (sSource != "item")
    {
        int iClass = METACT_FindCastingClass(oActor, iSpell, JsonGetInt(JsonObjectGet(jAction, "class")), JsonGetInt(JsonObjectGet(jAction, "metamagic")), JsonGetInt(JsonObjectGet(jAction, "domain")));
        bSpell = iClass != CLASS_TYPE_INVALID;
        if (!bSpell && sSource == "any") bSpell = METACT_FindAnyCastingVariant(oActor, iSpell);
        DeleteLocalInt(oActor, METACT_LOCAL_EVAL_CLASS);
        DeleteLocalInt(oActor, METACT_LOCAL_EVAL_METAMAGIC);
        DeleteLocalInt(oActor, METACT_LOCAL_EVAL_DOMAIN);
    }
    if (sSource != "spell")
    {
        object oItem = METACT_FindCastItem(oActor, jAction, iSpell);
        if (GetIsObjectValid(oItem)) bItem = GetIsItemPropertyValid(METACT_FindCastProperty(oItem, JsonGetInt(JsonObjectGet(jAction, "item_property")), iSpell));
    }
    return "spell=" + (bSpell ? "yes" : "no") + ", item=" + (bItem ? "yes" : "no");
}

void METACT_DumpTarget(object oPC, object oTarget)
{
    object oActor = GetLocalObject(oPC, METACT_LOCAL_ACTOR);
    if (!GetIsObjectValid(oActor) || !METACT_IsGroupCreature(oActor, oPC)) oActor = oPC;
    int iRating = METACT_GetRelativeEnemyRating(oActor, oTarget);
    SendMessageToPC(oPC, "[METACT] TARGET " + GetName(oTarget) + " | actor=" + GetName(oActor) + " | CR=" + FloatToString(GetChallengeRating(oTarget), 0, 2) + " | actor HD=" + IntToString(GetHitDice(oActor)) + " | rating=" + IntToString(iRating) + " | distance=" + FloatToString(GetDistanceBetween(oActor, oTarget), 0, 2) + "m | SR=" + IntToString(GetSpellResistance(oTarget)));
    int iProfile = METACT_FindRuntimeProfile(oPC, oActor);
    if (iProfile < 0)
    {
        SendMessageToPC(oPC, "[METACT] No active profile for this actor.");
        return;
    }
    json jProfile = METACT_GetProfile(oPC, iProfile);
    json jTactic = JsonArrayGet(JsonObjectGet(jProfile, "tactics"), JsonGetInt(JsonObjectGet(jProfile, "active")));
    json jRules = JsonObjectGet(jTactic, "rules");
    int iRule;
    for (iRule = 0; iRule < JsonGetLength(jRules); iRule++)
    {
        json jRule = JsonArrayGet(jRules, iRule);
        if (!JsonGetInt(JsonObjectGet(jRule, "enabled"))) continue;
        int bCondition = METACT_MatchesCondition(oActor, oPC, JsonObjectGet(jRule, "condition"));
        json jActions = JsonObjectGet(jRule, "actions");
        int iAction;
        for (iAction = 0; iAction < JsonGetLength(jActions); iAction++)
        {
            json jAction = JsonArrayGet(jActions, iAction);
            if (JsonGetString(JsonObjectGet(jAction, "kind")) != "spell") continue;
            int iSpell = JsonGetInt(JsonObjectGet(jAction, "spell"));
            int iSpellLevel = METACT_GetActionSpellLevel(jAction, iSpell);
            int bSensible = METACT_IsSpellSensible(oActor, oTarget, iSpell, iSpellLevel);
            string sReason = bSensible ? "accepted" : METACT_DebugReasonText(oPC, GetLocalString(oActor, METACT_LOCAL_REJECT_REASON));
            SendMessageToPC(oPC, "[METACT] #" + IntToString(iRule + 1) + "." + IntToString(iAction + 1) + " " + RegExpReplace("_", Get2DAString("spells", "Label", iSpell), " ") + " | level=" + IntToString(iSpellLevel) + " | condition=" + (bCondition ? "yes" : "no") + " (" + METACT_DebugConditionText(oActor, JsonObjectGet(jRule, "condition")) + ") | target=" + sReason + " | " + METACT_DebugAvailability(oActor, jAction, iSpell));
        }
    }
}

void main()
{
    object oPC = GetLastPlayerToSelectTarget();
    if (!GetIsObjectValid(oPC) || !GetLocalInt(oPC, METACT_LOCAL_DEBUG_TARGETING)) return;
    DeleteLocalInt(oPC, METACT_LOCAL_DEBUG_TARGETING);
    object oTarget = GetTargetingModeSelectedObject();
    if (!GetIsObjectValid(oTarget))
    {
        SendMessageToPC(oPC, "[METACT] Target inspection cancelled.");
        return;
    }
    METACT_DumpTarget(oPC, oTarget);
}
