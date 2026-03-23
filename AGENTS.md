# Repository Guidelines

## Project Structure & Module Organization
`Enjoyable` is a macOS AppKit application. Core app classes live in `Classes/`, shared Objective-C categories live in `Categories/`, and app entry-point files such as `main.m` and the prefix header live in `Other Sources/`. UI resources are under `Resources/`, including `Resources/English.lproj/MainMenu.xib`, localized strings, status icons, and the bundled Help book in `Resources/Help/`. Project configuration is in `Enjoyable.xcodeproj` plus the top-level `Info.plist`. Treat `build/` as generated DerivedData output, not source.

## Build, Test, and Development Commands
Use the root `Makefile` for day-to-day work:

```bash
make build    # Debug build into ./build
make run      # Build and launch the app
make open     # Open the last built app bundle
make release  # Release build
make clean    # Remove DerivedData/build output
```

For direct Xcode builds, use `xcodebuild -project Enjoyable.xcodeproj -scheme Enjoyable -configuration Debug build`. The app build also regenerates the Help index via `Resources/Help/.../Makefile`, so keep the help HTML buildable.

## Coding Style & Naming Conventions
Follow the existing Objective-C style: 4-space indentation, braces on the same line, and one class per `.h`/`.m` pair. Preserve Cocoa naming patterns and the repository’s prefixes: app types use `NJ...` (`NJMapping`, `NJInputController`), while categories use `ClassName+Feature` (`NSFileManager+UniqueNames`). Keep UI-facing strings localized through `Resources/English.lproj/Localizable.strings` when introducing new text.

## Testing Guidelines
There is no automated test target in the project today, so every change must include a manual smoke test. At minimum, run `make build` and verify the affected flow in the app: device detection, mapping edits, status-menu behavior, import/export, or Help content as applicable. If you add automated coverage, prefer an XCTest target with files named after the class under test, for example `NJDeviceTests.m`.

## Commit & Pull Request Guidelines
Match the existing history: short, imperative subjects such as `Fix controller mapping collisions` or `Update README.md`. Keep formatting-only commits separate from behavior changes when practical. PRs should include a concise summary, linked issue if available, manual test notes, and screenshots for visible UI/XIB changes. Call out macOS version, Xcode version, and any codesigning or universal-binary impact when relevant.
