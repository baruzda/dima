---
name: release-audit
description: Используй перед production release или важным merge для независимого read-only финального аудита. Собирает evidence из product, UX/UI, tests, E2E, security, performance и docs и выдаёт release verdict без деплоя.
---

# Release Audit

## Ограничение

Этот навык никогда не деплоит, не мержит и не меняет внешние системы.

## Процесс

1. Зафиксируй release scope и commit/ref.
2. Прочитай acceptance criteria и release checklist.
3. Собери evidence по релевантным областям:
   - product scope;
   - UX/UI;
   - static checks/tests/build;
   - E2E/regression;
   - accessibility;
   - security/privacy;
   - performance;
   - migrations/rollback;
   - monitoring;
   - documentation/handoff.
4. Не повторяй глубокий аудит без причины: используй существующие результаты, но проверяй их актуальность для текущего ref.
5. Любой отсутствующий критический evidence помечай как `Not verified`, а не как успех.
6. Приоритизируй findings P0-P3.
7. Выдай один verdict:
   - `APPROVE`;
   - `APPROVE WITH KNOWN RISKS`;
   - `REQUEST CHANGES`;
   - `BLOCK`.
8. Для known risks укажи владельца, влияние и mitigation/rollback.

## Результат

```markdown
## Release scope/ref
## Evidence matrix
## Blocking findings
## Known risks
## Not verified
## Rollback readiness
## Verdict
```

## Готово, когда

У release owner есть проверяемая картина качества и однозначная рекомендация без скрытых непроверенных областей.
