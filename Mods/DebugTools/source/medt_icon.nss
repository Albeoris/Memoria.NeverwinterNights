#include "medt_lib"

void main()
{
    if (GetIsPC(OBJECT_SELF))
    {
        MEDT_StartTargeting(OBJECT_SELF, MEDT_TARGET_MODE_ICON);
    }
}
