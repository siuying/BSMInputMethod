# Move legacy project aside and generate modern project with XcodeGen

The legacy Objective-C/CocoaPods project will be moved into a `Legacy/` folder, and the modernized Swift input method will take the canonical `BSMInputMethod` project name. The new project will be generated with XcodeGen so the repo root can describe the current Swift app target, Swift core module, tests, resources, and generated project settings while still retaining the legacy implementation for reference during migration.
