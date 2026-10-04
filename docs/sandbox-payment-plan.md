# NOVA sandbox payment requirements

NOVA is a portfolio demonstration, not a live merchant. Card checkout must use
MyFatoorah's published public sandbox token exclusively. Private merchant tokens
remain outside the app and repository. No live API host or real card collection.

Verified facts: the public token returns payment methods on the sandbox API;
the user's private demo tokens currently return 401. ExecutePayment callbacks
are optional. The sandbox currency is KWD while NOVA catalog prices are EGP.
Use a clearly disclosed fixed 1 KWD virtual payment, not an invented FX rate.

Invariants: preserve COD/wallet demonstrations, UID privacy, checkout totals,
order idempotency and cart cleanup behavior. Keep all orders under demoOrders;
never allow client writes to real orders or payment status. No customer contact
or address data goes to the shared public merchant.

Implementation: a domain sandbox payment boundary; Dio provider adapter;
UID-scoped pending invoice persistence with an in-memory fallback; checkout
pending/check/retry UI; optional demo receipt metadata and bilingual labels.
Open the hosted checkout in the browser and verify directly with GetPaymentStatus
on return or explicit check. Never accept a callback/browser return as payment.

Acceptance: pending/failed/offline payments retain the bag and do not place an
order; paid invoices must match invoice ID, opaque reference, amount and currency;
retries reuse the persisted checkout rather than charging again; account changes
cannot save or clear another account's bag. Confirmed sandbox receipt persists
with the demo order. Restarting checkout restores its existing pending invoice.
Rules enforce isolation and bounded immutable sandbox records, and deny live
payment writes. Validate provider parsing, checkout state transitions, restart
recovery, rules attacks and existing tests. Report actual browser/native checks
separately from automated tests.
