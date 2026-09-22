#include "mecm_lib"

const string MECM_INVENTORY_WARNING_WINDOW = "mecm_invwarn";

json MECM_BuildInventoryWarning(object oPC)
{
    json jColumn = JsonArray();
    json jWarning = NuiStyleForegroundColor(NuiText(JsonString(MECM_GetText("inventory_warning", oPC)), FALSE, NUI_SCROLLBARS_NONE), NuiColor(235, 70, 70));
    jColumn = JsonArrayInsert(jColumn, NuiHeight(jWarning, 92.0f));
    json jButtons = JsonArray();
    jButtons = JsonArrayInsert(jButtons, NuiWidth(NuiId(NuiButton(JsonString(MECM_GetText("inventory_warning_yes", oPC))), "yes"), 150.0f));
    jButtons = JsonArrayInsert(jButtons, NuiSpacer());
    jButtons = JsonArrayInsert(jButtons, NuiWidth(NuiId(NuiButton(JsonString(MECM_GetText("inventory_warning_no", oPC))), "no"), 150.0f));
    jColumn = JsonArrayInsert(jColumn, NuiHeight(NuiRow(jButtons), 36.0f));
    return NuiWindow(NuiCol(jColumn), JsonString(MECM_GetText("inventory_warning_title", oPC)), NuiRect(-1.0f, -1.0f, 620.0f, 190.0f), JsonBool(FALSE), JsonBool(FALSE), JsonBool(TRUE), JsonBool(FALSE), JsonBool(TRUE));
}

void main()
{
    object oPC = MECM_GetRootMaster(OBJECT_SELF);
    if (!MECM_IsRootPlayer(oPC))
        return;
    int iOldToken = NuiFindWindow(oPC, MECM_INVENTORY_WARNING_WINDOW);
    if (iOldToken > 0)
        NuiDestroy(oPC, iOldToken);
    NuiCreate(oPC, MECM_BuildInventoryWarning(oPC), MECM_INVENTORY_WARNING_WINDOW, "mecm_invwevt");
}
