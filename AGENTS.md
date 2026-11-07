# CookFresh-Classic

Native Apple app (SwiftUI + CoreData) built with Xcode. Single target, no tests, CI, or package manager.

## Build

- Scheme: `CookFresh-Classic`
- iOS (verified working): `xcodebuild -scheme CookFresh-Classic -destination 'platform=iOS Simulator,name=iPhone 15' build`
- macOS (compiles; sign with `CODE_SIGNING_ALLOWED=NO` in CLI): `xcodebuild -scheme CookFresh-Classic -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO build`

## CoreData

- Model: `CookFresh-Classic/CookFresh_Classic.xcdatamodeld` (`ChatSession`, `ChatMessage` entities). `ChatSession.messages` cascades to `ChatMessage`.
- `codeGenerationType="class"`: Xcode auto-generates `ChatSession`/`ChatMessage` subclasses into DerivedSources. Do not add hand-written managed-object files.
- `PersistenceController.shared` provides the container; `PersistenceController.preview` for SwiftUI previews.

## Platform support

`project.pbxproj` declares `SUPPORTED_PLATFORMS = "iphoneos iphonesimulator macosx"`, `SUPPORTS_MACCATALYST = NO`, `MACOSX_DEPLOYMENT_TARGET = 13.5`. The UI is now cross-platform (SwiftUI only); avoid iOS-only APIs such as `.navigationBarTrailing` placement or `EditButton()` in shared views. Both platforms build; macOS code signing may fail in CLI without a valid cert (use `CODE_SIGNING_ALLOWED=NO` for compile checks).

## Conventions

- iOS deployment target 15.6, macOS 13.5, Swift 5.0. Bundle ID `com.olaflueg.CookFresh-Classic`. (Project-level IPHONEOS_DEPLOYMENT_TARGET still 17.2; target overrides to 15.6.)
- Gemini API key and selected model stored via `@AppStorage` (UserDefaults keys `gemini_api_key`, `gemini_model`). `GeminiService` (actor) calls the REST API with full history each turn.
- No test target exists; verification = successful build.