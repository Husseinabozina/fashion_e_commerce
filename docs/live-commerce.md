# Live commerce acceptance

The next authorized work follows the completed Firebase connection: prepare real push delivery and payment integration, with trustworthy products, stock and order lifecycle. A live store means actual transactions and fulfillment, not only persistent prototype data.

## Facts and dependencies

The NOVA project is separate; Auth and the `nova-app` database have passed live SDK owner-isolation checks. Products and checkout are still sample/demo data. The user has not yet identified a payment provider, merchant account, currency or authoritative inventory source. These are required inputs for a live payment gateway. Provider credentials belong in backend secrets, never client config or chat text.

Firebase Cloud Messaging is the push transport. Automatic event-triggered delivery uses Cloud Functions and therefore requires Blaze billing. iPhone delivery requires the owner's Apple Developer APNs key. Those external activations are pending; code can be prepared and tested without upgrading billing or inventing credentials.

## Invariants

- Default checkout stays labelled demo until a real gateway is configured and verified.
- A client must never submit an authoritative paid status, price or stock decrement.
- Merchant settlement must follow a verified signed webhook, not a success page.
- The server must calculate amount/currency and reserve inventory atomically.
- Duplicate requests and callbacks must not create duplicate orders or charges.
- Device registration is private; account transitions revoke its old binding.
- Notification text is generic; no personal shipping/payment data in push payloads.
- Stock alerts are sent only for a size that changed from unavailable to available.
- No real push send or billing/merchant activation is claimed from local tests.

## Acceptance

Prepare opt-in FCM client permission/registration/refresh, foreground delivery/open handling, account-safe cleanup and protected device schemas. Prepare server-created notification records and real FCM delivery on stock/order events, with deduplication and failed-delivery retry handling. Test matching, retries, isolation and malformed device writes. Document exact deployment inputs.

Payment implementation is dependent on provider selection/merchant setup. Once supplied, implement a hosted checkout and webhook using the provider's official API, test its sandbox end-to-end, then validate live mode separately. Authoritative catalog/admin and fulfillment need the chosen operational source.

## Implemented push pipeline and limits

Android/iOS have explicit enable/disable actions. A device registers only with OS permission; iOS additionally checks APNs readiness. Tokens refresh with owner scoping. Credential changes wait for old device removal. One `deviceBindings/{tokenKey}` owner supersedes stale private registrations even after an app restart; the sender rechecks that binding immediately before sending. Foreground messages and opened routes ignore other UIDs. Cold opens wait until account loading, splash and onboarding have reached Home.

Cloud Functions v2 uses the same named `nova-app` database in Frankfurt. An existing size changing from unavailable to available creates one notification per account/product/event, only for matching subscriptions and colors. Changes under server-owned `users/{uid}/orders` create generic order updates; client `demoOrders` never trigger real payment/shipment claims. Real-order opens currently show the inbox until a real order repository/payment backend exists.

Notification records and a private durable outbox are created atomically with deterministic event IDs. Delivery leases, per-device progress, invalid-token removal and trigger retries handle failures. FCM delivery is at least once: a crash after FCM accepts a message can repeat it. Collapse IDs help bound repeats, but exactly-once delivery is not promised. An already accepted OS notification cannot be recalled on sign-out; all push text stays generic, with no address, customer name, price or payment details. Web/macOS push is not enabled by this mobile implementation.

## Activation steps

1. The project owner links billing and chooses Blaze in the [Firebase console](https://console.firebase.google.com/project/nova-fashion-hussein/overview). No billing upgrade or notification-functions deployment was performed by this change. FCM transport itself does not require Blaze; the automatic Cloud Functions pipeline does.
2. For iPhone, use the owner's Apple Developer team/provisioning profile for the existing bundle identifier (or arrange a coordinated bundle/config migration), enable Push capability, and upload the APNs `.p8` key, key ID and team ID under Firebase project settings / Cloud Messaging. Do not put that private key in Git or chat. Development/production APNs entitlements are set by build configuration; remote notification/background fetch capabilities are prepared. Keep Firebase method swizzling enabled.
3. After those owner activations, deploy the prepared code:

```sh
npm --prefix functions ci
npm --prefix functions test
npx firebase-tools deploy --only functions:notifications --project nova-fashion-hussein
```

4. On a supported signed device, sign in and explicitly enable notifications from the notifications page. First send a console test to that device token. Then subscribe to an unavailable sample size and use a trusted admin to restore it; verify one in-app record and foreground/background/cold-open delivery. Switch accounts and verify old-account routes/content never open. Revoke OS permission and repeat the negative checks. These real-device send checks have not been performed.
5. After integrating payments/authoritative orders, verify a trusted real-order status change triggers an alert and demo checkout does not.

[Firebase mobile setup](https://firebase.google.com/docs/cloud-messaging/flutter/get-started) and [Cloud Functions billing/deployment requirements](https://firebase.google.com/docs/functions/get-started).

## What makes this an operational store

A payment provider and merchant account define currency, available payment methods and verified callback signatures. The next payment implementation will use a server-calculated checkout amount, provider-hosted payment UI and signed webhook confirmation. A successful client page alone will never mark an order paid. Stock reservation, expiry, duplicate callbacks, refunds and failed payments need sandbox tests before any live transaction.

A real catalog needs actual SKUs, prices, images, size/color inventory and an owner-controlled source. An admin panel is a reasonable starting point if there is no existing inventory system, but no operational product source has yet been supplied. Fulfillment needs someone to accept orders, prepare parcels, record carrier/tracking/status and process returns/refunds. Software can support these actions; it cannot invent inventory or perform physical shipping.

Payment/provider/currency and catalog-source questions are pending. Checkout remains explicitly demo; no real charges, stock reservations or live shipping claims have been enabled.
