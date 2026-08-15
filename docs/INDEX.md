# Индекс документации

> Status: APPROVED  
> Authority: CANONICAL  
> Last reviewed: 2026-08-16

Этот раздел хранит устойчивые правила работы. Документы конкретного продукта создаются отдельно в `docs/project/`.

## Канонический набор

| Документ | Отвечает на вопрос |
|---|---|
| [`01-operating-model.md`](01-operating-model.md) | Как превратить запрос в управляемую задачу |
| [`02-product-playbook.md`](02-product-playbook.md) | Что и зачем строить |
| [`03-ux-playbook.md`](03-ux-playbook.md) | Как спроектировать путь пользователя |
| [`04-ui-playbook.md`](04-ui-playbook.md) | Как описать и проверить интерфейс |
| [`05-engineering-playbook.md`](05-engineering-playbook.md) | Как менять код безопасно и минимально |
| [`06-documentation-system.md`](06-documentation-system.md) | Что считать источником правды |
| [`07-agent-orchestration.md`](07-agent-orchestration.md) | Когда и как подключать роли и субагентов |
| [`08-quality-gates.md`](08-quality-gates.md) | Какие проверки обязательны |
| [`09-prompting-guide.md`](09-prompting-guide.md) | Как ставить задачи Codex и ChatGPT |
| [`10-official-references.md`](10-official-references.md) | На каких официальных возможностях основан комплект |
| [`11-tool-stack.md`](11-tool-stack.md) | Какой инструмент использовать на каждом этапе работы |
| [`12-verification-strategy.md`](12-verification-strategy.md) | Как проводить E2E, QA, UX/UI, security, performance и documentation audits |

## Проектные документы

После запуска `scripts/bootstrap-project.sh` в целевом проекте появляется:

```text
docs/project/
├── PROJECT_BRIEF.md
├── CURRENT_STATE.md
├── DECISION_LOG.md
└── TASKS.md
```

Они отвечают соответственно за продуктовый контракт, фактическое состояние, принятые решения и очередь работы.

## Правило навигации

Если документ нельзя найти отсюда и он не относится к временной задаче, он почти наверняка потеряется. Добавляй устойчивые документы в индекс, а временные отчёты держи рядом с задачей или PR.
