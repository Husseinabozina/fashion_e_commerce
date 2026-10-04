# NOVA application architecture

## Composition and dependency direction

The app now has catalog, search, product details/complete looks, authentication, wishlist, bag, checkout, orders/returns, addresses, brands, preferences, reviews, promotions, notifications and recent-history features. Each feature groups its presentation, business rules and external data boundary.

```text
presentation -> domain <- data
app/core wires concrete implementations
```

Presentation owns widgets and Cubits. Domain owns entities, use cases and repository contracts. Data owns Firebase/demo data sources and serialization. `configureDependencies` selects either real Firebase services or deterministic demo sources; tests can inject fake SDK instances without changing feature business rules.

`main.dart` initializes Firebase before starting account-dependent screens. The bootstrap has an explicit retry state. `FirebaseAccountStore` creates UID-scoped collection references at operation start; it keeps no account data cache. Account transitions recreate the navigator and personal Cubits. `AccountCubit` ignores late results after disposal, while form write errors leave the form open for retry. Global Auth cancels its stream subscription.

## Data ownership

The catalog and promotions are server-managed. User data lives under `users/{uid}`. A guest is an authenticated anonymous UID, and registration links credentials to preserve it. Signing into an existing account does not merge unrelated guest data. Reviews are public to authenticated shoppers and owned by the author's UID; private addresses/order labels never enter public collections.

Checkout remains a simulated business flow. Product reference documents in the bag read the latest catalog, while demo order item snapshots preserve the submitted display values. An attempt ID makes receipt saves idempotent. Owner checks prevent an in-flight purchase from saving or clearing data in a newly selected account. A failed cart cleanup cannot cause the same order to be placed again.

## Preserved presentation invariants

The two-stage splash, cancellable navigation timer, disposed animation controller, central routes, Hero tag, existing assets and 360×800 ScreenUtil design size remain. English/Arabic, small screens, large text, keyboard forms and the full simulated purchase journey are covered by existing widget regression tests. Android visual review remains outside this change's acceptance scope.

## Verification

Flutter analyzer and all feature/widget tests run in GitHub Actions. Firebase adapters have fake-SDK tests for persistence and account scope. The Auth/Firestore emulator suite probes real rules using allowed writes and adversarial requests. A separate live smoke check confirms the configured project/database and server-side owner isolation, then removes its temporary data.
