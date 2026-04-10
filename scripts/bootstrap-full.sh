#!/usr/bin/env bash
set -euo pipefail

# Полная локальная подготовка SmartMenu после чистого git clone корневого репозитория.
# Скрипт скачивает сервисы, ставит зависимости, генерирует Prisma Client,
# поднимает Postgres/Redis, синхронизирует схемы БД и собирает Docker-образы.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SERVICES=(
  "ai-orchestrator"
  "inventory-manager"
  "logistics-route-planner"
  "recipe-content-service"
  "retail-data-aggregator"
  "telegram-bot-gateway"
  "user-profile-service"
)

DB_SERVICES=(
  "ai-orchestrator:smartmenu_ai_orchestrator"
  "inventory-manager:smartmenu_inventory"
  "logistics-route-planner:smartmenu_logistics"
  "recipe-content-service:smartmenu_recipe"
  "retail-data-aggregator:smartmenu_retail"
  "user-profile-service:smartmenu_user_profile"
)

require_command() {
  local command_name="$1"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Не найдена команда: ${command_name}" >&2
    exit 1
  fi
}

wait_for_postgres() {
  echo "Жду готовности Postgres..."

  for _ in {1..60}; do
    if docker compose exec -T postgres pg_isready -U smartmenu -d smartmenu >/dev/null 2>&1; then
      echo "Postgres готов."
      return
    fi

    sleep 2
  done

  echo "Postgres не стал готовым за отведенное время." >&2
  exit 1
}

require_command git
require_command node
require_command npm
require_command docker

cd "$ROOT_DIR"

echo "Шаг 1/7: скачиваю и проверяю репозитории."
bash "${ROOT_DIR}/scripts/sync-repositories.sh"

echo "Шаг 2/7: устанавливаю зависимости корневого проекта."
npm install

echo "Шаг 3/7: устанавливаю зависимости сервисов."
for service in "${SERVICES[@]}"; do
  echo "npm install: ${service}"
  npm --prefix "${ROOT_DIR}/services/${service}" install
done

echo "Шаг 4/7: поднимаю Postgres и Redis."
docker compose up -d postgres redis
wait_for_postgres

echo "Шаг 5/7: генерирую Prisma Client и синхронизирую схемы БД."
for service_and_db in "${DB_SERVICES[@]}"; do
  service="${service_and_db%%:*}"
  database="${service_and_db##*:}"
  database_url="postgresql://smartmenu:smartmenu@localhost:5432/${database}"
  service_path="${ROOT_DIR}/services/${service}"

  echo "Prisma generate: ${service}"
  DATABASE_URL="$database_url" npm --prefix "$service_path" run db:generate

  echo "Prisma db push: ${service}"
  DATABASE_URL="$database_url" npm --prefix "$service_path" run db:push
done

echo "Шаг 6/7: собираю Docker-образы."
docker compose build

echo "Шаг 7/7: запускаю все контейнеры."
docker compose up -d

node "${ROOT_DIR}/scripts/check-structure.mjs"

echo "SmartMenu готов. Проверь сервисы на http://localhost:3001 ... http://localhost:3007."
