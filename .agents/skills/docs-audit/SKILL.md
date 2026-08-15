---
name: docs-audit
description: Используй перед handoff/release или после крупных изменений для read-only аудита документации. Проверяет актуальность README, source of truth, ссылки, команды запуска, решения, CURRENT_STATE и возможность продолжить работу без старого чата.
---

# Documentation Audit

## Процесс

1. Прочитай `docs/INDEX.md` и канонические документы.
2. Сверь документацию с фактическим кодом и конфигурацией.
3. Проверь:
   - README и setup-команды;
   - рабочие ссылки;
   - API/data contracts;
   - `CURRENT_STATE.md`;
   - `DECISION_LOG.md`/ADR;
   - статусы `SUPERSEDED`;
   - отсутствие конфликтующих источников правды;
   - отсутствие секретов/PII;
   - понятность следующего шага.
4. Выполни documentation smoke test: новый участник должен суметь понять продукт, запустить проект, найти основной flow, решения и текущую задачу.
5. Не исправляй документы в этом проходе. Для исправлений передай findings в `docs-sync`/`docs_keeper`.

## Результат

```markdown
## Sources audited
## Broken or stale documentation
## Conflicting truths
## Missing decisions/context
## Smoke-test result
## P0-P3 findings
## Recommended docs-sync scope
## Verdict
```

## Готово, когда

Понятно, можно ли доверять документации как источнику правды и что конкретно мешает handoff.
