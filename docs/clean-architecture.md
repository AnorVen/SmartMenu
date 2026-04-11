# Clean Architecture в SmartMenu

Сервисы SmartMenu приведены к единой структуре слоев, чтобы код было легче развивать по мере роста доменной логики.

## Базовые блоки

Каждый сервис теперь стремится к такой раскладке:

```text
src/
  domain/           # Чистые доменные правила, типы, маппинг, парсинг, вычисления
  application/      # Сценарии использования и orchestration доменных операций
  infrastructure/   # Prisma, HTTP-клиенты, seed-данные, внешние интеграции
  presentation/     # HTTP-схемы, transport-слой, адаптеры входящих запросов
  index.ts          # Composition root и запуск процесса
```

## Как это применено сейчас

### ai-orchestrator

- `domain/`
  - [types.ts](/d:/other/SmartMenu/services/ai-orchestrator/src/domain/types.ts)
  - [utils.ts](/d:/other/SmartMenu/services/ai-orchestrator/src/domain/utils.ts)
  - [menu-planner.ts](/d:/other/SmartMenu/services/ai-orchestrator/src/domain/services/menu-planner.ts)
- `infrastructure/`
  - [prisma.ts](/d:/other/SmartMenu/services/ai-orchestrator/src/infrastructure/persistence/prisma.ts)
  - [service-clients.ts](/d:/other/SmartMenu/services/ai-orchestrator/src/infrastructure/clients/service-clients.ts)
- `index.ts`
  - [index.ts](/d:/other/SmartMenu/services/ai-orchestrator/src/index.ts)

### inventory-manager

- `domain/`
  - [inventory.ts](/d:/other/SmartMenu/services/inventory-manager/src/domain/inventory.ts)
- `presentation/`
  - [schemas.ts](/d:/other/SmartMenu/services/inventory-manager/src/presentation/http/schemas.ts)
- `infrastructure/`
  - [prisma.ts](/d:/other/SmartMenu/services/inventory-manager/src/infrastructure/persistence/prisma.ts)
- `index.ts`
  - [index.ts](/d:/other/SmartMenu/services/inventory-manager/src/index.ts)

### recipe-content-service

- `application/`
  - [recipe-service.ts](/d:/other/SmartMenu/services/recipe-content-service/src/application/recipe-service.ts)
- `presentation/`
  - [schemas.ts](/d:/other/SmartMenu/services/recipe-content-service/src/presentation/http/schemas.ts)
- `infrastructure/`
  - [prisma.ts](/d:/other/SmartMenu/services/recipe-content-service/src/infrastructure/persistence/prisma.ts)
  - [seed-data.ts](/d:/other/SmartMenu/services/recipe-content-service/src/infrastructure/seed/seed-data.ts)
- `index.ts`
  - [index.ts](/d:/other/SmartMenu/services/recipe-content-service/src/index.ts)

### telegram-bot-gateway

- `domain/`
  - [types.ts](/d:/other/SmartMenu/services/telegram-bot-gateway/src/domain/types.ts)
- `application/`
  - [dialog-state.ts](/d:/other/SmartMenu/services/telegram-bot-gateway/src/application/dialog-state.ts)
  - [bot-actions.ts](/d:/other/SmartMenu/services/telegram-bot-gateway/src/application/bot-actions.ts)
- `infrastructure/`
  - [service-client.ts](/d:/other/SmartMenu/services/telegram-bot-gateway/src/infrastructure/clients/service-client.ts)
- `index.ts`
  - [index.ts](/d:/other/SmartMenu/services/telegram-bot-gateway/src/index.ts)

### user-profile-service

- `domain/`
  - [profile-helpers.ts](/d:/other/SmartMenu/services/user-profile-service/src/domain/profile-helpers.ts)
- `presentation/`
  - [schemas.ts](/d:/other/SmartMenu/services/user-profile-service/src/presentation/http/schemas.ts)
- `infrastructure/`
  - [prisma.ts](/d:/other/SmartMenu/services/user-profile-service/src/infrastructure/persistence/prisma.ts)
  - [profile-store.ts](/d:/other/SmartMenu/services/user-profile-service/src/infrastructure/persistence/profile-store.ts)
- `index.ts`
  - [index.ts](/d:/other/SmartMenu/services/user-profile-service/src/index.ts)

### logistics-route-planner и retail-data-aggregator

Пока это тонкие сервисы-заглушки, поэтому у них уже выделен инфраструктурный слой Prisma, а дальнейшая логика будет раскладываться по тем же блокам по мере реализации use case-ов.

## Правило зависимостей

Желаемое направление зависимостей:

```text
presentation -> application -> domain
infrastructure -> application -> domain
```

`domain` не должен знать про Prisma, Fastify или HTTP.
