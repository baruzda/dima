# Стратегия проверок и аудитов

> Status: APPROVED  
> Authority: CANONICAL  
> Last reviewed: 2026-08-16

Этот документ выделяет проверки в отдельный обязательный контур. Качество нельзя оставлять последним пунктом «если останется время».

## Принцип

```text
BUILD → VERIFY → REVIEW → FIX → RE-VERIFY → HANDOFF
```

Автор реализации не считается достаточным источником подтверждения качества. Для значимых изменений нужен независимый review, а для критических сценариев — воспроизводимая автоматическая или ручная проверка.

## Карта проверок

| Проверка | Что доказывает | Когда обязательна | Основной исполнитель |
|---|---|---|---|
| Static checks | код соответствует базовым техническим ограничениям | почти всегда | Codex / CI |
| Unit tests | локальная бизнес-логика работает | при изменении логики | test runner / Codex |
| Integration tests | модули и API корректно взаимодействуют | при изменении границ системы | test runner / Codex |
| E2E | пользователь может завершить критический сценарий | критические web/app flows | Playwright / platform tooling |
| Regression | исправленная ошибка не вернулась | каждый подтверждённый bug fix | automated test или воспроизводимый сценарий |
| Visual QA | реализация соответствует дизайн-системе и макету | UI-изменения | Figma + screenshots + reviewer |
| Responsive QA | интерфейс не ломается на целевых размерах | web/mobile UI | browser/device tooling |
| Accessibility audit | продукт доступен с клавиатуры, screen reader и т.д. | пользовательские интерфейсы | automated + manual review |
| UX audit | flow понятен, завершён и не содержит тупиков | новые/изменённые сценарии | UX reviewer |
| Product audit | функция соответствует проблеме, scope и критериям | значимые функции и релизы | product reviewer |
| Security audit | доверительные границы и данные защищены | auth, payments, PII, API, внешние интеграции | security reviewer |
| Performance audit | скорость и ресурсы остаются приемлемыми | performance-sensitive изменения | profiler / browser tooling |
| Documentation audit | документация соответствует реальному продукту и коду | перед handoff/release и после крупных изменений | docs keeper + reviewer |
| Dependency audit | новые зависимости оправданы и безопасны | добавление/обновление зависимостей | package tooling + security review |
| Release audit | все критические гейты пройдены | перед production release | independent reviewer |

## 1. E2E

E2E проверяет не отдельную функцию, а наблюдаемый пользовательский результат.

Для каждого критического сценария зафиксируй:

```text
preconditions
→ entry point
→ user actions
→ system responses
→ final observable result
```

### Что покрывать в первую очередь

1. основной путь, создающий ценность;
2. авторизация и восстановление доступа, если есть;
3. создание/изменение ключевых данных;
4. платежи и другие необратимые действия;
5. критические интеграции;
6. наиболее дорогие исторические регрессии.

Не пытайся покрыть E2E каждую кнопку. Это делает suite медленным и хрупким.

### Web

Предпочтительный инструмент: Playwright или существующий E2E stack проекта.

E2E должен проверять поведение, а не случайные детали DOM. Используй стабильные пользовательские локаторы и контролируемые данные.

## 2. QA сценариев

QA начинается с acceptance criteria и UX-flow.

Проверяй:

- happy path;
- альтернативные пути;
- validation errors;
- system errors;
- loading;
- empty;
- retry;
- cancel/undo;
- permissions;
- offline, если релевантно;
- повторные действия и double-submit;
- возврат назад и сохранение состояния;
- длинные и граничные данные.

Для найденного дефекта обязательно фиксируй:

```markdown
Actual
Expected
Steps to reproduce
Environment
Evidence
Severity
Regression check
```

## 3. Visual QA

Для UI-изменения недостаточно фразы «похоже на макет».

Сравнивай:

- сетку;
- размеры;
- spacing;
- typography;
- tokens;
- состояния компонентов;
- длинные тексты;
- реальные данные;
- loading/error/empty;
- target viewport sizes;
- zoom и масштаб текста.

Для значимого интерфейса сохраняй контрольные screenshots или другой воспроизводимый visual evidence.

## 4. UX audit

UX-аудит проводится read-only агентом, который не проектировал текущую версию.

Проверяются:

