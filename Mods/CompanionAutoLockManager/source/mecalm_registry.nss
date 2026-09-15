#include "mecalm_lib"

void main()
{
    if (MECALM_IsRootPlayer(OBJECT_SELF))
        MECALM_RunLockRegistryDispatcher(OBJECT_SELF);
}
