// Original work Copyright (c) 2020 Mischa Dutzik (Ravick).
// Relicensed under the MIT License by Albeoris. See THIRD_PARTY_NOTICES.md.

#include "esi_lib"

void main()
{
    ESI_ExecuteEventScripts(OBJECT_SELF, EVENT_SCRIPT_MODULE_ON_PLAYER_TARGET);
}
