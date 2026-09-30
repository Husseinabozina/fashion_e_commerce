# Fashion E-Commerce Architecture

## Current verified scope

The repository currently contains the application shell and one real feature:
the two-stage splash experience. There is no implemented commerce data/domain
logic in the current `master` branch yet.

Because of that, this migration intentionally does **not** create empty
`domain/` or `data/` folders. Doing so would add ceremony without a real
boundary to protect.

## Target structure

```text
lib/
  app/
    app.dart
  core/
    config/
    routing/
  features/
    splash/
      presentation/
        pages/
        widgets/
```

As commerce features are added:

```text
features/
  products/
    presentation/
    domain/
    data/
  cart/
    presentation/
    domain/
    data/
  auth/
    presentation/
    domain/
    data/
```

## Dependency rule

When a feature has business/data layers:

```text
presentation -> domain <- data
```

- Presentation owns Flutter widgets/state.
- Domain owns business rules and repository contracts.
- Data owns DTOs, APIs, caches, and repository implementations.
- App/core wires concrete dependencies and cross-cutting configuration.

## Refactor invariants

This migration must preserve:
- the first splash background/color and logo composition;
- the approximately two-second transition to the second splash;
- the Hero transition tag continuity;
- the second splash background, bottom padding, and upward slide animation;
- the existing assets;
- the current 360×800 ScreenUtil design size.

## Reliability fixes included

- the delayed navigation timer is cancellable on dispose;
- navigation checks `mounted` before using the context;
- the animation controller is disposed;
- routing is centralized and real rather than commented-out placeholder code;
- the default counter test is replaced with tests for actual application behavior;
- CI is added for analyzer and tests.
