// Original work Copyright (c) 2020 Mischa Dutzik (Ravick).
// Relicensed under the MIT License by Albeoris. See THIRD_PARTY_NOTICES.md.

#include "m_lse_lib"

void main() 
{
    M_LSE_OnSpellCastAt(OBJECT_SELF, GetLastSpellHarmful(), GetLastSpellCaster(), GetLastSpell());
}
