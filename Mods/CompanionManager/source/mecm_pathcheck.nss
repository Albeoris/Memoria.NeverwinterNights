#include "mecm_lib"

void main()
{
    object oBlockingDoor = GetBlockingDoor();
    DeleteLocalObject(OBJECT_SELF, MECM_LOCAL_BLOCKING_DOOR);
    if (GetIsObjectValid(oBlockingDoor))
        SetLocalObject(OBJECT_SELF, MECM_LOCAL_BLOCKING_DOOR, oBlockingDoor);
}
