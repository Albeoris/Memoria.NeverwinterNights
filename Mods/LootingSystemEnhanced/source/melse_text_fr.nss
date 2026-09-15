// Original work Copyright (c) 2020 Mischa Dutzik (Ravick).
// Relicensed under the MIT License by Albeoris. See THIRD_PARTY_NOTICES.md.

#include "melse_sin_lib"

void main()
{
    int nStrRef = StringToInt(GetScriptParam(MELSE_SIN_PARAM_STRREF));
    
    string sString = nStrRef == 1   ? "Je devrais surveiller les trésors dans cette zone." 
                   : nStrRef == 2   ? "Cette zone semble dépourvue de trésors." 
                   : nStrRef == 5   ? "a laissé tomber un objet de quête !"
                   : nStrRef == 7   ? "a laissé tomber un objet équipé !" 
                   : nStrRef == 8   ? "Dernière acquisition par " 
                   : nStrRef == 9   ? "dans la zone " 
                   : nStrRef == 10  ? "Objet (non identifié)"
                   : nStrRef == 11  ? "est ignoré."

                   : nStrRef == 99   ? "Looting System Enhanced"
                   : nStrRef == 100  ? "Retour..."
                   : nStrRef == 101  ? "Détection des trésors"
                   : nStrRef == 102  ? "Suivi des trésors"
                   : nStrRef == 103  ? "Pillage automatique des trésors"
                   : nStrRef == 104  ? "Cadavres pillables"
                   : nStrRef == 105  ? "Les cadavres pillables se décomposent après avoir été pillés"
                   : nStrRef == 106  ? "Les cadavres pillables se décomposent avec le temps"
                   : nStrRef == 107  ? "Les cadavres pillables peuvent être ressuscités"
                   : nStrRef == 108  ? "Pillage automatique des cadavres après examen"
                   : nStrRef == 109  ? "Pillage automatique des cadavres après leur mort"
                   : nStrRef == 110  ? "Pillage automatique des cadavres tués par un compagnon"
                   : nStrRef == 111  ? "La description de l'objet indique qui l'a acquis en dernier"
                   : nStrRef == 112  ? "La description de l'objet indique le prix de base"

                   : nStrRef == 120  ? "Retour..."
                   : nStrRef == 121  ? "Délai de décomposition des cadavres pillables (en secondes)"
                   : nStrRef == 122  ? "Prix de base minimum pour le pillage automatique"
                   : nStrRef == 123  ? "Poids de base maximum pour le pillage automatique"

                   : nStrRef == 900  ? "Fermer."
                   : nStrRef == 901  ? "Fonctionnalités..."
                   : nStrRef == 902  ? "Paramètres..."
                   : nStrRef == 911  ? "+ 1"
                   : nStrRef == 912  ? "+ 10"
                   : nStrRef == 913  ? "+ 100"
                   : nStrRef == 914  ? "- 1"
                   : nStrRef == 915  ? "- 10"
                   : nStrRef == 916  ? "- 100"

                   : nStrRef == 951  ? "Détruire le cadavre sélectionné !"
                   : nStrRef == 952  ? "Détruire tous les cadavres de la zone actuelle !"
                   : nStrRef == 953  ? "Détruire tous les cadavres du module actuel !"

                   : nStrRef == 501  ? "Ravick's Looting System Enhanced : version installée"
                   : nStrRef == 502  ? "Ravick's Looting System Enhanced : mis à jour vers la version"

                   : nStrRef == 601  ? "Explique-moi comment utiliser MELSE !"
                   : nStrRef == 602  ? "Toutes les fonctionnalités de MELSE ont été installées automatiquement. Aucune action supplémentaire n'est nécessaire, sauf si vous souhaitez activer ou personnaliser certaines fonctionnalités, ce que ce tutoriel explique."
                   : nStrRef == 603  ? "Pour interagir avec MELSE, trouvez et utilisez l'« Outil du joueur 9 » sous « Capacités spéciales » dans votre menu clic droit. Vous devrez alors choisir une cible, ce qui détermine le type d'interaction. Ne sélectionnez rien pour l'instant, cela fermerait le tutoriel !"
                   : nStrRef == 604  ? "Que se passe-t-il si je sélectionne mon personnage ?"
                   : nStrRef == 605  ? "Que se passe-t-il si je sélectionne un cadavre ?"
                   : nStrRef == 606  ? "Je sais maintenant utiliser MELSE. Fermer le tutoriel."
                   : nStrRef == 607  ? "En sélectionnant votre personnage, le panneau de configuration s'ouvrira. Vous pourrez y activer certaines fonctionnalités ou modifier des paramètres spécifiques."
                   : nStrRef == 608  ? "En sélectionnant le cadavre d'un ennemi, le panneau d'outils s'ouvrira. Actuellement, les options disponibles se limitent au dépannage, comme la destruction des cadavres restants pour corriger d'éventuels bugs liés à certains scripts du module qui dépendent de l'existence de créatures (mortes ou vivantes)."

                   :                STRING_EMPTY;

    SetLocalString(OBJECT_SELF, "MELSE_CONFIG_TEXT_RESULT", sString);
    MELSE_SIN_SetBufferedString(nStrRef, sString);
}
