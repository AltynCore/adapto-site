# Сайт Adapto OS

Обычные HTML-файлы и один `assets/site.css`. Сборки нет, JavaScript нет. Отдаётся любым статическим сервером (nginx), корень — эта папка.

- Русский — в корне, казахский — в `kk/` с теми же именами файлов.
- Шапка и подвал повторяются в каждой странице: страниц мало, а генератор стоил бы дороже, чем поиск с заменой.
- Цвета и шрифт взяты из продукта: токены Espresso из `adapto-frappe/adapto/adapto/dash/styles/tokens/`, шрифт — `adapto/adapto/public/dash/fonts/`.
- Жёлтые пометки `class="todo"` — данные, которых ещё нет: БИН, адрес, контакты, цены, адрес демо. Перед выкладкой: `grep -rn 'class="todo"' .`
- Текст лицензии собран из `adapto-frappe/LICENSE.md` без раздела вопросов юристу.

Посмотреть локально: `python3 -m http.server -d . 8000`.

## Выкладка

```
bin/deploy
```

Скрипт берёт закоммиченный HEAD, заливает файлы сайта по FTPS в `httpdocs` на `srv-plesk63.ps.kz` и проверяет живые страницы. Пароль FTP — в связке ключей macOS, один раз: `security add-generic-password -s adapto-site-ftp -a adaptokz -w`. На сервере ничего не удаляется: в `httpdocs` ещё живёт `SakenGPT_bot`, а в домашней папке подписки — `altyncore.kz`.

## Установка одной командой

`install.sh` — установщик Adapto OS, сайт отдаёт его как `https://adapto.kz/install.sh`. Сборки лежат в релизах [AltynCore/adapto-os](https://github.com/AltynCore/adapto-os/releases), их публикует `deploy/release.sh` из `adapto-frappe`. Скрипт качает их через `adapto.kz/download/<метка>/…`: `.htaccess` отвечает редиректом 302 на GitHub, а метка из письма (`ADAPTO_KEY`) остаётся в журнале доступа — так видно, кто скачал.
