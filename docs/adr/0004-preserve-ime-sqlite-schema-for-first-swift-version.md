# Preserve the IME SQLite schema for the first Swift version

The first Swift version will keep the existing `ime` SQLite schema with `id`, `code`, `word`, and `frequency` columns plus the current code and frequency indexes. This lets the modern runtime and preprocessing tool target the same data shape as the legacy implementation while behavior parity is being established.
