# Firebase integration acceptance and audit

## Requirements and invariants

- Use a separate NOVA Firebase project; never reuse Shop App.
- Register existing Android/iOS bundle identifiers and Web.
- Persist shopping/account data with real email/password and anonymous authentication.
- Preserve the current bilingual storefront, feature boundaries and deterministic demo mode.
- Keep payment/fulfillment explicitly simulated; no paid status or authoritative price from a client.
- Isolate personal data by authenticated UID; retain guest data only through credential linking.
- Cancel subscriptions/timers and discard results after a screen/account is disposed.
- Do not include unrelated pre-existing Apple project changes in the Firebase commit.
- Skip Android visual QA as requested.

## Verified configuration

Project: `nova-fashion-hussein` (NOVA Fashion). Database: `nova-app`, Enterprise Native, `europe-west3` (Frankfurt), Core realtime enabled, MongoDB access disabled. Providers: anonymous and email/password. Android package: `com.example.fashion_e_commerce`. Apple bundle: `com.example.fashionECommerce`. Web app is configured in `firebase_options.dart`.

The initial setup database had realtime disabled; the live SDK check caught it before release. It contained only the 12 reproducible public sample documents and no user documents/subcollections. It was replaced with the properly configured database, rules were redeployed and the sample catalog reapplied. Live server reads/writes and cross-UID denials then passed.

## Schema and query inventory

All personal queries target the exact `users/{currentUID}/{collection}` path. Catalog/reviews are authenticated reads. Lists currently use collection reads and small client-side sorts/filtering; there are no collection-group client queries or composite-index requirements. Index/performance work is needed when the catalog/history grows.

| Path | Client permissions and validation |
|---|---|
| `products`, `catalog`, `brands`, `promotions` | Authenticated read; no client catalog/price/promotion writes |
| `products/{productId}/reviews/{uid}` | Registered author UID/name, bounded rating/comment/fit, immutable creation, no verified claim |
| `users/{uid}/cart` | Owner; catalog variant/availability; quantity integer 1–99; references only |
| `wishlist`, `following` | Owner; canonical existing catalog IDs |
| `recentlyViewed` | Owner; existing product and server timestamp |
| `addresses` | Owner; exact bounded private shipping fields |
| `settings` | Owner; supported interests, own existing default address, existing promotion |
| `subscriptions` | Owner; catalog product/color/size only |
| `notifications` | Owner read; mark read only; creation/content server-owned |
| `demoOrders` | Owner; bounded demo snapshot, immutable price/total/time; no client delivery/payment progress |
| `returnRequests` | Owner; delivered order/item, allowed reason/size; atomic order transition and request creation |
| `users/{uid}/devices`, `settings/push` | Owner registration/preferences; exact bounded token/platform/server time |
| `deviceBindings/{tokenKey}` | One current owner per installation; private get, no lists; atomic own-device registration |
| `notificationOutbox`, other paths/real orders | Server-owned; denied to clients |

## Meaningful verification

- Existing 43 Flutter regressions plus Firebase persistence/account-scope tests.
- Emulator suite: unauthenticated access, cross-account get/list/create/update/delete, quantity/type/extra-field attacks, invalid variants and stock, forged timestamps/roles/authors, notification tampering, unverified review bounds, immutable receipt contents/status/time, atomic returns and replay denial.
- Real Auth emulator: anonymous UID links to email/password; saved data survives; wrong/unknown credentials never create an account; new guest cannot read old data; registered sign-in restores it; password reset request succeeds locally.
- Live client smoke: actual anonymous sign-in, named database catalog fetch, owner wishlist write/read and cross-account read/write denial. Temporary users/documents removed afterward.

## Remaining production work

Secure payment backend and webhook settlement, authoritative fulfillment/catalog admin, activation of the tested FCM/notification functions, verified purchase review policy, monitoring and scale-oriented indexes/pagination. Rules are a reviewed prototype and require another review before broad public sharing.
