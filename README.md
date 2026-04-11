# SmartMenu

SmartMenu — микросервисный каркас для ИИ-помощника по планированию питания, zero-waste меню, закупкам и маршрутам по магазинам.

## Сервисы

- `ai-orchestrator` — координация генерации меню, перепланирование, валидация бюджета и веса.
- `inventory-manager` — домашние остатки, сроки годности, списание после готовки.
- `retail-data-aggregator` — цены, скидки, пользовательский ввод цен, кэширование.
- `logistics-route-planner` — маршруты, ограничения по весу, магазины по пути.
- `recipe-content-service` — рецепты, фильтры по технике, заменители ингредиентов.
- `user-profile-service` — профиль, семья, ограничения, аллергии, расписание гостей.
- `telegram-bot-gateway` — внешний пользовательский шлюз для Telegram.

## Быстрый старт

После чистого скачивания корневого репозитория:

```bash
git clone https://github.com/AnorVen/SmartMenu.git
cd SmartMenu
bash scripts/bootstrap-full.sh
```

Этот скрипт:

- скачает все сервисные репозитории в `services/*`;
- установит зависимости корня и сервисов;
- поднимет Postgres и Redis;
- сгенерирует Prisma Client;
- применит Prisma-схемы через `db:push`;
- соберет Docker-образы;
- запустит все контейнеры;
- проверит структуру проекта.

То же самое через npm:

```bash
npm run setup:full
```

Если нужно только скачать или обновить сервисные репозитории и проверить структуру:

```bash
npm run setup:repos
```

или напрямую:

```bash
bash scripts/sync-repositories.sh
```

Ручной запуск Docker без bootstrap:

```bash
docker compose build
docker compose up
```

Для Windows нужен Git Bash, WSL или другая bash-совместимая оболочка.

## Prisma

В DB-сервисах используется Prisma. Пример команд для одного сервиса:

```bash
cd services/user-profile-service
npm run db:generate
npm run db:migrate
```

Для локального прототипирования можно использовать `npm run db:push`, но для командной разработки лучше фиксировать миграции через `db:migrate`.

Проверка структуры:

```bash
npm run check:structure
```

## Порты

- `3001` — AI Orchestrator
- `3002` — Inventory Manager
- `3003` — Retail Data Aggregator
- `3004` — Logistics Route Planner
- `3005` — Recipe Content Service
- `3006` — User Profile Service
- `3007` — Telegram Bot Gateway
- `5432` — Postgres
- `6379` — Redis

## Telegram Bot MVP

`telegram-bot-gateway` принимает `POST /telegram/webhook` и понимает команды:

- `/start`
- `/profile`
- `/generate`
- `/route`
- `/inventory`
- `/summary`
- `/help`

Также бот реагирует на обычные фразы:

- `купила молоко 1 л, курица 500 г`
- `цена молоко 70 руб, Магнит`
- `в пятницу придут двое гостей, ужин`
- `хочу борщ в четверг`
- `замени в среду курицу на тофу`
- `я приготовила ужин`
- `пропускаю ужин`
- `я в магазине Пятерочка`
- `предложи рецепт`

Можно отправить геолокацию для маршрута или фото чека как источник цен.

## Документация

- [Архитектура](docs/architecture.md)
- [Clean Architecture по сервисам](docs/clean-architecture.md)
- [Анализ языков для сервисов](docs/language-analysis.md)
- [Следующие шаги](docs/next-steps.md)
- [Git-репозитории](docs/repositories.md)
