// Original work Copyright (c) 2020 Mischa Dutzik (Ravick).
// Relicensed under the MIT License by Albeoris. See THIRD_PARTY_NOTICES.md.

#include "melse_lib"

void main() 
{
    MELSE_OnAcquiredItem(OBJECT_SELF, GetModuleItemAcquired(), GetModuleItemAcquiredBy(), GetModuleItemAcquiredFrom(), GetModuleItemAcquiredStackSize());
}
