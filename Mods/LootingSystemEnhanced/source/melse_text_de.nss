// Original work Copyright (c) 2020 Mischa Dutzik (Ravick).
// Relicensed under the MIT License by Albeoris. See THIRD_PARTY_NOTICES.md.

#include "melse_sin_lib"

void main()
{
    int nStrRef = StringToInt(GetScriptParam(MELSE_SIN_PARAM_STRREF));
    
    string sString = nStrRef == 1   ? "Ich sollte mich nach Schätzen umsehen."
                   : nStrRef == 2   ? "Diese Gegend scheint frei von Schätzen zu sein."
                   : nStrRef == 5   ? "hat einen Quest-Gegenstand fallengelassen!"
                   : nStrRef == 7   ? "hat einen getragenen Gegenstand fallengelassen!"
                   : nStrRef == 8   ? "Zuletzt erbeutet von "
                   : nStrRef == 9   ? "in Bereich "
                   : nStrRef == 10  ? "Gegenstand (Nicht identifiziert)"
                   : nStrRef == 11  ? "wird ignoriert."

                   : nStrRef == 99   ? "Looting System Enhanced"
                   : nStrRef == 100  ? "Zurück..."
                   : nStrRef == 101  ? "Behältnisse scannen"
                   : nStrRef == 102  ? "Behältnisse nachverfolgen"
                   : nStrRef == 103  ? "Behältnisse automatisch plündern"
                   : nStrRef == 104  ? "Plünderbare Leichen"
                   : nStrRef == 105  ? "Plünderbare Leichen verwesen nach Plünderung"
                   : nStrRef == 106  ? "Plünderbare Leichen verwesen mit der Zeit"
                   : nStrRef == 107  ? "Plünderbare Leichen können wiederbelebt werden"
                   : nStrRef == 108  ? "Leichen automatisch plündern nach Untersuchung"
                   : nStrRef == 109  ? "Leichen automatisch plündern nach dem Tod"
                   : nStrRef == 110  ? "Leichen automatisch plündern nach dem Tod durch Begleiter"
                   : nStrRef == 111  ? "Gegenstandsbeschreibung zeigt Quelle des letzten Funds"
                   : nStrRef == 112  ? "Gegenstandsbeschreibung zeigt Basispreis"

                   : nStrRef == 120  ? "Zurück..."
                   : nStrRef == 121  ? "Plünderbare Leichen Verwesungsdauer in Sekunden"
                   : nStrRef == 122  ? "Autom. Plündern von Gegenst. mit Mindestpreis"
                   : nStrRef == 123  ? "Autom. Plündern von Gegenst. mit Maximalgewicht"

                   : nStrRef == 900  ? "Schließen."
                   : nStrRef == 901  ? "Features..."
                   : nStrRef == 902  ? "Parameter..."
                   : nStrRef == 911  ? "+ 1"
                   : nStrRef == 912  ? "+ 10"
                   : nStrRef == 913  ? "+ 100"
                   : nStrRef == 914  ? "- 1"
                   : nStrRef == 915  ? "- 10"
                   : nStrRef == 916  ? "- 100"

                   : nStrRef == 951  ? "Zerstöre ausgewählte Leiche!"
                   : nStrRef == 952  ? "Zerstöre alle Leichen in aktuellem Gebiet!"
                   : nStrRef == 953  ? "Zerstöre alle Leichen in aktuellem Modul!"

                   : nStrRef == 501  ? "Ravick's Looting System Enhanced: Installierte Version"
                   : nStrRef == 502  ? "Ravick's Looting System Enhanced: Aktualisiert auf Version"

                   : nStrRef == 601  ? "Erkläre mir, wie ich MELSE verwende!"
                   : nStrRef == 602  ? "Alle Features von MELSE wurden automatisch installiert. Es muss nichts weiter unternommen werden, es sei denn du möchtest bestimmte Features umschalten oder einstellen, was im Folgenden erläutert wird."
                   : nStrRef == 603  ? "Um mit MELSE zu interagieren, finde und benutze das \"Spieler Werkzeug 9\" unter den \"Spezialfähigkeiten\" in deinem Rechtsklick-Menü. Du wirst dann ein Ziel auswählen müssen, wovon die Art der Interaktion abhängt. Treffe jedoch zunächst keine Auswahl, das würde nämlich dieses Tutorial schließen!"
                   : nStrRef == 604  ? "Was passiert, wenn ich meinen Charakter auswähle?"
                   : nStrRef == 605  ? "Was passiert, wenn ich eine Leiche auswähle?"
                   : nStrRef == 606  ? "Ich weiß nun, wie ich MELSE verwende. Schließe das Tutorial."
                   : nStrRef == 607  ? "Wenn du deinen Charakter auswählst, wird das Konfigurationsfenster geöffnet. Hier kannst du einzelne Features umschalten oder bestimmte Parameter ändern."
                   : nStrRef == 608  ? "Wenn du die Leiche eines Feindes auswählst, wird das Werkzeugfenster geöffnet. Momentan beschränken sich die verfügbaren Optionen auf die Fehlerbehebung, wie das Zerstören von herumliegenden Leichen, um diesbezüglich mögliche Fehler in gewissen Modulskripten zu beheben, wenn diese von der Existenz einer Kreatur abhängen (tot oder lebendig)."

                   :                STRING_EMPTY;

    SetLocalString(OBJECT_SELF, "MELSE_CONFIG_TEXT_RESULT", sString);
    MELSE_SIN_SetBufferedString(nStrRef, sString);
}
