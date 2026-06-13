# Commit the prebuilt database and promote dictionary source inputs

The runtime `bsm.db` is committed to the repository and copied into the app bundle as a resource. The `BSMDatabaseBuilder` (see ADR 0005) is a manual regeneration tool run when the dictionary source changes, not a build phase; this matches the legacy reality that `bsm.db` was checked in, keeps app builds fast and deterministic, and avoids a build-time tool dependency.

The three raw dictionary source inputs (`BIAU1.TXT`, `bsm_applet.dat`, `extension.txt`) are promoted to a modern top-level `Data/` directory because they remain live source-of-truth that the builder consumes. This deliberately refines the earlier "move `data/` into `Legacy/`" decision: the generated database and the raw inputs are modern assets, while only the Ruby pipeline (`tools/*.rb`, `Rakefile`) is retained under `Legacy/` for reference. Having the builder read from `Legacy/data/` was rejected because it would wrongly imply those inputs are dead.

The legacy inputs are BIG5-HKSCS; they are converted to UTF-8 once and stored as UTF-8 in `Data/` so the Swift builder carries no legacy-encoding code path (the original BIG5 files stay under `Legacy/data/` for provenance). When regenerating, the conversion must reproduce the same characters the legacy Ruby `Encoding::Converter` produced so the rebuilt database matches the committed one.
