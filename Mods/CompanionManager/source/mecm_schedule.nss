#include "mecm_lib"

void main()
{
    if (MECM_IsRootPlayer(OBJECT_SELF))
        MECM_RunSchedulerDispatcher(OBJECT_SELF);
}
