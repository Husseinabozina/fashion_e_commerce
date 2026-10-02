# Fashion E-Commerce AI Engineering Rules

This repository follows the reliability workflow from
`Husseinabozina/ai-reliability-playbook`.

## Before non-trivial changes

1. Convert the request into explicit, testable requirements.
2. Write the invariants that must not change.
3. Separate verified facts from hypotheses.
4. Map the affected files, states, navigation, data, and tests.
5. Define acceptance criteria before implementation.
6. Prefer small, reversible changes over broad rewrites.
7. Verify regressions and report only checks that were actually performed.

## Architecture

Use feature-first Clean Architecture pragmatically:

```text
lib/
  app/
  core/
  features/
    <feature>/
      presentation/
      domain/        # only when real business rules exist
      data/          # only when real external/local data exists
```

Do not create empty repositories, use cases, entities, or data sources just to imitate
Clean Architecture. Abstractions must represent real boundaries.

Dependency direction when all layers exist:

```text
presentation -> domain <- data
```

The app/composition layer wires concrete dependencies.

## Clean code rules

- One file/class should have one clear responsibility.
- Prefer descriptive names over numbered or generic names.
- UI code must not own infrastructure/networking concerns.
- Cancel timers and dispose controllers.
- Avoid unused imports, dead routes, dead abstractions, and commented-out code.
- Preserve user-visible behavior during architecture-only refactors.
- Keep navigation centralized.
- Add tests around behavior before expanding a migration.

## Verification

Minimum for architecture changes:
- `flutter analyze --no-fatal-infos --no-fatal-warnings`
- `flutter test`
- CI green when GitHub Actions is available
