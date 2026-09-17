# API snapshots

Every push to `main` creates an immutable `api-<mod-id>-v<version>` tag for each mod project referenced by at least one `NwnRequiredPackage` whose tag does not already exist. Projects without consumers do not receive API tags. The `api-` prefix visually separates API snapshots from release tags and preserves the source-level NWScript API available at that mod version.

Every `NwnRequiredPackage` version range must have a bounded, inclusive minimum. The build compares that minimum with the dependency project's current `Version`. An equal version uses the local `source` directory. An older minimum resolves `api-<mod-id>-v<minimum>` from `ApiSnapshotRepository`, validates the tagged project's `ModId` and `Version`, and extracts its `.nss` sources beneath `artifacts/api-cache/<mod-id>/<version>/source`. A missing or inconsistent tag fails the build before compilation.

The cache is shared by parallel mod builds through per-snapshot file locks. Completed entries are immutable and survive `dotnet clean`; deleting `artifacts/api-cache` manually forces snapshots to be downloaded again.
