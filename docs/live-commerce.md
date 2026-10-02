# NOVA demonstration scope

NOVA is a portfolio application. The user explicitly excluded operating a real
store: no real charges, physical inventory, shipping or refunds are planned.
Products, checkout totals, delivery estimates and orders remain demonstration
records. Firebase authentication and private persistent app data are connected
to `nova-fashion-hussein`, named database `nova-app` in Frankfurt.

## Electronic payment implemented

Card checkout now uses MyFatoorah's published public sandbox credential and
provider-hosted card page. It creates a virtual invoice, opens it in the browser,
and verifies the invoice ID, opaque reference, amount and currency through
GetPaymentStatus before saving a demo order. The user's private demo account
currently returns HTTP 401; support activation is pending. Private keys are not
included in the application or repository.

The sandbox uses a fixed virtual **1 KWD** payment, clearly disclosed separately
from the cart's EGP total. There is no currency conversion claim and no real
money movement. Only the official test card is shown. Customer name/contact/
address and card data are not sent by NOVA to the shared sandbox merchant.

Pending invoices are private and restored for the same basket/account. Failed,
pending and unverifiable attempts retain the bag. Saving a confirmed demo order
uses its invoice ID as an idempotency key. Receipt metadata survives app restarts;
consumed invoices are not reused for a later identical purchase. Real `orders`
and payment records remain protected from client writes.

See [sandbox payment guide](sandbox-payments.md) for testing and limitations.

## Implemented push pipeline and limits

Android/iOS have explicit enable/disable actions. A device registers only with OS permission; iOS additionally checks APNs readiness. Tokens refresh with owner scoping. Credential changes wait for old device removal. One `deviceBindings/{tokenKey}` owner supersedes stale private registrations even after an app restart; the sender rechecks that binding immediately before sending. Foreground messages and opened routes ignore other UIDs. Cold opens wait until account loading, splash and onboarding have reached Home.

Cloud Functions v2 uses the same named `nova-app` database in Frankfurt. An existing size changing from unavailable to available creates one notification per account/product/event, only for matching subscriptions and colors. Changes under server-owned `users/{uid}/orders` create generic order updates; client `demoOrders` never trigger real payment/shipment claims. Real-order opens currently show the inbox until a real order repository/payment backend exists.

Notification records and a private durable outbox are created atomically with deterministic event IDs. Delivery leases, per-device progress, invalid-token removal and trigger retries handle failures. FCM delivery is at least once: a crash after FCM accepts a message can repeat it. Collapse IDs help bound repeats, but exactly-once delivery is not promised. An already accepted OS notification cannot be recalled on sign-out; all push text stays generic, with no address, customer name, price or payment details. Web/macOS push is not enabled by this mobile implementation.

## Optional notification activation

The prepared push code remains optional for this demonstration. Automatic
Cloud Functions delivery requires Blaze billing; iPhone delivery requires the
owner's Apple Developer/APNs setup. Neither billing nor notification functions
have been activated by the sandbox payment work.

If the owner later chooses to activate mobile push, follow
[Firebase mobile setup](https://firebase.google.com/docs/cloud-messaging/flutter/get-started)
and [Cloud Functions deployment requirements](https://firebase.google.com/docs/functions/get-started),
then deploy the prepared notifications code and verify foreground, background,
cold-open and account-isolation behavior on signed devices. These real-device
send checks have not yet been performed. Demo checkout does not claim a real
payment, shipment or automatic fulfillment.
