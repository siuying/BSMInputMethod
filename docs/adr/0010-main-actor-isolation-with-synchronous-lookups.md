# Main-actor isolation with synchronous dictionary lookups

The rewrite adopts Swift 6 language mode with strict concurrency. The input method is modeled as main-actor-isolated: the InputMethodKit controller, the composing buffer, and the Candidate List window are `@MainActor`, which matches the legacy reality that all of this already runs synchronously on the IMK input thread, so there is no behavior change.

Dictionary lookups stay **synchronous** (`throws`, not `async`). The bundled dictionary is small and queries are sub-millisecond; the legacy engine already queries SQLite inline on the input thread. `BSMCore` value types (`Candidate`, `BSMCode`, …) are `Sendable` structs. Async lookups on a background actor were rejected because they would change the synchronous-on-input-thread timing the current behavior relies on while buying nothing for a small bundled database, and Swift 5 mode was rejected because it discards the compile-time concurrency safety that motivates the rewrite.
