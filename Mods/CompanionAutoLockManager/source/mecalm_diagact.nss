#include "mecalm_lib"

void main()
{
    object oTarget = GetLocalObject(OBJECT_SELF, MECALM_LOCAL_CHECK_TARGET);
    int iType = GetObjectType(oTarget);
    int bPossible;
    if (iType == OBJECT_TYPE_DOOR)
        bPossible = GetIsDoorActionPossible(oTarget, DOOR_ACTION_UNLOCK);
    else if (iType == OBJECT_TYPE_PLACEABLE)
        bPossible = GetIsPlaceableObjectActionPossible(oTarget, PLACEABLE_ACTION_UNLOCK);
    SetLocalInt(OBJECT_SELF, MECALM_LOCAL_CHECK_RESULT, bPossible);
}
