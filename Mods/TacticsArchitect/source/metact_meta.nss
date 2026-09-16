// Runtime spell metadata. Standard columns make this work for custom spells too.
#include "metact_core"

const int METACT_ROLE_GENERIC = 0;
const int METACT_ROLE_SUMMON = 1;
const int METACT_ROLE_NEGATIVE = 2;

int METACT_GetSpellRole(int iSpell)
{
    if (iSpell == SPELL_ANIMATE_DEAD || iSpell == SPELL_CREATE_UNDEAD || iSpell == SPELL_ELEMENTAL_SWARM || iSpell == SPELL_GATE || iSpell == SPELL_PLANAR_BINDING || iSpell == SPELL_PLANAR_ALLY || iSpell == SPELL_SUMMON_SHADOW || iSpell == SPELL_SHADOW_CONJURATION_SUMMON_SHADOW || (iSpell >= SPELL_SUMMON_CREATURE_I && iSpell <= SPELL_SUMMON_CREATURE_IV) || (iSpell >= SPELL_SUMMON_CREATURE_V && iSpell <= SPELL_SUMMON_CREATURE_VIII) || iSpell == SPELL_SUMMON_CREATURE_IX)
        return METACT_ROLE_SUMMON;
    if (iSpell == SPELL_NEGATIVE_ENERGY_BURST || iSpell == SPELL_NEGATIVE_ENERGY_RAY)
        return METACT_ROLE_NEGATIVE;
    return METACT_ROLE_GENERIC;
}

int METACT_GetSpellAssociateType(int iSpell)
{
    string sLabel = Get2DAString("spells", "Label", iSpell);
    if (sLabel == "Summon_Familiar") return ASSOCIATE_TYPE_FAMILIAR;
    if (sLabel == "Summon_Animal_Companion") return ASSOCIATE_TYPE_ANIMALCOMPANION;
    if (METACT_GetSpellRole(iSpell) == METACT_ROLE_SUMMON) return ASSOCIATE_TYPE_SUMMONED;
    return -1;
}

int METACT_IsSpellHostile(int iSpell)
{
    return Get2DAString("spells", "HostileSetting", iSpell) == "1";
}

int METACT_IsSpellArea(int iSpell)
{
    string sShape = Get2DAString("spells", "TargetShape", iSpell);
    return sShape != "" && sShape != "****";
}

int METACT_CanSpellHitAllies(int iSpell)
{
    string sFlags = Get2DAString("spells", "TargetFlags", iSpell);
    if (sFlags == "" || sFlags == "****") return TRUE;
    return StringToInt(sFlags) / 2 % 2 == 1;
}

int METACT_GetActionSpellLevel(json jAction, int iSpell)
{
    json jStoredLevel = JsonObjectGet(jAction, "level");
    if (JsonGetType(jStoredLevel) == JSON_TYPE_INTEGER)
    {
        int iStoredLevel = JsonGetInt(jStoredLevel);
        if (iStoredLevel >= 0 && iStoredLevel <= 9) return iStoredLevel;
    }
    int iDomainLevel = JsonGetInt(JsonObjectGet(jAction, "domain"));
    if (iDomainLevel > 0 && iDomainLevel <= 9) return iDomainLevel;
    json jClass = JsonObjectGet(jAction, "class");
    if (JsonGetType(jClass) == JSON_TYPE_INTEGER)
    {
        int iClassLevel = GetSpellLevelByClass(JsonGetInt(jClass), iSpell);
        if (iClassLevel >= 0 && iClassLevel <= 9) return iClassLevel;
    }
    string sInnateLevel = Get2DAString("spells", "Innate", iSpell);
    if (sInnateLevel != "" && sInnateLevel != "****") return StringToInt(sInnateLevel);
    return -1;
}

float METACT_GetSpellAreaRadius(object oCaster, int iSpell, int iSpellLevel, int iMetaMagic)
{
    float fRadius = StringToFloat(Get2DAString("spells", "TargetSizeX", iSpell));
    return fRadius > 0.0f ? fRadius : 3.33f;
}

float METACT_GetSpellRange(int iSpell)
{
    string sRange = Get2DAString("spells", "Range", iSpell);
    if (sRange == "P")
        return 0.1f;
    if (sRange == "T")
        return 2.5f;
    if (sRange == "S")
        return 8.0f;
    if (sRange == "M")
        return 20.0f;
    return 40.0f;
}

