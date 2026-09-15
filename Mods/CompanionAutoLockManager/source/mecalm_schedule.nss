#include "mecalm_lib"

void main()
{
    if (MECALM_IsRootPlayer(OBJECT_SELF))
        MECALM_RunSchedulerDispatcher(OBJECT_SELF);
}
