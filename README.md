# Сайт Adapto OS

Обычные HTML-файлы и один `assets/site.css`. Сборки нет, JavaScript нет. Отдаётся любым статическим сервером (nginx), корень — эта папка.

- Русский — в корне, казахский — в `kk/` с теми же именами файлов.
- Шапка и подвал повторяются в каждой странице: страниц мало, а генератор стоил бы дороже, чем поиск с заменой.
- Цвета и шрифт взяты из продукта: токены Espresso из `adapto-frappe/adapto/adapto/dash/styles/tokens/`, шрифт — `adapto/adapto/public/dash/fonts/`.
- Жёлтые пометки `class="todo"` — данные, которых ещё нет: БИН, адрес, контакты, цены, адрес демо. Перед выкладкой: `grep -rn 'class="todo"' .`
- Текст лицензии собран из `adapto-frappe/LICENSE.md` без раздела вопросов юристу.

Посмотреть локально: `python3 -m http.server -d . 8000`.

## Выкладка

Хостинг ps.kz (Plesk, сервер `srv-plesk63.ps.kz`), папка сайта — `httpdocs` подписки `adapto.kz`. Там же лежит `SakenGPT_bot` — его не трогать; в домашней папке подписки ещё `altyncore.kz`.

1. `git archive --format=zip -o adapto-site.zip HEAD -- '*.html' kk assets .htaccess`
2. Plesk → Файлы → `httpdocs` → «Добавить новый» → «Загрузить файл».
3. Архив → «Извлечь файлы» с «Заменить существующие файлы».
4. Удалить `adapto-site.zip` из `httpdocs`: иначе его можно скачать.