int METACT_ImmunityNameToType(string sImmunity)
{
    if (sImmunity == "Mind_Affecting") return IMMUNITY_TYPE_MIND_SPELLS;
    if (sImmunity == "Poison") return IMMUNITY_TYPE_POISON;
    if (sImmunity == "Disease") return IMMUNITY_TYPE_DISEASE;
    if (sImmunity == "Fear") return IMMUNITY_TYPE_FEAR;
    if (sImmunity == "Paralysis") return IMMUNITY_TYPE_PARALYSIS;
    if (sImmunity == "Blindness") return IMMUNITY_TYPE_BLINDNESS;
    if (sImmunity == "Deafness") return IMMUNITY_TYPE_DEAFNESS;
    if (sImmunity == "Slow") return IMMUNITY_TYPE_SLOW;
    if (sImmunity == "Entangle") return IMMUNITY_TYPE_ENTANGLE;
    if (sImmunity == "Silence") return IMMUNITY_TYPE_SILENCE;
    if (sImmunity == "Stun") return IMMUNITY_TYPE_STUN;
    if (sImmunity == "Sleep") return IMMUNITY_TYPE_SLEEP;
    if (sImmunity == "Charm") return IMMUNITY_TYPE_CHARM;
    if (sImmunity == "Dominate") return IMMUNITY_TYPE_DOMINATE;
    if (sImmunity == "Confused") return IMMUNITY_TYPE_CONFUSED;
    if (sImmunity == "Curse") return IMMUNITY_TYPE_CURSED;
    if (sImmunity == "Dazed") return IMMUNITY_TYPE_DAZED;
    if (sImmunity == "Death") return IMMUNITY_TYPE_DEATH;
    return IMMUNITY_TYPE_NONE;
}

int METACT_ImmunityNameToDamageType(string sImmunity, int iSpell)
{
    if (sImmunity == "Acid") return DAMAGE_TYPE_ACID;
    if (sImmunity == "Cold") return DAMAGE_TYPE_COLD;
    if (sImmunity == "Divine") return DAMAGE_TYPE_DIVINE;
    if (sImmunity == "Electricity") return DAMAGE_TYPE_ELECTRICAL;
    if (sImmunity == "Fire") return DAMAGE_TYPE_FIRE;
    if (sImmunity == "Negative") return DAMAGE_TYPE_NEGATIVE;
    if (sImmunity == "Positive") return DAMAGE_TYPE_POSITIVE;
    if (sImmunity == "Sonic") return DAMAGE_TYPE_SONIC;
    if (iSpell == SPELL_MAGIC_MISSILE || iSpell == SPELL_ISAACS_LESSER_MISSILE_STORM || iSpell == SPELL_ISAACS_GREATER_MISSILE_STORM) return DAMAGE_TYPE_MAGICAL;
    if (iSpell == SPELL_ICE_STORM) return DAMAGE_TYPE_COLD;
    return DAMAGE_TYPE_BASE_WEAPON;
}

int METACT_DamageTypeToItemType(int iDamageType)
{
    if (iDamageType == DAMAGE_TYPE_MAGICAL) return IP_CONST_DAMAGETYPE_MAGICAL;
    if (iDamageType == DAMAGE_TYPE_ACID) return IP_CONST_DAMAGETYPE_ACID;
    if (iDamageType == DAMAGE_TYPE_COLD) return IP_CONST_DAMAGETYPE_COLD;
    if (iDamageType == DAMAGE_TYPE_DIVINE) return IP_CONST_DAMAGETYPE_DIVINE;
    if (iDamageType == DAMAGE_TYPE_ELECTRICAL) return IP_CONST_DAMAGETYPE_ELECTRICAL;
    if (iDamageType == DAMAGE_TYPE_FIRE) return IP_CONST_DAMAGETYPE_FIRE;
    if (iDamageType == DAMAGE_TYPE_NEGATIVE) return IP_CONST_DAMAGETYPE_NEGATIVE;
    if (iDamageType == DAMAGE_TYPE_POSITIVE) return IP_CONST_DAMAGETYPE_POSITIVE;
    if (iDamageType == DAMAGE_TYPE_SONIC) return IP_CONST_DAMAGETYPE_SONIC;
    return -1;
}

