#!/usr/bin/env bash
set -euo pipefail

# Скрипт скачивает или обновляет все сервисные репозитории SmartMenu.
# Корневой репозиторий хранит документацию, инфраструктуру и скрипты,
# а код сервисов живет в отдельных Git-репозиториях внутри services/*.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASE_URL="https://github.com/AnorVen"
ROOT_REMOTE="${BASE_URL}/SmartMenu.git"

SERVICES=(
  "ai-orchestrator"
  "inventory-manager"
  "logistics-route-planner"
  "recipe-content-service"
  "retail-data-aggregator"
  "telegram-bot-gateway"
  "user-profile-service"
)

require_command() {
  local command_name="$1"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Не найдена команда: ${command_name}" >&2
    exit 1
  fi
}

sync_repo() {
  local repo_path="$1"
  local repo_url="$2"
  local repo_name="$3"

  if [ -d "${repo_path}/.git" ]; then
    echo "Обновляю remote для ${repo_name}: ${repo_url}"
    git -C "$repo_path" remote remove origin >/dev/null 2>&1 || true
    git -C "$repo_path" remote add origin "$repo_url"

    if [ -z "$(git -C "$repo_path" status --porcelain)" ]; then
      echo "Рабочее дерево ${repo_name} чистое, пробую fast-forward pull."
      git -C "$repo_path" pull --ff-only origin main || echo "Не удалось выполнить pull для ${repo_name}. Возможно, удаленный репозиторий еще пустой."
    else
      echo "В ${repo_name} есть локальные изменения, pull пропущен."
    fi

    return
  fi

  if [ -e "$repo_path" ]; then
    echo "Путь ${repo_path} уже существует, но это не Git-репозиторий. Разберите папку вручную." >&2
    exit 1
  fi

  echo "Клонирую ${repo_name}: ${repo_url}"
  git clone "$repo_url" "$repo_path"
}

require_command git
require_command node

cd "$ROOT_DIR"

echo "Настраиваю root origin: ${ROOT_REMOTE}"
git remote remove origin >/dev/null 2>&1 || true
git remote add origin "$ROOT_REMOTE"

mkdir -p "${ROOT_DIR}/services"

for service in "${SERVICES[@]}"; do
  sync_repo "${ROOT_DIR}/services/${service}" "${BASE_URL}/SmartMenu-${service}.git" "SmartMenu-${service}"
done

node "${ROOT_DIR}/scripts/check-structure.mjs"

echo "Все репозитории SmartMenu синхронизированы."
