# Рецепты рабочих процессов

> Status: APPROVED  
> Authority: CANONICAL  
> Last reviewed: 2026-08-16

Этот документ отвечает на практический вопрос: **какие skills, agents и проверки запускать для конкретного типа задачи**.

Не нужно каждый раз изобретать процесс заново. Выбери ближайший рецепт, сократи лишние шаги для маленькой задачи и добавь обязательные проверки для рискованной.

## Базовая формула

```text
UNDERSTAND
→ PLAN
→ BUILD
→ VERIFY
→ REVIEW
→ FIX
→ RE-VERIFY
→ DOCS
→ HANDOFF
```

## 1. Новый продукт или приложение

Подходит для пустого репозитория, новой идеи или проекта без актуального source of truth.

```text
$project-kickoff
→ product_strategist
→ $product-discovery
→ $ux-flow
→ ux_architect
→ $ui-spec, если нужен интерфейс
→ $implementation-plan
→ code_mapper
→ $build-feature
→ implementation_worker
→ $quality-review
→ $e2e-review
→ $visual-qa / $ux-audit, если есть UI
→ $docs-audit
→ $docs-sync
```

### Минимальный результат

- PROJECT_BRIEF;
- CURRENT_STATE;
- DECISION_LOG;
- TASKS;
- один завершённый vertical slice;
- acceptance criteria;
- проверенный основной сценарий;
- handoff.

### Не делать

- не строить сразу всю архитектуру;
- не создавать десятки экранов до проверки основного flow;
- не добавлять инфраструктуру «на будущее» без требования.

## 2. Новая продуктовая функция

```text
$product-discovery
→ product_strategist, если ценность или scope неочевидны
→ $ux-flow
→ $ui-spec, если меняется UI
→ $implementation-plan
→ $build-feature
→ $quality-review
→ $e2e-review для критического flow
→ $visual-qa / $ux-audit при UI-изменениях
→ $docs-audit
→ $docs-sync
```

### Shortcut для маленькой понятной функции

```text
TASK + acceptance criteria
→ $implementation-plan
→ $build-feature
→ targeted tests
→ $quality-review
→ docs sync
```

## 3. UI-фича или новый экран

```text
$ux-flow
→ ux_architect
→ $ui-spec
→ Figma / Product Design при необходимости
→ $implementation-plan
→ $build-feature
→ $visual-qa
→ visual_qa_reviewer
→ $e2e-review
→ $ux-audit
→ accessibility smoke
→ $docs-sync
```

### Обязательно проверить

- default/loading/empty/error/success;
- hover/focus/disabled/selected;
- mobile и desktop;
- длинные тексты;
- переполнение;
- keyboard focus;
- contrast и touch targets;
- критический пользовательский сценарий.

## 4. Редизайн существующего интерфейса

Не начинать с визуальной полировки.

```text
$ux-audit текущего решения
→ ux_architect
→ product_strategist, если меняется поведение
→ зафиксировать проблемы и метрики
→ Product Design / Figma: направления
→ выбрать одно направление
→ $ui-spec
→ $implementation-plan
→ $build-feature по вертикальным срезам
→ $visual-qa
→ $e2e-review
→ $ux-audit новой версии
→ $docs-sync
```

### Правило

Каждое заметное визуальное изменение должно быть связано хотя бы с одним из:

- иерархия;
- читаемость;
- скорость выполнения задачи;
- состояние;
- доступность;
- консистентность дизайн-системы.

## 5. Есть чужое приложение или сайт, хочется сделать похожее

```text
исследовать источник как reference
→ product_strategist: отделить ценность от копирования
→ $ux-audit reference flow
→ определить что сохраняем / меняем / не копируем
→ $product-discovery для собственного продукта
→ $ux-flow
→ Product Design / Figma для нового направления
→ $ui-spec
→ $implementation-plan
→ $build-feature
→ verification stack
```

### Не переносить слепо

- бренд;
- тексты;
- уникальные ассеты;
- proprietary content;
- ошибки чужого UX;
- техническую архитектуру, которую мы не проверяли.

## 6. Баг

```text
$bug-triage
→ qa_reviewer
→ code_mapper, если причина не локальна
→ доказать root cause
→ implementation_worker / $build-feature
→ regression test
→ $quality-review
→ $e2e-review, если затронут критический flow
→ $docs-sync, если меняется контракт или known issue
```

### Запрет

Не исправлять симптом до подтверждения первой точки расхождения.

## 7. UI-баг

```text
Browser / device: reproduce
→ $bug-triage
→ Figma/design system: source of truth
→ $visual-qa для сравнения
→ code_mapper
→ implementation_worker
→ visual regression check
→ $e2e-review, если поведение затронуто
→ visual_qa_reviewer
```

## 8. Аудит существующего приложения

Подходит, когда нужно понять качество проекта без немедленной реализации.

```text
product_strategist
+ ux_architect
+ code_mapper
+ qa_reviewer
+ security_reviewer при релевантности
+ docs_auditor
→ общий synthesis
```

Для интерфейса добавить:

```text
$ux-audit
+ $visual-qa
+ $e2e-review ключевых сценариев
```

### Итог аудита

```markdown
## Executive summary
## P0/P1
## P2
## Product gaps
## UX/UI gaps
## Engineering gaps
## Test gaps
## Security/privacy gaps
## Documentation gaps
## Quick wins
## Recommended roadmap
```

