# NOVA Fold

A compact folded-ribbon N for NOVA's sneaker and streetwear storefront. Three pieces share a diagonal seam, suggesting fabric and movement without relying on a shopping-bag symbol. The existing acid-lime (#C8FF1E), near-black (#0A0A0A), and off-white palette remains the basis of the identity.

The initial concept was generated with built-in ImageGen on 2026-10-04. Prompt: one flat acid-lime N monogram, inspired by folded fabric and streetwear movement, transparent background, no extra symbol, word, shadow, gradient or mockup. The generated bitmap was used as a concept reference. Final geometry was rebuilt as clean editable vector paths, removing raster artifacts and making every platform use the same shape.

## Sources and exports

- `tools/branding/mark_geometry.json` is the master geometry.
- `python3 tools/branding/export_brand.py` regenerates SVG/8-bit PNG masters, all native icons and native splash marks, and Flutter path geometry. Requires ImageMagick (`magick`).
- `assets/branding/` contains the editable mark and square icon masters. Rounded or circular masks are supplied by the launcher, not baked into the artwork.
- Android adaptive foreground fits in the central 66dp safe circle of a 108dp canvas. Android 13 monochrome icons reuse the silhouette. Android 12+ has a dedicated padded launch drawable; earlier versions use a centered 112dp vector.
- iOS icons are opaque and use the existing asset catalog sizes. Its launch image is transparent over the same near-black background.
- `assets/fonts/Syne-Variable.ttf` and `Syne-OFL.txt` bundle the official Google Fonts typeface/license. NOVA lettering works offline. The app's package identifier is unchanged.

## Motion

The native screen and Firebase initialization begin with the same centered mark. Flutter plays a finite 1.6-second reveal: the folds separate by at most three design units, settle, receive one subtle highlight, and rise as the wordmark and caption appear. The reveal and preference loading run concurrently. Reduced-motion settings show the final lockup immediately and proceed as soon as preferences are ready.

The app icon itself is static, as expected by mobile launchers. Animation belongs to the in-app launch sequence. The sequence never loops and error recovery does not replay it.

## Preview and checks

`flutter test --no-pub tools/branding/render_brand_test.dart` exports frames from the actual production widget to `build/branding/frames`. The first 49 frames cover 1.6 seconds at 30fps; remaining frames hold the finished logo for preview only.

Behavior tests cover first-time/returning routing, delayed initialization, retry, disposal, reduced motion, and compact RTL/landscape layout. No payment or account behavior is changed.
