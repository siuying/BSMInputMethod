# Hide SQLite.swift behind a candidate dictionary boundary

The Swift core will expose BSM concepts such as codes, candidates, counts, paging, and possible next codes rather than SQLite.swift types. SQLite.swift will be used for both runtime database lookup and the SwiftPM database builder, but it remains behind a candidate dictionary boundary so behavior parity tests can use in-memory dictionaries and app/UI callers are not coupled to the database library.
