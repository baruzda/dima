---
name: visual-qa
description: Используй после реализации UI для независимого сравнения интерфейса с Figma, дизайн-системой или утверждённой спецификацией. Проверяет визуальную точность, состояния, responsive, overflow и accessibility evidence без изменения файлов.
---

# Visual QA

## Процесс

1. Найди визуальный source of truth: Figma, design spec, approved screenshot или существующую design system.
2. Зафиксируй контрольные размеры экрана и состояния.
3. Сравни:
   - layout/grid;
   - spacing;
   - typography;
   - colors/tokens;
   - radii/elevation;
   - component anatomy;
   - interaction states;
   - content and long text;
   - loading/empty/error;
   - responsive/overflow.
4. Для web проверь минимум узкий mobile и desktop, плюс промежуточный размер для сложного layout.
5. Проверь zoom/text scaling и keyboard focus, когда релевантно.
6. Каждое замечание должно содержать source of truth, фактическое отклонение и влияние.
7. Не превращай личный вкус в finding.
8. Не меняй файлы в этом проходе.

## Результат

```markdown
## Reference
## Viewports and states checked
## P0/P1 visual defects
## P2 defects
## P3 polish
## Accessibility observations
## Evidence
## Verdict
```

## Готово, когда

Команда понимает, соответствует ли реализация утверждённой системе и какие конкретные отклонения блокируют приёмку.
