// Original work Copyright (c) 2020 Mischa Dutzik (Ravick).
// Relicensed under the MIT License by Albeoris. See THIRD_PARTY_NOTICES.md.

#include "melse_lib"

void main() 
{
    object oModule = GetModule();
    if (GetLocalString(oModule, "MELSE_RUNTIME") != "1.1-memoria.1") SetLocalString(oModule, "MELSE_RUNTIME", "1.1-memoria.1");
    MELSE_OnHeartbeat(OBJECT_SELF);
}
