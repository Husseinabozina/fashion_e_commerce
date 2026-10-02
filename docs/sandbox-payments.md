# MyFatoorah sandbox checkout

## Try it in NOVA

1. Add a product to the bag and enter a demo shipping address.
2. Choose Card, review the EGP total and continue to test payment.
3. Open test checkout. The provider page displays **1.000 KWD**: a fixed virtual
   sandbox amount, separate from the EGP basket total.
4. Use only this official test card: **5123450000000008**, expiry **01/39**,
   CVV **100**, name **Test User**. In the ACS Emulator, submit the selected
   successful authentication result. Never enter a real card.
5. Return to NOVA. The app checks when it resumes; Check payment result also
   retries verification. A matching Paid invoice saves one demo order and clears
   the bag. Failed/pending/offline attempts retain it.

Returning to review preserves an unfinished invoice. The same basket/account
restores its link after restart when Firebase is configured. An offline demo
uses memory, so pending invoices survive navigation but not process restart.
Cancelled invoices are discarded before creating another attempt. Hosted links
can expire according to the provider; the link is not a permanent payment URL.

## Scope and credentials

Only MyFatoorah's **public documentation test token** is compiled into NOVA.
There is no private account token override, live host, real card collection,
webhook or billing upgrade. The customer's contact/address are not sent to the
shared sandbox merchant. An opaque random reference binds the invoice to NOVA's
attempt. Because the merchant is shared and the credential public, sandbox
receipt metadata is for demonstration only, never authoritative financial proof.

The account-specific token supplied by the user remains outside this repository
and currently returns 401. Support activation is still pending. A future private
merchant integration requires a server secret and independent authorization;
never paste that token into Flutter code. Public sandbox availability/token may
change under the provider's control.

Confirmation requires NOVA to be open and able to query the provider. There is
no background/server confirmation when the app is closed. Order data stays under
private `demoOrders`, with bounded optional sandbox receipt metadata. Rules
prevent access to another UID's sessions and client writes to real payment/order
records. Idempotent order IDs prevent duplicate demo orders when saves retry.

## Verification completed on 2026-10-02

The actual Flutter provider adapter created invoice **7226700**, initially
verified Pending, then verified Paid after hosted payment with the official
Mastercard test card and successful 3D Secure emulator authentication. Invoice
identity, opaque reference, 1 KWD amount and display currency matched. This was
a sandbox transaction; it does not test a real charge or native browser return.

Focused automated checks cover pending/declined/offline outcomes, save retries,
account changes, duplicate attempts, persisted restart recovery, invalid/live
URLs, receipt mismatches, completed invoice cleanup, bilingual small-screen UI
and Firestore isolation. The live-provider smoke test is opt-in and skipped by
the ordinary suite so CI never creates invoices:

```sh
flutter test --dart-define=LIVE_SANDBOX_TEST=true test/sandbox_provider_smoke_test.dart
# After paying the generated virtual invoice in the browser:
flutter test --dart-define=LIVE_SANDBOX_TEST=true --dart-define=VERIFY_SANDBOX_PAYMENT=true test/sandbox_provider_smoke_test.dart
```

Official references:
[API key and demo activation](https://docs.myfatoorah.com/docs/api-key),
[ExecutePayment](https://docs.myfatoorah.com/docs/execute-payment),
[GetPaymentStatus](https://docs.myfatoorah.com/docs/get-payment-status),
[test cards](https://docs.myfatoorah.com/docs/test-cards).
