void main()
{
    int i = StringToInt(GetScriptParam("M_TACT_TEXT_KEY"));
    if (i == 27) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Friendly-fire policy"); return; }
    if (i == 64) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Enemy rating at least"); return; }
    if (i == 65) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Enemy rating at most"); return; }
    if (i == 66) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "TARGET PRIORITIES"); return; }
    if (i == 67) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Add priority"); return; }
    if (i == 68) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Priority editor"); return; }
    if (i == 69) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Enemy spellcasters"); return; }
    if (i == 70) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Enemies with highest rating"); return; }
    if (i == 71) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Enemies with lowest rating"); return; }
    if (i == 72) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Enemies with lowest health"); return; }
    if (i == 73) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Enemies with highest health"); return; }
    if (i == 74) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Then: all other enemies"); return; }
    if (i == 75) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Criterion"); return; }
    if (i == 76) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "RULES"); return; }
    if (i == 77) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Decision debugging"); return; }
    if (i == 78) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Inspect selected target"); return; }
    if (i == 79) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "[M_TACT] Select a creature for the diagnostic report."); return; }
    if (i == 80) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "[M_TACT] Diagnostic target selection cancelled."); return; }
    if (i == 81) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Area is determined automatically by the spell"); return; }
    if (i == 82) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Unrestricted"); return; }
    if (i == 83) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Check before casting"); return; }
    if (i == 84) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Check while casting"); return; }
    if (i == 85) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Only while allies are stationary"); return; }
    if (i == 86) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "ACTIONS"); return; }
    if (i == 88) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Global priorities"); return; }
    if (i == 89) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Rule priorities"); return; }
    if (i == 90) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Action editor"); return; }
    if (i == 91) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Add action"); return; }
    if (i == 92) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Enemy rating"); return; }
    if (i == 93) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Comparison"); return; }
    if (i == 94) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "At least"); return; }
    if (i == 95) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "At most"); return; }
    if (i == 96) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Health below"); return; }
    if (i == 97) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Subject"); return; }
    if (i == 98) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "This character"); return; }
    if (i == 99) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "An ally"); return; }
    if (i == 100) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Only hostile area actions apply; the best cluster is selected automatically."); return; }
    if (i == 101) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "According to target priorities"); return; }
    if (i == 102) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "No actions yet"); return; }
    if (i == 103) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Action priorities"); return; }
    if (i == 104) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Then: global, then other enemies"); return; }
    if (i == 105) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Then: rule, global, other enemies"); return; }
    if (i == 106) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Allies are ignored and may be hit by the spell."); return; }
    if (i == 107) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "The area is checked before casting.\nCasting is not cancelled afterwards."); return; }
    if (i == 108) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Safety is rechecked while casting.\nNew danger cancels the cast."); return; }
    if (i == 109) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Casting waits until allies stop.\nThe area is then checked once."); return; }
    if (i == 110) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Equip item"); return; }
    if (i == 111) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Equippable items"); return; }
    string s = i == 1 ? "Tactics Architect" : i == 2 ? "Opens the visual tactics editor. Configure prioritized actions and conditions for the hero, a specific companion, or a creature template." : i == 3 ? "Tactics Architect installed, version" : i == 4 ? "Tactics Architect" : i == 5 ? "Character" : i == 6 ? "Profile scope" : i == 7 ? "This character" : i == 8 ? "This creature type" : i == 9 ? "Current tactic" : i == 10 ? "New" : i == 11 ? "Delete" : i == 12 ? "Enabled" : i == 13 ? "Tactic name" : i == 14 ? "Rename" : i == 15 ? "ACTION" : i == 16 ? "WHEN" : i == 17 ? "Up" : i == 18 ? "Down" : i == 19 ? "Edit" : i == 20 ? "Add rule" : i == 21 ? "Close" : i == 22 ? "Edit rule" : i == 23 ? "Choose action" : i == 24 ? "Choose condition" : i == 25 ? "Advanced" : i == 26 ? "May move into range" : i == 27 ? "Allow friendly fire" : i == 28 ? "Source" : i == 29 ? "Any available source" : i == 30 ? "Spellbook slot" : i == 31 ? "Selected item type" : i == 32 ? "Target" : i == 33 ? "Automatic" : i == 34 ? "Self" : i == 35 ? "Nearest sensible enemy" : i == 36 ? "Lowest-health ally" : i == 37 ? "Best enemy cluster" : i == 38 ? "Always" : i == 39 ? "Enemies nearby" : i == 40 ? "Enemies clustered" : i == 41 ? "Self health below" : i == 42 ? "Ally health below" : i == 43 ? "No summoned creature" : i == 44 ? "No familiar summoned" : i == 45 ? "Threshold" : i == 46 ? "Radius (metres)" : i == 47 ? "Save" : i == 48 ? "Cancel" : i == 49 ? "Choose a spell or item" : i == 50 ? "Search" : i == 51 ? "Previous" : i == 52 ? "Next" : i == 53 ? "Choose" : i == 54 ? "Summon familiar" : i == 55 ? "Attack nearest enemy" : i == 56 ? "Spell or usable item..." : i == 57 ? "Not configured" : i == 58 ? "Default" : i == 59 ? "No rules yet. Add the first priority." : i == 60 ? "Main character" : i == 61 ? "Invalid value." : i == 62 ? "Enemy with lowest health" : i == 63 ? "Enemy with highest health" : "";
    SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", s);
}
