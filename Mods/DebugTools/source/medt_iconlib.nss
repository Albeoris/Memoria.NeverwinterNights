// Item icon discovery and appearance selection.

#include "medt_lib"

string MEDT_PadItemModel(int iModel)
{
    if (iModel < 10)
    {
        return "00" + IntToString(iModel);
    }
    if (iModel < 100)
    {
        return "0" + IntToString(iModel);
    }
    return IntToString(iModel);
}

string MEDT_GetIconResource(string sItemClass, int iModel)
{
    return "i" + GetStringLowerCase(sItemClass) + "_" + MEDT_PadItemModel(iModel);
}

int MEDT_IsIconAvailable(string sItemClass, int iModel)
{
    string sIcon = MEDT_GetIconResource(sItemClass, iModel);
    return ResManGetAliasFor(sIcon, RESTYPE_TGA) != "" || ResManGetAliasFor(sIcon, RESTYPE_DDS) != "";
}

json MEDT_BuildIconWindow(object oPC, object oItem)
{
    int iBaseItem = GetBaseItemType(oItem);
    string sItemClass = Get2DAString("baseitems", "ItemClass", iBaseItem);
    int iCurrent = GetItemAppearance(oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0);
    json jRows = JsonArray();
    int iCount;
    int iModel;
    for (iModel = 0; iModel <= 255; iModel++)
    {
        if (!MEDT_IsIconAvailable(sItemClass, iModel))
        {
            continue;
        }
        string sIcon = MEDT_GetIconResource(sItemClass, iModel);
        json jRow = JsonArray();
        json jButton = NuiId(NuiButtonImage(JsonString(sIcon)), "icon_" + IntToString(iModel));
        jRow = JsonArrayInsert(jRow, NuiWidth(NuiTooltip(jButton, JsonString(sIcon)), 44.0f));
        string sLabel = MEDT_PadItemModel(iModel) + " — " + sIcon;
        if (iModel == iCurrent)
        {
            sLabel += " " + MEDT_GetText(oPC, "icon_current");
        }
        json jLabel = NuiLabel(JsonString(sLabel), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_MIDDLE));
        if (iModel == iCurrent)
        {
            jLabel = NuiStyleForegroundColor(jLabel, NuiColor(225, 190, 95));
        }
        jRow = JsonArrayInsert(jRow, jLabel);
        jRows = JsonArrayInsert(jRows, NuiHeight(NuiRow(jRow), 46.0f));
        iCount++;
    }
    if (iCount == 0)
    {
        jRows = JsonArrayInsert(jRows, NuiHeight(NuiText(JsonString(MEDT_GetText(oPC, "icon_none")), TRUE, NUI_SCROLLBARS_NONE), 70.0f));
    }
    json jRoot = JsonArray();
    string sSummary = MEDT_GetText(oPC, "icon_summary");
    sSummary = MEDT_ReplaceToken(sSummary, "{class}", sItemClass);
    sSummary = MEDT_ReplaceToken(sSummary, "{base}", IntToString(iBaseItem));
    sSummary = MEDT_ReplaceToken(sSummary, "{count}", IntToString(iCount));
    jRoot = JsonArrayInsert(jRoot, NuiHeight(NuiText(JsonString(sSummary), FALSE, NUI_SCROLLBARS_NONE), 38.0f));
    jRoot = JsonArrayInsert(jRoot, NuiHeight(NuiGroup(NuiCol(jRows), TRUE, NUI_SCROLLBARS_Y), 410.0f));
    return NuiWindow(NuiCol(jRoot), JsonString(MEDT_GetText(oPC, "icon_title")), NuiRect(-1.0f, -1.0f, 540.0f, 500.0f), JsonBool(FALSE), JsonBool(FALSE), JsonBool(TRUE), JsonBool(FALSE), JsonBool(TRUE));
}

void MEDT_OpenIconPicker(object oPC, object oItem)
{
    if (!GetIsObjectValid(oItem) || GetObjectType(oItem) != OBJECT_TYPE_ITEM)
    {
        SendMessageToPC(oPC, MEDT_GetText(oPC, "icon_item_required"));
        return;
    }
    int iBaseItem = GetBaseItemType(oItem);
    string sItemClass = Get2DAString("baseitems", "ItemClass", iBaseItem);
    if (Get2DAString("baseitems", "ModelType", iBaseItem) != "0" || sItemClass == "" || sItemClass == "****")
    {
        SendMessageToPC(oPC, MEDT_GetText(oPC, "icon_unsupported"));
        return;
    }
    int iOldToken = NuiFindWindow(oPC, MEDT_ICON_WINDOW_ID);
    if (iOldToken > 0)
    {
        NuiDestroy(oPC, iOldToken);
    }
    SetLocalObject(oPC, MEDT_LOCAL_ICON_TARGET, oItem);
    NuiCreate(oPC, MEDT_BuildIconWindow(oPC, oItem), MEDT_ICON_WINDOW_ID, "medt_nuievt");
}

void MEDT_ChangeItemIcon(object oPC, int iToken, int iModel)
{
    object oItem = GetLocalObject(oPC, MEDT_LOCAL_ICON_TARGET);
    if (!GetIsObjectValid(oItem) || GetObjectType(oItem) != OBJECT_TYPE_ITEM)
    {
        DeleteLocalObject(oPC, MEDT_LOCAL_ICON_TARGET);
        NuiDestroy(oPC, iToken);
        SendMessageToPC(oPC, MEDT_GetText(oPC, "target_missing"));
        return;
    }
    int iBaseItem = GetBaseItemType(oItem);
    string sItemClass = Get2DAString("baseitems", "ItemClass", iBaseItem);
    if (Get2DAString("baseitems", "ModelType", iBaseItem) != "0" || !MEDT_IsIconAvailable(sItemClass, iModel))
    {
        SendMessageToPC(oPC, MEDT_GetText(oPC, "icon_change_failed"));
        return;
    }
    string sName = GetName(oItem);
    object oNewItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, iModel, TRUE);
    if (!GetIsObjectValid(oNewItem) || GetItemAppearance(oNewItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0) != iModel)
    {
        if (GetIsObjectValid(oNewItem))
        {
            DestroyObject(oNewItem);
        }
        SendMessageToPC(oPC, MEDT_GetText(oPC, "icon_change_failed"));
        return;
    }
    DestroyObject(oItem);
    DeleteLocalObject(oPC, MEDT_LOCAL_ICON_TARGET);
    NuiDestroy(oPC, iToken);
    string sMessage = MEDT_GetText(oPC, "icon_changed");
    sMessage = MEDT_ReplaceToken(sMessage, "{name}", sName);
    sMessage = MEDT_ReplaceToken(sMessage, "{model}", IntToString(iModel));
    sMessage = MEDT_ReplaceToken(sMessage, "{icon}", MEDT_GetIconResource(sItemClass, iModel));
    SendMessageToPC(oPC, sMessage);
}
