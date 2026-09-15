// Original work Copyright (c) 2020 Mischa Dutzik (Ravick).
// Relicensed under the MIT License by Albeoris. See THIRD_PARTY_NOTICES.md.

#include "m_lse_lib"
#include "x0_i0_position"

void main()
{
    object oTarget = GetSpellTargetObject();
    if (!GetIsObjectValid(oTarget))
    {
        oTarget = GetNearestCreatureToLocation(CREATURE_TYPE_IS_ALIVE, FALSE, GetSpellTargetLocation());
    }
    M_LSE_UseFeat(GetFirstPC(), oTarget, M_LSE_FEAT_OPTIONS);
}