# Split Swift input method app and core module

The modernized BSM Input Method will be built as a Swift input method app bundle plus a separate pure Swift core module. The app target owns macOS integration, InputMethodKit controller wiring, installation bundle metadata, and UI, while the core module owns BSM behavior such as code buffering, candidate paging, matching semantics, and dictionary lookup boundaries; this preserves the system-required app bundle shape while making behavior parity testable without launching the input method.
