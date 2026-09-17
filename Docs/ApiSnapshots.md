# API snapshots

Every push to `main` creates an immutable `<mod-id>-api-v<version>` tag for each mod project whose tag does not already exist. These tags are independent of release tags and preserve the source-level NWScript API available at that mod version.

Every `NwnRequiredPackage` version range must have a bounded, inclusive minimum. The build compares that minimum with the dependency project's current `Version`. An equal version uses the local `source` directory. An older minimum resolves `<mod-id>-api-v<minimum>` from `ApiSnapshotRepository`, validates the tagged project's `ModId` and `Version`, and extracts its `.nss` sources beneath `artifacts/api-cache/<mod-id>/<version>/source`. A missing or inconsistent tag fails the build before compilation.

The cache is shared by parallel mod builds through per-snapshot file locks. Completed entries are immutable and survive `dotnet clean`; deleting `artifacts/api-cache` manually forces snapshots to be downloaded again.
