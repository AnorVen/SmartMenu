import { existsSync } from "node:fs";

const requiredPaths = [
  "docker-compose.yml",
  "infrastructure/postgres/init/01-create-databases.sql",
  "scripts/sync-repositories.sh",
  "scripts/bootstrap-full.sh",
  "services/ai-orchestrator/Dockerfile",
  "services/ai-orchestrator/prisma/schema.prisma",
  "services/inventory-manager/Dockerfile",
  "services/inventory-manager/prisma/schema.prisma",
  "services/retail-data-aggregator/Dockerfile",
  "services/retail-data-aggregator/prisma/schema.prisma",
  "services/logistics-route-planner/Dockerfile",
  "services/logistics-route-planner/prisma/schema.prisma",
  "services/recipe-content-service/Dockerfile",
  "services/recipe-content-service/prisma/schema.prisma",
  "services/user-profile-service/Dockerfile",
  "services/user-profile-service/prisma/schema.prisma",
  "services/telegram-bot-gateway/Dockerfile",
  "docs/architecture.md",
  "docs/language-analysis.md",
  "docs/next-steps.md",
  "docs/repositories.md"
];

const missingPaths = requiredPaths.filter((path) => !existsSync(path));

if (missingPaths.length > 0) {
  console.error("Не найдены обязательные файлы:");
  for (const path of missingPaths) {
    console.error(`- ${path}`);
  }
  process.exit(1);
}

console.log("Структура SmartMenu готова.");
