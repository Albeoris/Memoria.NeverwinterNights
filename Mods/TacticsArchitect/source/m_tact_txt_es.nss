void main()
{
    int i = StringToInt(GetScriptParam("M_TACT_TEXT_KEY"));
    if (i == 112) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Abrir editor de tacticas"); return; }
    if (i == 27) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Parametros de fuego amigo"); return; }
    if (i == 64) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Dificultad enemiga minima"); return; }
    if (i == 65) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Dificultad enemiga maxima"); return; }
    if (i == 66) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "PRIORIDADES DE OBJETIVO"); return; }
    if (i == 67) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Anadir prioridad"); return; }
    if (i == 68) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Editor de prioridad"); return; }
    if (i == 69) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Lanzadores de conjuros enemigos"); return; }
    if (i == 70) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Enemigos con dificultad maxima"); return; }
    if (i == 71) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Enemigos con dificultad minima"); return; }
    if (i == 72) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Enemigos con salud minima"); return; }
    if (i == 73) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Enemigos con salud maxima"); return; }
    if (i == 74) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Despues: los demas enemigos"); return; }
    if (i == 75) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Criterio"); return; }
    if (i == 76) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "REGLAS"); return; }
    if (i == 77) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Depuracion de decisiones"); return; }
    if (i == 78) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Examinar objetivo elegido"); return; }
    if (i == 79) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "[M_TACT] Selecciona una criatura para el diagnostico."); return; }
    if (i == 80) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "[M_TACT] Seleccion de diagnostico cancelada."); return; }
    if (i == 81) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "El area se determina automaticamente por el hechizo"); return; }
    if (i == 82) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Sin restricciones"); return; }
    if (i == 83) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Comprobar antes de lanzar"); return; }
    if (i == 84) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Comprobar durante el lanzamiento"); return; }
    if (i == 85) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Solo con aliados inmoviles"); return; }
    if (i == 86) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "ACCIONES"); return; }
    if (i == 88) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Prioridades globales"); return; }
    if (i == 89) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Prioridades de la regla"); return; }
    if (i == 90) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Editor de acciones"); return; }
    if (i == 91) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Anadir accion"); return; }
    if (i == 92) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Valoracion del enemigo"); return; }
    if (i == 93) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Comparacion"); return; }
    if (i == 94) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Como minimo"); return; }
    if (i == 95) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Como maximo"); return; }
    if (i == 96) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Salud inferior"); return; }
    if (i == 97) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Sujeto"); return; }
    if (i == 98) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Este personaje"); return; }
    if (i == 99) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Un aliado"); return; }
    if (i == 100) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Solo se aplican acciones de area hostiles; el mejor grupo se elige automaticamente."); return; }
    if (i == 101) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Segun prioridades de objetivo"); return; }
    if (i == 102) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "No hay acciones"); return; }
    if (i == 103) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Prioridades de la accion"); return; }
    if (i == 104) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Despues: globales y otros enemigos"); return; }
    if (i == 105) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Despues: regla, globales y otros enemigos"); return; }
    if (i == 106) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Se ignora a los aliados y el hechizo puede alcanzarlos."); return; }
    if (i == 107) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "El area se comprueba antes.\nEl lanzamiento no se cancela despues."); return; }
    if (i == 108) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "La seguridad se vuelve a comprobar.\nUn nuevo peligro cancela el lanzamiento."); return; }
    if (i == 109) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Se espera a que los aliados se detengan.\nDespues se comprueba el area."); return; }
    if (i == 110) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Equipar objeto"); return; }
    if (i == 111) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Objetos equipables"); return; }
    string s = i == 1 ? "Arquitecto tactico" : i == 2 ? "Abre el editor visual de tacticas. Configura acciones y condiciones prioritarias para el heroe, un companero concreto o un tipo de criatura." : i == 3 ? "Arquitecto tactico instalado, version" : i == 4 ? "Arquitecto tactico" : i == 5 ? "Personaje" : i == 6 ? "Alcance del perfil" : i == 7 ? "Este personaje" : i == 8 ? "Este tipo de criatura" : i == 9 ? "Tactica actual" : i == 10 ? "Nueva" : i == 11 ? "Eliminar" : i == 12 ? "Activada" : i == 13 ? "Nombre de la tactica" : i == 14 ? "Renombrar" : i == 15 ? "ACCION" : i == 16 ? "CUANDO" : i == 17 ? "Subir" : i == 18 ? "Bajar" : i == 19 ? "Editar" : i == 20 ? "Anadir regla" : i == 21 ? "Cerrar" : i == 22 ? "Editar regla" : i == 23 ? "Elegir accion" : i == 24 ? "Elegir condicion" : i == 25 ? "Avanzado" : i == 26 ? "Puede moverse al alcance" : i == 27 ? "Permitir fuego amigo" : i == 28 ? "Fuente" : i == 29 ? "Cualquier fuente disponible" : i == 30 ? "Espacio del libro de conjuros" : i == 31 ? "Tipo de objeto elegido" : i == 32 ? "Objetivo" : i == 33 ? "Automatico" : i == 34 ? "Uno mismo" : i == 35 ? "Enemigo apropiado mas cercano" : i == 36 ? "Aliado con menos salud" : i == 37 ? "Mejor grupo de enemigos" : i == 38 ? "Siempre" : i == 39 ? "Enemigos cercanos" : i == 40 ? "Enemigos agrupados" : i == 41 ? "Salud propia inferior" : i == 42 ? "Salud de aliado inferior" : i == 43 ? "Sin criatura invocada" : i == 44 ? "Sin familiar invocado" : i == 45 ? "Umbral" : i == 46 ? "Radio (metros)" : i == 47 ? "Guardar" : i == 48 ? "Cancelar" : i == 49 ? "Elegir conjuro u objeto" : i == 50 ? "Buscar" : i == 51 ? "Anterior" : i == 52 ? "Siguiente" : i == 53 ? "Elegir" : i == 54 ? "Invocar familiar" : i == 55 ? "Atacar al enemigo mas cercano" : i == 56 ? "Conjuro u objeto utilizable..." : i == 57 ? "Sin configurar" : i == 58 ? "Predeterminada" : i == 59 ? "Aun no hay reglas. Anade la primera prioridad." : i == 60 ? "Heroe principal" : i == 61 ? "Valor no valido." : i == 62 ? "Enemigo con menos salud" : i == 63 ? "Enemigo con mas salud" : "";
    SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", s);
}
