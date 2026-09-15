void main()
{
    int i = StringToInt(GetScriptParam("METACT_TEXT_KEY"));
    if (i == 112) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Ouvrir l'editeur de tactiques"); return; }
    if (i == 27) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Parametres des degats allies"); return; }
    if (i == 64) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Difficulte ennemie au moins"); return; }
    if (i == 65) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Difficulte ennemie au plus"); return; }
    if (i == 66) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "PRIORITES DES CIBLES"); return; }
    if (i == 67) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Ajouter une priorite"); return; }
    if (i == 68) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Editeur de priorite"); return; }
    if (i == 69) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Lanceurs de sorts ennemis"); return; }
    if (i == 70) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Ennemis au niveau le plus eleve"); return; }
    if (i == 71) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Ennemis au niveau le plus faible"); return; }
    if (i == 72) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Ennemis avec le moins de vie"); return; }
    if (i == 73) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Ennemis avec le plus de vie"); return; }
    if (i == 74) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Puis : les autres ennemis"); return; }
    if (i == 75) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Critere"); return; }
    if (i == 76) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "REGLES"); return; }
    if (i == 77) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Debogage des decisions"); return; }
    if (i == 78) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Examiner la cible choisie"); return; }
    if (i == 79) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "[METACT] Selectionnez une creature pour le diagnostic."); return; }
    if (i == 80) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "[METACT] Selection de cible annulee."); return; }
    if (i == 81) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "La zone est determinee automatiquement par le sort"); return; }
    if (i == 82) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Sans restrictions"); return; }
    if (i == 83) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Verifier avant l'incantation"); return; }
    if (i == 84) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Verifier pendant l'incantation"); return; }
    if (i == 85) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Seulement si les allies sont immobiles"); return; }
    if (i == 86) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "ACTIONS"); return; }
    if (i == 88) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Priorites globales"); return; }
    if (i == 89) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Priorites de la regle"); return; }
    if (i == 90) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Editeur d'action"); return; }
    if (i == 91) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Ajouter une action"); return; }
    if (i == 92) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Puissance de l'ennemi"); return; }
    if (i == 93) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Comparaison"); return; }
    if (i == 94) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Au moins"); return; }
    if (i == 95) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Au plus"); return; }
    if (i == 96) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Points de vie inferieurs"); return; }
    if (i == 97) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Sujet"); return; }
    if (i == 98) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Ce personnage"); return; }
    if (i == 99) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Un allie"); return; }
    if (i == 100) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Seules les actions de zone hostiles s'appliquent; le meilleur groupe est choisi automatiquement."); return; }
    if (i == 101) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Selon les priorites de cible"); return; }
    if (i == 102) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Aucune action"); return; }
    if (i == 103) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Priorites de l'action"); return; }
    if (i == 104) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Puis : globales, autres ennemis"); return; }
    if (i == 105) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Puis : regle, globales, autres ennemis"); return; }
    if (i == 106) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Les allies sont ignores et peuvent etre touches."); return; }
    if (i == 107) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "La zone est verifiee avant.\nL'incantation n'est pas annulee ensuite."); return; }
    if (i == 108) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "La securite est reverifiee pendant.\nUn nouveau danger annule le sort."); return; }
    if (i == 109) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Le sort attend l'arret des allies.\nLa zone est ensuite verifiee."); return; }
    if (i == 110) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Equiper un objet"); return; }
    if (i == 111) { SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", "Objets equipables"); return; }
    string s = i == 1 ? "Architecte tactique" : i == 2 ? "Ouvre l'editeur visuel de tactiques. Configurez les actions et conditions prioritaires du heros, d'un compagnon precis ou d'un type de creature." : i == 3 ? "Architecte tactique installe, version" : i == 4 ? "Architecte tactique" : i == 5 ? "Personnage" : i == 6 ? "Portee du profil" : i == 7 ? "Ce personnage" : i == 8 ? "Ce type de creature" : i == 9 ? "Tactique actuelle" : i == 10 ? "Nouvelle" : i == 11 ? "Supprimer" : i == 12 ? "Activee" : i == 13 ? "Nom de la tactique" : i == 14 ? "Renommer" : i == 15 ? "ACTION" : i == 16 ? "QUAND" : i == 17 ? "Monter" : i == 18 ? "Descendre" : i == 19 ? "Modifier" : i == 20 ? "Ajouter une regle" : i == 21 ? "Fermer" : i == 22 ? "Modifier la regle" : i == 23 ? "Choisir l'action" : i == 24 ? "Choisir la condition" : i == 25 ? "Avance" : i == 26 ? "Peut se deplacer a portee" : i == 27 ? "Autoriser les degats allies" : i == 28 ? "Source" : i == 29 ? "Toute source disponible" : i == 30 ? "Emplacement du grimoire" : i == 31 ? "Type d'objet choisi" : i == 32 ? "Cible" : i == 33 ? "Automatique" : i == 34 ? "Soi-meme" : i == 35 ? "Ennemi approprie le plus proche" : i == 36 ? "Allie avec le moins de vie" : i == 37 ? "Meilleur groupe d'ennemis" : i == 38 ? "Toujours" : i == 39 ? "Ennemis proches" : i == 40 ? "Ennemis groupes" : i == 41 ? "Sante du personnage inferieure" : i == 42 ? "Sante d'un allie inferieure" : i == 43 ? "Aucune creature invoquee" : i == 44 ? "Aucun familier invoque" : i == 45 ? "Seuil" : i == 46 ? "Rayon (metres)" : i == 47 ? "Enregistrer" : i == 48 ? "Annuler" : i == 49 ? "Choisir un sort ou un objet" : i == 50 ? "Rechercher" : i == 51 ? "Precedent" : i == 52 ? "Suivant" : i == 53 ? "Choisir" : i == 54 ? "Invoquer le familier" : i == 55 ? "Attaquer l'ennemi le plus proche" : i == 56 ? "Sort ou objet utilisable..." : i == 57 ? "Non configure" : i == 58 ? "Par defaut" : i == 59 ? "Aucune regle. Ajoutez la premiere priorite." : i == 60 ? "Heros principal" : i == 61 ? "Valeur incorrecte." : i == 62 ? "Ennemi avec le moins de vie" : i == 63 ? "Ennemi avec le plus de vie" : "";
    SetLocalString(OBJECT_SELF, "METACT_TEXT_RESULT", s);
}