Аудит по умолчанию read-only.

## 9. Аудит документации

```text
$docs-audit
→ docs_auditor
→ проверить README и setup на чистой среде
→ сверить contracts с кодом
→ проверить CURRENT_STATE и DECISION_LOG
→ проверить ссылки и статусы
→ вернуть findings
→ $docs-sync только после review
```

Ключевой smoke test: новый человек или агент должен суметь понять проект и продолжить его без чтения старого чата.

## 10. Рефакторинг

Сначала доказать необходимость.

```text
code_mapper
→ $implementation-plan
→ зафиксировать invariant и measurable reason
→ targeted baseline tests
→ implementation_worker
→ tests
→ $quality-review
→ $e2e-review критических сценариев
→ performance check, если причина performance
→ $docs-sync при изменении архитектуры
```

### Отдельный ADR нужен, если меняется

- архитектурная граница;
- публичный API;
- схема данных;
- ownership состояния;
- инфраструктурный контракт.

## 11. Новая интеграция или автоматизация

```text
$product-discovery
→ определить source of truth и failure modes
→ code_mapper
→ security_reviewer
→ решить: core app или n8n orchestration
→ $implementation-plan
→ implementation_worker
→ integration tests
→ failure/retry/idempotency checks
→ $quality-review
→ $docs-audit
→ $docs-sync
```

### Обязательно определить

- auth/secrets;
- retries;
- idempotency;
- rate limits;
- timeout;
- duplicate events;
- partial failure;
- logging;
- manual recovery;
- ownership данных.

## 12. Добавление AI-функции

```text
$product-discovery
→ определить где AI действительно нужен
→ acceptance criteria + fallback
→ security/privacy review
→ prompt/model/data contract
→ $implementation-plan
→ implementation_worker
→ evaluation cases
→ adversarial/edge inputs
→ $quality-review
→ E2E пользовательского flow
→ cost/latency check
→ docs sync
```

Не считать субъективное «ответ выглядит нормально» достаточной оценкой.

## 13. Подготовка к PR

```text
review git status/diff
→ targeted tests
→ $quality-review
→ нужные specialized audits
→ $docs-audit
→ убедиться, что diff scoped
→ подготовить PR summary + evidence
```

Не включать чужие или случайные изменения.

## 14. Подготовка к релизу

```text
acceptance criteria
→ full relevant test suite
→ critical E2E
→ regression suite
→ visual/UX QA, если UI
→ accessibility audit
→ security review, если релевантно
→ performance check, если релевантно
→ $docs-audit
→ $release-audit
→ release_auditor
```

Только после verdict:

```text
APPROVE
или
APPROVE WITH KNOWN RISKS
```

можно переходить к отдельному разрешению на deploy/release.

## 15. После релиза

```text
smoke test production
→ проверить critical metrics/logs
→ подтвердить основной пользовательский flow
→ зафиксировать инциденты/аномалии
→ обновить CURRENT_STATE
→ сохранить reusable lesson в memories, если он применим шире проекта
```

## 16. Быстрый UX-аудит без разработки

```text
$ux-audit
→ ux_architect
→ список P1/P2/P3
→ quick wins
→ предложенный новый flow
```

Не менять код и макеты, пока пользователь явно не попросил перейти от аудита к redesign.

## 17. Быстрый технический аудит без разработки

```text
code_mapper
+ qa_reviewer
+ security_reviewer при необходимости
+ docs_auditor
→ synthesis
```

Проверить:

- architecture hot spots;
- dead/duplicate paths;
- test gaps;
- type/contracts;
- dependency risk;
- secrets;
- CI;
- documentation drift.

## 18. Работа, прерванная между сессиями или агентами

```text
прочитать AGENTS.md
→ CURRENT_STATE.md
→ DECISION_LOG.md
→ последний HANDOFF
→ git status
→ проверить расхождение docs/code
→ продолжить только ближайший safe action
```

Если предыдущая сессия оставила незнакомые изменения, сначала разобраться с ними.

## 19. Работа с memories

После проекта или значимого решения спроси:

```text
Это знание специфично для проекта или пригодится снова?
```

Если пригодится снова:

```text
project evidence
→ сформулировать lesson/pattern
→ убрать секреты и project-specific шум
→ положить в memories inbox
→ проверить применимость
→ классифицировать как pattern/tool/repo/lesson/idea
```

`memories` не заменяет документацию проекта и не имеет приоритета над его каноническими решениями.

## Матрица выбора проверки

| Тип изменения | Минимальная проверка |
|---|---|
| Текст/документация | docs-audit |
| Маленький bug fix | regression + quality-review |
| Бизнес-логика | unit/integration + quality-review |
| UI component | component check + visual-qa + accessibility |
| User flow | E2E + UX audit |
| Auth/PII/admin | security review + E2E |
| Performance-sensitive | baseline + performance audit |
| Release | release-audit + critical E2E + docs-audit |

## Правило сокращения процесса

Процесс можно **сокращать**, если риск низкий. Нельзя удалять проверку, которая доказывает основной пользовательский результат.

Хороший вопрос:

```text
Какой самый дешёвый набор действий достаточно убедительно докажет, что задача решена и ничего важного не сломано?
```
