# Preserve input source identity for in-place upgrade

The modern app keeps the legacy `CFBundleIdentifier`/`TISInputSourceID` (`hk.ignition.inputmethod.BSMInputMethod`) and `InputMethodConnectionName` (`BSMInputMethod_Connection`) so an existing install upgrades in place and stays enabled without a re-enable or re-login.

The non-obvious part worth recording: `InputMethodServerControllerClass` must change from the bare Objective-C `BSMInputMethodController` to the fully qualified, module-namespaced Swift name (e.g. `BSMInputMethod.InputController`). Getting this wrong makes the input method silently fail to load with no error, so it is called out explicitly to stop a future reader from "correcting" it back.
