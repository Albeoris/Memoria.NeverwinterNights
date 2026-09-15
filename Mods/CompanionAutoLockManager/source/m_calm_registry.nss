#include "m_calm_lib"

void main()
{
    if (M_CALM_IsRootPlayer(OBJECT_SELF))
        M_CALM_RunLockRegistryDispatcher(OBJECT_SELF);
}
