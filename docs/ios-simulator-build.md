# iOS simulator build isolation

## Requirement and invariants
NOVA must launch from its simulator icon without a dynamic-loader symbol failure.
Keep Flutter 3.41.9, Firebase package versions, application IDs, sandbox behavior,
and other projects' existing caches unchanged.

## Diagnosis
The installed debug app failed at launch with a missing Abseil CHexEscape symbol.
Its absl/grpc/grpcpp embedded frameworks were empty stub libraries, while the
original downloaded Abseil archive contained the required symbol. The Xcode
link command searched a shared EagerLinkingTBDs directory before package archives.
This machine's IDEBuildLocationStyle was Shared: multiple Runner workspaces used
one intermediates directory. A shared Abseil TBD advertised dynamic symbols,
although NOVA's dependency is a static archive. This explains why a successful
build could still fail in dyld before Flutter starts.

## Change and acceptance
The local Xcode build-location preference is changed from Shared to Unique.
Unlike the workspace's shared settings, this preference is honored by xcodebuild.
Xcode keeps the configured DerivedData volume and gives each workspace separate
intermediates. Existing shared caches are preserved. For another affected Mac:

```sh
defaults write com.apple.dt.Xcode IDEBuildLocationStyle -string Unique
```

This is machine configuration, not a dependency-version change. To undo it on
this machine, set IDEBuildLocationStyle back to Shared.
Verify resolved paths are workspace-specific, rebuild, and ensure the final app
no longer dynamically imports Abseil/gRPC. Install over the existing simulator app
and confirm launch and relaunch without uninstalling user data.

## Verified on 2026-10-05
- Flutter 3.41.9 rebuilt the debug simulator app successfully (Xcode: 246 seconds).
- Native intermediates were generated under the workspace-specific
  `Runner-hddzdcjcglvyfbfrfsiesywiydtz/Build/Intermediates.noindex` directory.
- `nm` found a defined CHexEscape symbol in Runner.debug.dylib; `otool -L`
  showed no dynamic imports of absl.framework/grpc.framework/grpcpp.framework.
- Installed over the existing app, launched successfully, and captured the Home
  screen. Terminated and relaunched successfully without a Flutter debugger.
- No new Runner crash report appeared during those launches.
