# NOVA launch identity

## Requirements and acceptance
- A recognizable NOVA monogram, legible at launcher sizes, using the existing near-black / acid-lime palette.
- Android launcher (legacy, adaptive and monochrome), iOS icon and visible application names say NOVA.
- Native launch and Flutter initialization use the same dark surface and mark; no Suits logo or white loading flash.
- A brief, finite Flutter brand reveal; respect reduced motion, stay usable at small/landscape sizes, no network-dependent brand artwork or typography.
- First-time users still reach onboarding; returning users reach Home. Recover from preference-loading errors and never navigate after disposal.
- Produce and inspect real rendered launch frames, exercise navigation and reduced motion, build and sign an installable APK with an incremented version code, and publish a verified mobile download.

## Invariants
Keep package identifiers, signing key, Firebase project, payment sandbox behavior, account/data/navigation destinations and existing unrelated native changes. Do not reset working-tree changes.

## Verified facts
- Launcher label is fashion_e_commerce; MaterialApp title is Fashion E-Commerce.
- Existing raster logo spells Suits. Launch currently contains two timed routes (2 s + 1.3 s), with different backgrounds.
- Firebase initialization shows a separate light spinner before those routes.
- Palette: #0A0A0A, #C8FF1E, #F5F5F2. Home uses Syne with a NOVA_ wordmark.
- Published build is version 1.0.0, code 2. Android minimum SDK 24.

## Hypotheses to verify
- A single visual composition can remain stable through native startup, Firebase bootstrap and the brand reveal.
- A three-part folded N remains readable under circle/squircle launcher masks.

## Affected areas
Shared brand artwork/widgets; splash timing and preference routing; bootstrap loading UI; Home lockup; Android resources/manifest; iOS asset catalogs/launch storyboard/display name; widget tests; generated brand exports and release packaging.

## Verification
Inspect generated artwork and actual Flutter frames. Test first/returning routing, error retry, disposal, reduced motion, and small RTL/landscape layout. Run analyzer and Flutter suite, validate native assets and APK signature, then verify the published download checksum.

## Validation results
- Full Flutter suite: 83 passed; one existing opt-in provider smoke test skipped.
- New launch tests verify normal/reduced motion, first and returning customer routing, slow preferences, retry, disposal, and compact RTL/landscape layouts.
- All Android resource XML and iOS launch storyboard parse. iOS icon sizes, 8-bit color, and opacity verified.
- Brand preview is rendered from production Flutter widgets with the bundled typeface.
