// Original work Copyright (c) 2020 Mischa Dutzik (Ravick).
// Relicensed under the MIT License by Albeoris. See THIRD_PARTY_NOTICES.md.

#include "m_lse_lib"

void main() 
{
    object oModule = GetModule();
    if (GetLocalString(oModule, "M_LSE_RUNTIME") != "1.1-memoria.1") SetLocalString(oModule, "M_LSE_RUNTIME", "1.1-memoria.1");
    M_LSE_OnHeartbeat(OBJECT_SELF);
}
