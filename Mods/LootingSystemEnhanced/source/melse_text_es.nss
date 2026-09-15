// Original work Copyright (c) 2020 Mischa Dutzik (Ravick).
// Relicensed under the MIT License by Albeoris. See THIRD_PARTY_NOTICES.md.

#include "melse_sin_lib"

void main()
{
    int nStrRef = StringToInt(GetScriptParam(MELSE_SIN_PARAM_STRREF));
    
    string sString = nStrRef == 1   ? "Debería estar atento a los tesoros en esta zona." 
                   : nStrRef == 2   ? "Esta zona parece estar libre de tesoros." 
                   : nStrRef == 5   ? "¡soltó un objeto de misión!"
                   : nStrRef == 7   ? "¡soltó un objeto equipado!" 
                   : nStrRef == 8   ? "Adquirido por última vez por " 
                   : nStrRef == 9   ? "en la zona " 
                   : nStrRef == 10  ? "Objeto (sin identificar)"
                   : nStrRef == 11  ? "se ignora."

                   : nStrRef == 99   ? "Looting System Enhanced"
                   : nStrRef == 100  ? "Volver..."
                   : nStrRef == 101  ? "Detección de tesoros"
                   : nStrRef == 102  ? "Seguimiento de tesoros"
                   : nStrRef == 103  ? "Saqueo automático de tesoros"
                   : nStrRef == 104  ? "Cadáveres saqueables"
                   : nStrRef == 105  ? "Los cadáveres saqueables desaparecen tras ser saqueados"
                   : nStrRef == 106  ? "Los cadáveres saqueables desaparecen con el tiempo"
                   : nStrRef == 107  ? "Los cadáveres saqueables se pueden resucitar"
                   : nStrRef == 108  ? "Saqueo automático de cadáveres tras examinarlos"
                   : nStrRef == 109  ? "Saqueo automático de cadáveres tras matarlos"
                   : nStrRef == 110  ? "Saqueo automático de cadáveres tras ser matados por un compañero"
                   : nStrRef == 111  ? "La descripción del objeto muestra quién lo adquirió por última vez"
                   : nStrRef == 112  ? "La descripción del objeto muestra el precio base"

                   : nStrRef == 120  ? "Volver..."
                   : nStrRef == 121  ? "Tiempo de desaparición de cadáveres saqueables en segundos"
                   : nStrRef == 122  ? "Precio base mínimo para el saqueo automático"
                   : nStrRef == 123  ? "Peso base máximo para el saqueo automático"

                   : nStrRef == 900  ? "Cerrar."
                   : nStrRef == 901  ? "Características..."
                   : nStrRef == 902  ? "Parámetros..."
                   : nStrRef == 911  ? "+ 1"
                   : nStrRef == 912  ? "+ 10"
                   : nStrRef == 913  ? "+ 100"
                   : nStrRef == 914  ? "- 1"
                   : nStrRef == 915  ? "- 10"
                   : nStrRef == 916  ? "- 100"

                   : nStrRef == 951  ? "¡Destruir el cadáver seleccionado!"
                   : nStrRef == 952  ? "¡Destruir todos los cadáveres del área actual!"
                   : nStrRef == 953  ? "¡Destruir todos los cadáveres del módulo actual!"

                   : nStrRef == 501  ? "Ravick's Looting System Enhanced: versión instalada"
                   : nStrRef == 502  ? "Ravick's Looting System Enhanced: actualizado a la versión"

                   : nStrRef == 601  ? "¡Explícame cómo usar MELSE!"
                   : nStrRef == 602  ? "Todas las funciones de MELSE se instalaron automáticamente. No es necesario hacer nada más, salvo que quieras activar o personalizar algunas funciones, lo cual se explica en este tutorial."
                   : nStrRef == 603  ? "Para interactuar con MELSE, busca y usa la \"Herramienta de Jugador 9\" en \"Habilidades especiales\" en tu menú de clic derecho. A continuación deberás elegir un objetivo, que determina el tipo de interacción. ¡No selecciones nada ahora mismo, ya que eso cerraría el tutorial!"
                   : nStrRef == 604  ? "¿Qué ocurre si selecciono a mi personaje?"
                   : nStrRef == 605  ? "¿Qué ocurre si selecciono un cadáver?"
                   : nStrRef == 606  ? "Ya sé cómo usar MELSE. Cerrar el tutorial."
                   : nStrRef == 607  ? "Al seleccionar a tu personaje se abrirá el panel de configuración. Aquí podrás activar funciones individuales o cambiar parámetros específicos."
                   : nStrRef == 608  ? "Al seleccionar el cadáver de un enemigo se abrirá el panel de herramientas. Por ahora, las opciones disponibles se limitan a la solución de problemas, como destruir cadáveres restantes para corregir posibles errores de ciertos scripts del módulo que dependen de la existencia de criaturas (vivas o muertas)."

                   :                STRING_EMPTY;

    SetLocalString(OBJECT_SELF, "MELSE_CONFIG_TEXT_RESULT", sString);
    MELSE_SIN_SetBufferedString(nStrRef, sString);
}
