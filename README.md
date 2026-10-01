# NOVA Fashion

A bilingual Flutter fashion storefront with a feature-first Clean Architecture and Firebase-backed accounts and shopping data.

## Run

Use Flutter 3.41.9 or newer. Firebase runs by default:

```sh
flutter pub get
flutter run
```

Android, iPhone and Web are registered in the separate **NOVA Fashion** project, `nova-fashion-hussein`. Firestore uses the named Enterprise Native database **`nova-app`** in **Frankfurt (`europe-west3`)**, with Core realtime operations enabled. Client identifiers in `lib/firebase_options.dart` are public configuration; access is enforced by Firebase Authentication and `firestore.rules`.

iPhone requires iOS 15 or newer. The project opts into Flutter Swift Package Manager for the native Firebase dependencies. The offline showcase and widget tests remain available:

```sh
flutter run --dart-define=USE_DEMO_DATA=true
flutter test
flutter analyze --no-fatal-infos --no-fatal-warnings
```

## Accounts and stored data

A guest has an anonymous Firebase UID. Creating an email/password account links that UID, keeping its saved items, bag and addresses. Signing into an existing account loads that account's data. Signing out creates a separate guest session; guest-only data cannot be recovered across devices without linking the guest to an account. Email sign-in, registration and password reset are separate actions.

Firestore persists the catalog, wishlist, bag, shopping preferences, followed brands, recently viewed products, addresses/default address, selected promotion, stock-notification requests, product reviews and **demo** order receipts. Private collections are under `users/{uid}`. Account changes recreate the navigation and personal state; late completions from disposed screens are discarded. Checkout reuses one submission ID per attempt, keeps a successful receipt after cleanup errors, and never clears another account's bag.

## Prototype boundaries

Checkout is explicitly simulated: no payment gateway, card collection or real charge. Demo receipts are under `demoOrders`; their price snapshots and totals cannot be edited after creation. Trusted fulfillment must set delivery status before returns become eligible. Clients cannot create real orders or paid/delivered status.

Stock alerts currently save requests; push delivery, FCM/server triggers, catalog administration, real payment/fulfillment and verified-purchase reviews are future backend work. Reviews require an email/password account. Notification records are server-owned; clients may only mark their own notifications read.

Rules validate owners and document schemas, block arbitrary fields/roles, protect catalog prices and deny unspecified paths. They are prototype rules covered by adversarial emulator tests; review them before broad public release. The six seeded products are sample catalog data. No billing plan was upgraded during setup.

## Firebase verification and maintenance

Node 22+ and Java 21+ are required for emulator tests:

```sh
npm --prefix tools/firebase ci
npx firebase-tools emulators:exec --only auth,firestore --project demo-nova 'npm --prefix tools/firebase run test:rules'
```

These tests cover allowed owner actions, cross-account reads/writes, malformed schemas, privilege/author spoofing, catalog tampering, immutable demo receipts, atomic returns, guest account linking, incorrect passwords and restoring a registered session. Flutter adapter tests cover persistence, account isolation, defaults, promotions, subscription deduplication and checkout idempotency.

For a Flutter emulator session, seed the same sample catalog with the Firestore console/Admin SDK and run:

```sh
npx firebase-tools emulators:start --only auth,firestore --project demo-nova
flutter run --dart-define=USE_FIREBASE_EMULATORS=true
```

On the Android emulator, also pass `--dart-define=FIREBASE_EMULATOR_HOST=10.0.2.2`. iPhone simulator and Web use `127.0.0.1` by default. Emulator clients disable persistence to avoid mixing cached local test data.

The public sample catalog can be reapplied to the configured live project with an authorized Firebase CLI login:

```sh
npx firebase-tools login
npm --prefix tools/firebase run seed
npx firebase-tools deploy --only firestore,auth --project nova-fashion-hussein
node tools/firebase/live-smoke.mjs
```

`seed` overwrites only the 12 public documents in `catalog-seed.json`. `live-smoke` creates two temporary anonymous test users, verifies actual server reads/writes and isolation, then removes their test wishlist documents and users. Database creation must explicitly enable Firestore data access and realtime updates; the Firebase deployment configuration alone does not currently set realtime mode.

See [architecture](docs/architecture/clean_architecture.md) and [Firebase acceptance/audit](docs/firebase-integration.md).
