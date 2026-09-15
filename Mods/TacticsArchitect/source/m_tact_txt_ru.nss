void main()
{
    int i = StringToInt(GetScriptParam("M_TACT_TEXT_KEY"));
    if (i == 27) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Параметры дружественного огня"); return; }
    if (i == 64) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Рейтинг врага не ниже"); return; }
    if (i == 65) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Рейтинг врага не выше"); return; }
    if (i == 66) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "ПРИОРИТЕТЫ ЦЕЛЕЙ"); return; }
    if (i == 67) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Добавить приоритет"); return; }
    if (i == 68) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Редактор приоритета"); return; }
    if (i == 69) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Враги-заклинатели"); return; }
    if (i == 70) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Враги с наивысшим рейтингом"); return; }
    if (i == 71) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Враги с наименьшим рейтингом"); return; }
    if (i == 72) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Враги с минимальным здоровьем"); return; }
    if (i == 73) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Враги с максимальным здоровьем"); return; }
    if (i == 74) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Далее: остальные враги"); return; }
    if (i == 75) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Критерий"); return; }
    if (i == 76) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "ПРАВИЛА"); return; }
    if (i == 77) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Отладка решений"); return; }
    if (i == 78) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Проверить выбранную цель"); return; }
    if (i == 79) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "[M_TACT] Выберите существо для диагностического отчёта."); return; }
    if (i == 80) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "[M_TACT] Выбор диагностической цели отменён."); return; }
    if (i == 81) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Область автоматически определяется заклинанием"); return; }
    if (i == 82) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Без ограничений"); return; }
    if (i == 83) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Проверка перед кастом"); return; }
    if (i == 84) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Проверка во время каста"); return; }
    if (i == 85) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Только при неподвижных союзниках"); return; }
    if (i == 86) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "ДЕЙСТВИЯ"); return; }
    if (i == 88) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Глобальные приоритеты"); return; }
    if (i == 89) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Приоритеты правила"); return; }
    if (i == 90) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Редактор действия"); return; }
    if (i == 91) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Добавить действие"); return; }
    if (i == 92) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Рейтинг противника"); return; }
    if (i == 93) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Сравнение"); return; }
    if (i == 94) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Не ниже"); return; }
    if (i == 95) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Не выше"); return; }
    if (i == 96) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Здоровье ниже"); return; }
    if (i == 97) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Чьё здоровье"); return; }
    if (i == 98) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Этого персонажа"); return; }
    if (i == 99) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Союзника"); return; }
    if (i == 100) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Подходят только враждебные площадные действия; лучшее скопление выбирается автоматически."); return; }
    if (i == 101) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Согласно приоритетам целей"); return; }
    if (i == 102) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Действий пока нет"); return; }
    if (i == 103) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Приоритеты действия"); return; }
    if (i == 104) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Далее: глобальные, затем остальные враги"); return; }
    if (i == 105) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Далее: правило, глобальные, остальные враги"); return; }
    if (i == 106) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Союзники не учитываются; заклинание может их задеть."); return; }
    if (i == 107) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Область проверяется перед кастом.\nНачатый каст не отменяется."); return; }
    if (i == 108) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Проверка повторяется во время каста.\nПри новой угрозе каст отменяется."); return; }
    if (i == 109) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Каст начинается после остановки союзников.\nОбласть проверяется перед кастом."); return; }
    if (i == 110) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Экипировать предмет"); return; }
    if (i == 111) { SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", "Экипируемые предметы"); return; }
    string s = i == 1 ? "Архитектор тактик" : i == 2 ? "Открывает визуальный редактор тактик. Настройте приоритетные действия и условия для героя, конкретного спутника или вида существ." : i == 3 ? "Архитектор тактик установлен, версия" : i == 4 ? "Архитектор тактик" : i == 5 ? "Персонаж" : i == 6 ? "Область профиля" : i == 7 ? "Этот персонаж" : i == 8 ? "Этот вид существ" : i == 9 ? "Текущая тактика" : i == 10 ? "Новая" : i == 11 ? "Удалить" : i == 12 ? "Включена" : i == 13 ? "Название тактики" : i == 14 ? "Переименовать" : i == 15 ? "ДЕЙСТВИЕ" : i == 16 ? "КОГДА" : i == 17 ? "Выше" : i == 18 ? "Ниже" : i == 19 ? "Изменить" : i == 20 ? "Добавить правило" : i == 21 ? "Закрыть" : i == 22 ? "Редактор правила" : i == 23 ? "Выбрать действие" : i == 24 ? "Выбрать условие" : i == 25 ? "Расширенные" : i == 26 ? "Можно подойти на дистанцию" : i == 27 ? "Разрешить дружественный огонь" : i == 28 ? "Источник" : i == 29 ? "Любой доступный источник" : i == 30 ? "Ячейка книги заклинаний" : i == 31 ? "Выбранный вид предмета" : i == 32 ? "Цель" : i == 33 ? "Автоматически" : i == 34 ? "На себя" : i == 35 ? "Ближайший подходящий враг" : i == 36 ? "Союзник с минимумом здоровья" : i == 37 ? "Лучшее скопление врагов" : i == 38 ? "Всегда" : i == 39 ? "Враги рядом" : i == 40 ? "Враги стоят вместе" : i == 41 ? "Здоровье персонажа ниже" : i == 42 ? "Здоровье союзника ниже" : i == 43 ? "Нет призванного существа" : i == 44 ? "Нет призванного фамильяра" : i == 45 ? "Порог" : i == 46 ? "Радиус (метры)" : i == 47 ? "Сохранить" : i == 48 ? "Отмена" : i == 49 ? "Выбор заклинания или предмета" : i == 50 ? "Поиск" : i == 51 ? "Назад" : i == 52 ? "Вперёд" : i == 53 ? "Выбрать" : i == 54 ? "Призвать фамильяра" : i == 55 ? "Атаковать ближайшего врага" : i == 56 ? "Заклинание или используемый предмет..." : i == 57 ? "Не настроено" : i == 58 ? "По умолчанию" : i == 59 ? "Правил пока нет. Добавьте первый приоритет." : i == 60 ? "Главный герой" : i == 61 ? "Некорректное значение." : i == 62 ? "Враг с минимальным здоровьем" : i == 63 ? "Враг с максимальным здоровьем" : "";
    SetLocalString(OBJECT_SELF, "M_TACT_TEXT_RESULT", s);
}
