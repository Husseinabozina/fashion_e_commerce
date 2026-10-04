# Repository synchronization and local Flutter setup

## Requirements and invariants
- Preserve the working NOVA demo, sandbox payments, branding, and application IDs.
- Commit the reviewed native platform integration and dependency lockfiles.
- Match the local editor SDK to CI (Flutter 3.41.9); keep machine paths local.
- Keep generated packages, build outputs, and private credentials out of Git.
- Push the existing feature branch without merging the draft PR into master.

## Verified facts and scope
The running iOS simulator app was built with Flutter 3.41.9. The shell/editor
previously selected Flutter 3.38.5. Pending native changes include Flutter's
Swift Package integration, CocoaPods fallback, scene lifecycle migration,
and the matching pubspec lockfile. The native project retains iOS 15.0 and
-ObjC linker settings. macOS fallback configuration has not been built here.

## Acceptance
Native property lists/project parse successfully; Podfile checksum and installed
manifest agree; Flutter analysis/tests pass in CI; working tree is clean and
local HEAD equals the remote branch after push. No application flows change.

## Developer setup
Use Flutter **3.41.9**, as pinned in `.github/workflows/flutter_quality.yml`. In Cursor, use **Flutter: Change SDK**
to select that installation. This machine also has a local, Git-excluded
`.vscode/settings.json` with `dart.flutterSdkPath` pointing to the tested SDK.
Other machines should select their own installation path.

Run `flutter pub get` with that SDK before running the iOS project. Use
`flutter run` for the first launch to prepare generated native packages.
Keep `pubspec.lock` and `ios/Podfile.lock` committed. Do not commit Pods,
Flutter ephemeral directories, SDK installations, or generated build outputs.
An initial iOS build compiles native dependencies and can take substantially
longer than subsequent launches. Avoid `flutter clean` for routine restarts.
