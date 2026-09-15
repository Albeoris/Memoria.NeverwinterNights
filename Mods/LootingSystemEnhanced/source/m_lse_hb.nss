// Loader registration point and legacy M_LSE collision detector.
// Relicensed under the MIT License by Albeoris. See THIRD_PARTY_NOTICES.md.

#include "nw_inc_nui"

const string M_LSE_CHECK_WINDOW = "m_lse_check";

json M_LSE_BuildCheckWindow()
{
    return NuiWindow(NuiVisible(NuiSpacer(), JsonBool(FALSE)), JsonString(""), NuiRect(-100.0f, -100.0f, 1.0f, 1.0f), JsonBool(FALSE), JsonBool(FALSE), JsonBool(FALSE), JsonBool(TRUE), JsonBool(FALSE), JsonBool(FALSE));
}

void main()
{
    int nToken = NuiFindWindow(OBJECT_SELF, M_LSE_CHECK_WINDOW);
    if (nToken > 0 && JsonGetInt(NuiGetUserData(OBJECT_SELF, nToken)))
    {
        ExecuteScript("m_lse_crthrtbt", OBJECT_SELF);
        return;
    }
    object oModule = GetModule();
    DeleteLocalString(oModule, "M_LSE_RUNTIME");
    ExecuteScript("m_lse_crthrtbt", OBJECT_SELF);
    if (GetLocalString(oModule, "M_LSE_RUNTIME") != "1.1-memoria.1") SendMessageToPC(OBJECT_SELF, "M_LSE conflict: legacy and Memoria M_LSE resources are mixed. Remove or disable the legacy M_LSE installation.");
    nToken = NuiCreate(OBJECT_SELF, M_LSE_BuildCheckWindow(), M_LSE_CHECK_WINDOW, "m_boot_noop");
    if (nToken > 0) NuiSetUserData(OBJECT_SELF, nToken, JsonInt(TRUE));
}
