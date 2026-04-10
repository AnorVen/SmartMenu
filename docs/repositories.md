# Git-репозитории

Проект разделен на несколько независимых Git-репозиториев.

## Корневой репозиторий

Путь:

```text
D:\other\SmartMenu
```

Remote:

```text
https://github.com/AnorVen/SmartMenu.git
```

Назначение:

- документация;
- Docker Compose;
- инфраструктурные файлы;
- скрипты;
- общие markdown-описания продукта.

Корневой репозиторий не трекает код сервисов. Для этого в корневом `.gitignore` добавлено:

```gitignore
services/*
```

## Репозитории сервисов

Каждый сервис внутри `services` является отдельным Git-репозиторием:

| Локальный путь | GitHub remote |
|---|---|
| `services/ai-orchestrator` | `https://github.com/AnorVen/SmartMenu-ai-orchestrator.git` |
| `services/inventory-manager` | `https://github.com/AnorVen/SmartMenu-inventory-manager.git` |
| `services/logistics-route-planner` | `https://github.com/AnorVen/SmartMenu-logistics-route-planner.git` |
| `services/recipe-content-service` | `https://github.com/AnorVen/SmartMenu-recipe-content-service.git` |
| `services/retail-data-aggregator` | `https://github.com/AnorVen/SmartMenu-retail-data-aggregator.git` |
| `services/telegram-bot-gateway` | `https://github.com/AnorVen/SmartMenu-telegram-bot-gateway.git` |
| `services/user-profile-service` | `https://github.com/AnorVen/SmartMenu-user-profile-service.git` |

## Проверка статусов

Корневой репозиторий:

```bash
git status
```

Все сервисы:

```powershell
$serviceDirs = Get-ChildItem services -Directory
foreach ($dir in $serviceDirs) {
  Write-Output "[$($dir.Name)]"
  git -C $dir.FullName status --short
}
```

## Скачивание всех репозиториев

После клонирования корневого репозитория можно скачать или обновить все сервисы одной командой:

```bash
npm run setup:repos
```

или напрямую:

```bash
bash scripts/sync-repositories.sh
```

Скрипт использует такие remote-адреса:

- root: `https://github.com/AnorVen/SmartMenu.git`
- services: `https://github.com/AnorVen/SmartMenu-<service-name>.git`

## Полная локальная сборка

Для полной подготовки окружения:

```bash
bash scripts/bootstrap-full.sh
```

Скрипт скачивает сервисы, ставит npm-зависимости, запускает Postgres/Redis, генерирует Prisma Client, применяет Prisma-схемы через `db:push`, собирает Docker-образы и запускает контейнеры.

## Коммиты

Коммиты нужно делать отдельно:

1. В корне — изменения документации, `docker-compose.yml`, инфраструктуры и скриптов.
2. В конкретном сервисе — изменения только этого сервиса.

Пример:

```bash
cd services/user-profile-service
git add .
git commit -m "Implement user profile API"
```