int METACT_HasFullDamageImmunity(object oTarget, int iDamageType)
{
    if (iDamageType == DAMAGE_TYPE_BASE_WEAPON)
        return FALSE;
    effect eEffect = GetFirstEffect(oTarget);
    while (GetIsEffectValid(eEffect))
    {
        if (GetEffectType(eEffect, TRUE) == EFFECT_TYPE_DAMAGE_IMMUNITY_INCREASE && ((GetEffectInteger(eEffect, 0) == iDamageType && GetEffectInteger(eEffect, 1) >= 100) || (GetEffectInteger(eEffect, 1) == iDamageType && GetEffectInteger(eEffect, 0) >= 100)))
            return TRUE;
        eEffect = GetNextEffect(oTarget);
    }
    int iItemType = METACT_DamageTypeToItemType(iDamageType);
    int iSlot;
    for (iSlot = INVENTORY_SLOT_HEAD; iSlot <= INVENTORY_SLOT_CARMOUR; iSlot++)
    {
        object oItem = GetItemInSlot(iSlot, oTarget);
        itemproperty ip = GetFirstItemProperty(oItem);
        while (GetIsItemPropertyValid(ip))
        {
            if (GetItemPropertyType(ip) == ITEM_PROPERTY_IMMUNITY_DAMAGE_TYPE && GetItemPropertySubType(ip) == iItemType && GetItemPropertyCostTableValue(ip) == IP_CONST_DAMAGEIMMUNITY_100_PERCENT)
                return TRUE;
            ip = GetNextItemProperty(oItem);
        }
    }
    return FALSE;
}

int METACT_IsSpellSensible(object oCaster, object oTarget, int iSpell, int iSpellLevel)
{
    DeleteLocalString(oCaster, METACT_LOCAL_REJECT_REASON);
    if (!GetIsObjectValid(oCaster) || !GetIsObjectValid(oTarget))
    {
        SetLocalString(oCaster, METACT_LOCAL_REJECT_REASON, "invalid_object");
        return FALSE;
    }
    if (METACT_IsSpellHostile(iSpell))
    {
        if (METACT_GetSpellRole(iSpell) == METACT_ROLE_NEGATIVE && GetRacialType(oTarget) == RACIAL_TYPE_UNDEAD)
        {
            SetLocalString(oCaster, METACT_LOCAL_REJECT_REASON, "negative_vs_undead");
            return FALSE;
        }
        string sImmunity = Get2DAString("spells", "ImmunityType", iSpell);
        int iImmunity = METACT_ImmunityNameToType(sImmunity);
        if (iImmunity != IMMUNITY_TYPE_NONE && GetIsImmune(oTarget, iImmunity, oCaster))
        {
            SetLocalString(oCaster, METACT_LOCAL_REJECT_REASON, "status_immunity");
            return FALSE;
        }
        if (METACT_HasFullDamageImmunity(oTarget, METACT_ImmunityNameToDamageType(sImmunity, iSpell)))
        {
            SetLocalString(oCaster, METACT_LOCAL_REJECT_REASON, "damage_immunity");
            return FALSE;
        }
        if (SpellImmunityCheck(oTarget, oCaster, iSpell, FALSE))
        {
            SetLocalString(oCaster, METACT_LOCAL_REJECT_REASON, "spell_immunity");
            return FALSE;
        }
        if (SpellAbsorptionLimitedCheck(oTarget, oCaster, iSpell, -1, iSpellLevel, FALSE, FALSE))
        {
            SetLocalString(oCaster, METACT_LOCAL_REJECT_REASON, "limited_absorption");
            return FALSE;
        }
        if (SpellAbsorptionUnlimitedCheck(oTarget, oCaster, iSpell, -1, iSpellLevel, FALSE))
        {
            SetLocalString(oCaster, METACT_LOCAL_REJECT_REASON, "unlimited_absorption");
            return FALSE;
        }
        int iResistance = GetSpellResistance(oTarget);
        if (iResistance > 0 && iResistance > GetCasterLevel(oCaster) + 20)
        {
            SetLocalString(oCaster, METACT_LOCAL_REJECT_REASON, "unbeatable_spell_resistance");
            return FALSE;
        }
    }
    else if (METACT_GetSpellRole(iSpell) != METACT_ROLE_SUMMON && GetHasSpellEffect(iSpell, oTarget))
    {
        SetLocalString(oCaster, METACT_LOCAL_REJECT_REASON, "effect_already_present");
        return FALSE;
    }
    SetLocalInt(oCaster, "METACT_META_SPELL", iSpell);
    SetLocalObject(oCaster, "METACT_META_TARGET", oTarget);
    ExecuteScript("metact_meta_ext", oCaster);
    DeleteLocalInt(oCaster, "METACT_META_SPELL");
    DeleteLocalObject(oCaster, "METACT_META_TARGET");
    int iDecision = GetLocalInt(oCaster, "METACT_META_DECISION");
    DeleteLocalInt(oCaster, "METACT_META_DECISION");
    if (iDecision < 0) SetLocalString(oCaster, METACT_LOCAL_REJECT_REASON, "extension_rejected");
    return iDecision < 0 ? FALSE : TRUE;
}
