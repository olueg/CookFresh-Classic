# CookFresh-Classic

Native Apple app (SwiftUI + CoreData) built with Xcode. Single target, no tests, CI, or package manager.

## Build

- Scheme: `CookFresh-Classic`
- iOS (verified working): `xcodebuild -scheme CookFresh-Classic -destination 'platform=iOS Simulator,name=iPhone 15' build`
- macOS: `xcodebuild -scheme CookFresh-Classic -destination 'platform=macOS' build` — **currently fails** (see below).

## CoreData

- Model: `CookFresh-Classic/CookFresh_Classic.xcdatamodeld` (`Item` entity, optional `timestamp: Date`).
- `codeGenerationType="class"`: Xcode auto-generates `Item` (and model) subclasses into DerivedSources. Do not add hand-written `Item` managed-object files.
- `PersistenceController.shared` provides the container; `PersistenceController.preview` for SwiftUI previews.

## Platform support gotcha

`project.pbxproj` declares `SUPPORTED_PLATFORMS = "iphoneos iphonesimulator macosx"`, `SUPPORTS_MACCATALYST = NO`, `MACOSX_DEPLOYMENT_TARGET = 13.5`. But `ContentView.swift` uses `.toolbar { ToolbarItem(placement: .navigationBarTrailing) { EditButton() } }`, whose placement and `EditButton` are unavailable on macOS, so the macOS build currently fails. For a working Mac build, make those iOS-only (e.g. `#if os(iOS)` or a cross-platform placement). iOS build is the reliable verification today.

## Conventions

- iOS deployment target 17.2, macOS 13.5, Swift 5.0. Bundle ID `com.olaflueg.CookFresh-Classic`.
- No test target exists; verification = successful build.