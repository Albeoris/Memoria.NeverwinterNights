#include "m_calm_lib"

void main()
{
    object oBlockingDoor = GetBlockingDoor();
    DeleteLocalObject(OBJECT_SELF, M_CALM_LOCAL_BLOCKING_DOOR);
    if (GetIsObjectValid(oBlockingDoor))
        SetLocalObject(OBJECT_SELF, M_CALM_LOCAL_BLOCKING_DOOR, oBlockingDoor);
}
