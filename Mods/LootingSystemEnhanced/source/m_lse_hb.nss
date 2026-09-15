// Loader registration point and legacy M_LSE collision detector.
// Relicensed under the MIT License by Albeoris. See THIRD_PARTY_NOTICES.md.

void main()
{
    object oModule = GetModule();
    DeleteLocalString(oModule, "M_LSE_RUNTIME");
    ExecuteScript("m_lse_crthrtbt", OBJECT_SELF);
    if (GetLocalString(oModule, "M_LSE_RUNTIME") != "1.1-memoria.1") SendMessageToPC(OBJECT_SELF, "M_LSE conflict: legacy and Memoria M_LSE resources are mixed. Remove or disable the legacy M_LSE installation.");
}

