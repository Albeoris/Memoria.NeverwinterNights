// Shared recursive associate traversal helpers for Memoria mods.

/// @brief Retrieves a cached group member from a player-local object slot.
/// @param oPlayer Player object that owns the cache.
/// @param sMemberLocalPrefix Prefix used for indexed member locals.
/// @param iIndex One-based member index.
/// @return Cached member object, or OBJECT_INVALID when the slot is empty.
object MEMORIA_GetGroupMember(object oPlayer, string sMemberLocalPrefix, int iIndex)
{
    return GetLocalObject(oPlayer, sMemberLocalPrefix + IntToString(iIndex));
}

/// @brief Retrieves the number of members stored in a player's group cache.
/// @param oPlayer Player object that owns the cache.
/// @param sCountLocal Name of the local integer containing the member count.
/// @return Cached group member count.
int MEMORIA_GetGroupCount(object oPlayer, string sCountLocal)
{
    return GetLocalInt(oPlayer, sCountLocal);
}

/// @brief Searches a player's group cache for a creature.
/// @param oPlayer Player object that owns the cache.
/// @param oCreature Creature to find.
/// @param sCountLocal Name of the local integer containing the member count.
/// @param sMemberLocalPrefix Prefix used for indexed member locals.
/// @return TRUE when the creature is present in the cache; otherwise FALSE.
int MEMORIA_IsGroupMemberCached(object oPlayer, object oCreature, string sCountLocal, string sMemberLocalPrefix)
{
    int iIndex;
    for (iIndex = 1; iIndex <= MEMORIA_GetGroupCount(oPlayer, sCountLocal); iIndex++)
    {
        if (MEMORIA_GetGroupMember(oPlayer, sMemberLocalPrefix, iIndex) == oCreature) return TRUE;
    }
    return FALSE;
}

/// @brief Adds a valid, same-area, uncached creature to a player's group cache when capacity permits.
/// @param oPlayer Player object that owns the cache.
/// @param oCreature Creature to add.
/// @param sCountLocal Name of the local integer containing the member count.
/// @param sMemberLocalPrefix Prefix used for indexed member locals.
/// @param iMaximumMembers Maximum number of cached members.
/// @return Nothing.
void MEMORIA_AddGroupMember(object oPlayer, object oCreature, string sCountLocal, string sMemberLocalPrefix, int iMaximumMembers)
{
    if (!GetIsObjectValid(oCreature) || GetArea(oCreature) != GetArea(oPlayer) || MEMORIA_IsGroupMemberCached(oPlayer, oCreature, sCountLocal, sMemberLocalPrefix)) return;
    int iCount = MEMORIA_GetGroupCount(oPlayer, sCountLocal);
    if (iCount >= iMaximumMembers) return;
    iCount++;
    SetLocalInt(oPlayer, sCountLocal, iCount);
    SetLocalObject(oPlayer, sMemberLocalPrefix + IntToString(iCount), oCreature);
}

/// @brief Rebuilds a player's group cache by breadth-first traversal of recursively owned associates in the same area.
/// @param oPlayer Root player and first cached member.
/// @param sCountLocal Name of the local integer containing the member count.
/// @param sMemberLocalPrefix Prefix used for indexed member locals.
/// @param iMaximumMembers Maximum number of members to cache.
/// @return Nothing.
void MEMORIA_BuildGroupCache(object oPlayer, string sCountLocal, string sMemberLocalPrefix, int iMaximumMembers)
{
    int iIndex;
    int iOldCount = MEMORIA_GetGroupCount(oPlayer, sCountLocal);
    for (iIndex = 1; iIndex <= iOldCount; iIndex++) DeleteLocalObject(oPlayer, sMemberLocalPrefix + IntToString(iIndex));
    SetLocalInt(oPlayer, sCountLocal, 1);
    SetLocalObject(oPlayer, sMemberLocalPrefix + "1", oPlayer);
    int iMasterIndex = 1;
    while (iMasterIndex <= MEMORIA_GetGroupCount(oPlayer, sCountLocal) && MEMORIA_GetGroupCount(oPlayer, sCountLocal) < iMaximumMembers)
    {
        object oMaster = MEMORIA_GetGroupMember(oPlayer, sMemberLocalPrefix, iMasterIndex);
        int iType;
        for (iType = ASSOCIATE_TYPE_HENCHMAN; iType <= ASSOCIATE_TYPE_DOMINATED; iType++)
        {
            int iNth = 1;
            object oAssociate = GetAssociate(iType, oMaster, iNth);
            while (GetIsObjectValid(oAssociate) && MEMORIA_GetGroupCount(oPlayer, sCountLocal) < iMaximumMembers)
            {
                MEMORIA_AddGroupMember(oPlayer, oAssociate, sCountLocal, sMemberLocalPrefix, iMaximumMembers);
                iNth++;
                oAssociate = GetAssociate(iType, oMaster, iNth);
            }
        }
        iMasterIndex++;
    }
}
