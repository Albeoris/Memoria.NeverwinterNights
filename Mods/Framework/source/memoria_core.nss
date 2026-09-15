// Shared runtime helpers for Memoria mods.

/// @brief Resolves the highest master in an object's ownership chain, following at most eight links.
/// @param oObject Object from which to start resolving ownership.
/// @return The highest object reached, or the input object when it has no valid master.
object MEMORIA_GetRootPlayer(object oObject)
{
    object oCurrent = oObject;
    int iDepth;
    for (iDepth = 0; iDepth < 8; iDepth++)
    {
        object oMaster = GetMaster(oCurrent);
        if (!GetIsObjectValid(oMaster)) return oCurrent;
        oCurrent = oMaster;
    }
    return oCurrent;
}

/// @brief Determines whether a creature belongs to a non-DM player through its master chain.
/// @param oCreature Creature or associate to inspect.
/// @return TRUE when the root owner is a valid player character that is not a DM; otherwise FALSE.
int MEMORIA_IsPlayerPartyCreature(object oCreature)
{
    object oRoot = MEMORIA_GetRootPlayer(oCreature);
    return GetIsObjectValid(oRoot) && GetIsPC(oRoot) && !GetIsDM(oRoot);
}

/// @brief Determines whether a valid creature's root owner is the specified player.
/// @param oCreature Creature or associate to inspect.
/// @param oPlayer Expected root player object.
/// @return TRUE when oCreature is a creature rooted at oPlayer; otherwise FALSE.
int MEMORIA_IsPartyCreature(object oCreature, object oPlayer)
{
    return GetIsObjectValid(oCreature) && GetObjectType(oCreature) == OBJECT_TYPE_CREATURE && MEMORIA_GetRootPlayer(oCreature) == oPlayer;
}

/// @brief Determines whether an object is an unpossessed, masterless, non-DM player character.
/// @param oCreature Object to inspect.
/// @return TRUE when the object is a root player character; otherwise FALSE.
int MEMORIA_IsRootPlayerCharacter(object oCreature)
{
    return GetIsObjectValid(oCreature) && GetIsPC(oCreature) && !GetIsDM(oCreature) && !GetIsObjectValid(GetMaster(oCreature)) && !GetIsPossessedFamiliar(oCreature);
}

/// @brief Determines whether a player is currently possessing their familiar.
/// @param oPlayer Player whose familiar is inspected.
/// @return TRUE when the player has a valid possessed familiar; otherwise FALSE.
int MEMORIA_IsPossessingFamiliar(object oPlayer)
{
    object oFamiliar = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oPlayer);
    return GetIsObjectValid(oFamiliar) && GetIsPossessedFamiliar(oFamiliar);
}

/// @brief Calculates a creature's current hit points as an integer percentage of its maximum hit points.
/// @param oCreature Creature whose health is measured.
/// @return Truncated health percentage, or 0 when the maximum hit points are not positive.
int MEMORIA_GetHealthPercent(object oCreature)
{
    int iMaximum = GetMaxHitPoints(oCreature);
    return iMaximum > 0 ? GetCurrentHitPoints(oCreature) * 100 / iMaximum : 0;
}
