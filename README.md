# BSM Input Method (筆順碼輸入法) for macOS

A modern Swift rewrite of the BSM (筆順碼 / stroke-order code) macOS input method.
The input method is driven entirely by the numeric keypad: each digit is a
stroke class, and one to six strokes identify a character.

This repository is the modern Swift project. The original Objective-C /
CocoaPods / Ruby implementation is preserved under [`Legacy/`](Legacy/) for
reference, and the original usage guide and stroke table live in
[`Legacy/README.md`](Legacy/README.md).

## Requirements

- macOS 14 or later
- Xcode 16 or later (Swift 6)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

## Project layout

| Path | What it is |
| --- | --- |
| `project.yml` | XcodeGen spec for the app, Example app, and UI tests |
| `Package.swift` | Swift package: `BSMCore`, `BSMCandidateUI`, `BSMDictionarySQLite`, and the `bsm-db-build` tool |
| `App/` | The input method app: `IMKInputController` glue and `Info.plist` |
| `Sources/BSMCore/` | Pure domain: Composing Buffer, BSM Code / Stroke Marker, candidate dictionary protocol |
| `Sources/BSMCandidateUI/` | SwiftUI Candidate List and its `NSPanel` host |
| `Sources/BSMDictionarySQLite/` | SQLite.swift-backed dictionary (behind the `CandidateDictionary` boundary) |
| `Sources/BSMDatabaseBuilder/` | `bsm-db-build` CLI that regenerates `bsm.db` |
| `Example/` | Standalone app for visually reviewing / UI-testing the Candidate List |
| `Data/` | Bundled `bsm.db` and its UTF-8 dictionary sources |
| `docs/adr/` | Architecture decision records |
| `CONTEXT.md` | Domain glossary |

The deployment shape and the major decisions are recorded in
[`docs/adr/`](docs/adr/); the domain language is in [`CONTEXT.md`](CONTEXT.md).

## Build and test

```sh
# Pure domain + dictionary + builder tests (fast, no Xcode UI):
swift test

# Generate and build the app:
xcodegen generate
xcodebuild -project BSMInputMethod.xcodeproj -scheme BSMInputMethod build

# Candidate List Example app and its XCUITests:
xcodebuild -project BSMInputMethod.xcodeproj -scheme BSMExample test
```

## Install

```sh
./Scripts/install.sh
```

This builds Release and copies `BSMInputMethod.app` into
`~/Library/Input Methods`. The bundle preserves the legacy input source identity
(bundle id `hk.ignition.inputmethod.BSMInputMethod`), so installing over an
existing version upgrades it in place — it stays enabled with no re-enable or
re-login. For a first install, enable it under **System Settings → Keyboard →
Text Input → Input Sources → + → Traditional Chinese → BSM**.

## Rebuilding the dictionary

`Data/bsm.db` is committed and bundled directly. To regenerate it from the
UTF-8 dictionary sources in `Data/`:

```sh
swift run bsm-db-build Data Data/bsm.db
```

The sources were converted once from the original BIG5 / BIG5-HKSCS data via
`Tools/convert-legacy-sources.py`; the originals remain under `Legacy/data/`.

## Usage

BSM codes are typed on the numeric keypad. See
[`Legacy/README.md`](Legacy/README.md) for the full stroke table and examples;
in brief: `1`–`9`/`0` are stroke classes, `.` then a digit selects a candidate,
`Enter`/`Space` commit the first candidate, `*` is a wildcard, `-` deletes,
`/` and `=` page, `+` toggles the code column, and `Clear` resets.

## License

MIT (see `Legacy/README.md`). The input method and its code table are
copyright their original holders.
