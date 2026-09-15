// Loader registration point and legacy MELSE collision detector.
// Relicensed under the MIT License by Albeoris. See THIRD_PARTY_NOTICES.md.

#include "nw_inc_nui"

const string MELSE_CHECK_WINDOW = "melse_check";

json MELSE_BuildCheckWindow()
{
    return NuiWindow(NuiVisible(NuiSpacer(), JsonBool(FALSE)), JsonString(""), NuiRect(-100.0f, -100.0f, 1.0f, 1.0f), JsonBool(FALSE), JsonBool(FALSE), JsonBool(FALSE), JsonBool(TRUE), JsonBool(FALSE), JsonBool(FALSE));
}

void main()
{
    int nToken = NuiFindWindow(OBJECT_SELF, MELSE_CHECK_WINDOW);
    if (nToken > 0 && JsonGetInt(NuiGetUserData(OBJECT_SELF, nToken)))
    {
        ExecuteScript("melse_crthrtbt", OBJECT_SELF);
        return;
    }
    object oModule = GetModule();
    DeleteLocalString(oModule, "MELSE_RUNTIME");
    ExecuteScript("melse_crthrtbt", OBJECT_SELF);
    if (GetLocalString(oModule, "MELSE_RUNTIME") != "1.1-memoria.1") SendMessageToPC(OBJECT_SELF, "MELSE conflict: legacy and Memoria MELSE resources are mixed. Remove or disable the legacy MELSE installation.");
    nToken = NuiCreate(OBJECT_SELF, MELSE_BuildCheckWindow(), MELSE_CHECK_WINDOW, "meboot_noop");
    if (nToken > 0) NuiSetUserData(OBJECT_SELF, nToken, JsonInt(TRUE));
}