- ясность цели экрана;
- понятность основного CTA;
- количество необходимых шагов;
- информационная архитектура;
- сохранение контекста;
- обратная связь системы;
- ошибки и восстановление;
- когнитивная нагрузка;
- терминология;
- доступность;
- мобильный сценарий.

Finding должен описывать не вкус ревьюера, а проблему пользователя, доказательство и минимальную рекомендацию.

## 5. Product audit

Проверяет, что команда построила нужную вещь, а не просто технически работающую вещь.

Вопросы:

1. Какую проблему решает изменение?
2. Для какого пользователя?
3. Какой observable outcome изменился?
4. Выполнены ли acceptance criteria?
5. Не появился ли скрытый scope creep?
6. Есть ли ненужная сложность?
7. Что сознательно осталось `Not now`?
8. Как будет измеряться результат?

## 6. Accessibility audit

Автоматические проверки полезны, но недостаточны.

Минимум:

- semantic structure;
- accessible names;
- keyboard navigation;
- focus order;
- visible focus;
- contrast;
- form errors;
- touch targets;
- text scaling;
- screen reader smoke test для критического flow;
- reduced motion, если есть motion.

## 7. Security audit

Обязателен при изменениях, связанных с:

- authentication/authorization;
- PII;
- платежами;
- загрузкой файлов;
- внешними URL;
- webhooks;
- API keys и secrets;
- admin-функциями;
- destructive actions;
- новыми внешними интеграциями.

Проверка должна искать достижимые риски, а не генерировать абстрактный список OWASP ради списка.

## 8. Performance audit

Запускай при изменении:

- startup/initial load;
- больших списков;
- изображений и видео;
- тяжёлых вычислений;
- запросов к API;
- bundle size;
- анимаций;
- фоновых процессов.

Сначала зафиксируй baseline и метрику, затем оптимизируй. «Кажется быстрее» не является доказательством.

## 9. Documentation audit

Документация является частью продукта разработки и тоже проходит QA.

Проверяй:

- соответствует ли README реальному запуску;
- работают ли команды и ссылки;
- совпадают ли API/contracts с кодом;
- актуален ли `CURRENT_STATE.md`;
- отражены ли значимые решения в `DECISION_LOG.md`/ADR;
- нет ли двух конфликтующих источников правды;
- помечены ли устаревшие документы как `SUPERSEDED`;
- может ли новый агент продолжить работу без старого чата;
- нет ли секретов, PII и временного мусора.

### Документационный smoke test

Новый участник должен суметь по документации:

1. понять продукт;
2. запустить проект;
3. найти основной сценарий;
4. понять текущее состояние;
5. найти принятые решения;
6. выполнить ближайшую задачу.

Если это невозможно, документация не прошла аудит.

## 10. Audit matrix по размеру изменения

### Маленький локальный fix

```text
static checks
+ targeted test
+ regression check
+ diff review
```

### UI feature

```text
static checks
+ component/integration tests
+ main E2E
+ visual QA
+ responsive QA
+ accessibility smoke
+ UX review
+ docs sync
```

### Критическая функция

```text
unit/integration
+ E2E critical flows
+ regression suite
+ UX/product audit
+ accessibility audit
+ security review
+ performance check where relevant
+ documentation audit
+ release audit
```

## 11. Независимость проверки

Предпочтительная схема:

```text
implementation_worker
→ qa_reviewer
→ ui_reviewer / ux_architect / security_reviewer where relevant
→ implementation_worker fixes findings
→ qa_reviewer re-verifies
```

Один агент может выполнять несколько ролей последовательно, если отдельный агент недоступен, но он обязан явно переключить режим с BUILD на read-only REVIEW и заново пройти критерии.

## 12. Evidence pack

Для значимого изменения сохраняй компактный пакет доказательств:

```markdown
## Automated
- command → result

## E2E
- scenario → result

## Visual
- viewport/device → screenshot/reference

## Manual
- check → result

## Audit
- reviewer → verdict/findings

## Not verified
- area → reason/risk
```

## 13. Что считать завершением

Проверка завершена не тогда, когда «тесты зелёные», а когда:

- критический пользовательский результат доказан;
- релевантные ошибки и состояния проверены;
- findings обработаны или явно приняты как known risk;
- документация соответствует фактам;
- непроверенные области перечислены;
- существует понятный release verdict.
