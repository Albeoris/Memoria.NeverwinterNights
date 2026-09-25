// Shared helpers for engine GUI panels used by Memoria-owned inventory items.

void MEMORIA_GUI_SuppressItemExaminePanel(object oPC, object oItem)
{
    if (!GetIsPC(oPC) || !GetIsObjectValid(oItem) || GetItemPossessor(oItem) != oPC)
        return;
    SetGuiPanelDisabled(oPC, GUI_PANEL_EXAMINE_ITEM, FALSE, oItem);
    SetGuiPanelDisabled(oPC, GUI_PANEL_EXAMINE_ITEM, TRUE, oItem);
}

void MEMORIA_GUI_ScheduleItemExamineSuppression(object oPC, object oItem)
{
    MEMORIA_GUI_SuppressItemExaminePanel(oPC, oItem);
    DelayCommand(0.0f, MEMORIA_GUI_SuppressItemExaminePanel(oPC, oItem));
    DelayCommand(0.1f, MEMORIA_GUI_SuppressItemExaminePanel(oPC, oItem));
}
