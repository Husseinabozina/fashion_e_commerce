# NOVA presentation assets

The repository's public case study is served from `site/` at:
https://husseinabozina.github.io/fashion_e_commerce/

## Content and provenance

- The owner supplied the iPhone 17 Pro simulator screenshots and recording on October 5, 2026. The six gallery PNGs are exact copies, without retouching. The incomplete loading/transition screenshot was excluded.
- `site/assets/video/nova-walkthrough.mp4` is a silent 50-second cut, starting one second into the supplied recording. It ends before address-entry footage. It shows launch, browsing and product selection, not a hosted card transaction. Exported as an MP4 with Apple's AVFoundation as H.264 at 1080×2348 / 30 fps, with network optimization; the original recording remains on the owner's Desktop.
- The app's existing SVG mark and bundled Syne font are reused. The font license is included in `site/assets/brand/OFL.txt`.
- `launch.gif` is an earlier preview rendered from the actual production Flutter launch widget. Its repeating preview does not mean the in-app launch loops.
- The cover SVG is a repository-native layout using the existing NOVA geometry. `social-cover.png` is its raster social-preview export.
- Product photographs and brand names are illustrative sample catalog content. No brand affiliation, image/product match or real inventory is asserted.

## Editing and preview

This is a buildless HTML/CSS/JavaScript site. There are no runtime libraries, tracking scripts or external font requests.

```sh
python3 -m http.server 8765 --directory site
```

Open http://localhost:8765. Edit `site/index.html`, `site/styles.css` and `site/app.js`.
The five gallery buttons use accessible tab semantics and arrow/Home/End navigation;
the screenshot dialog closes with Escape and returns focus to its opener. Video
playback is user-controlled and uses `preload="none"`. Reduced-motion preferences
disable smooth scrolling and transitions.

The `NOVA Portfolio` workflow publishes only `site/` to GitHub Pages on relevant
master pushes. App source, backend configuration and private local files are not
part of the deployed artifact. Technical integration details live in the linked developer documentation.
The download area identifies the build as a portfolio demo with no real purchases.

## Android download

The case study and README link directly to NOVA 1.0.1 (build 3), built from the current application source with the Fold identity and animated launch. Earlier releases remain in the repository's history but are not the primary download.
