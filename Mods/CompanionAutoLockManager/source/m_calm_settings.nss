#include "m_calm_ui"

void main()
{
    object oPC = M_CALM_GetRootMaster(OBJECT_SELF);
    if (M_CALM_IsRootPlayer(oPC))
        M_CALM_OpenSettings(oPC);
}
