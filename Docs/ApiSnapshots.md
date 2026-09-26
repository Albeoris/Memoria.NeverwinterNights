# API snapshots

Every push to `main` creates an immutable `api-<mod-id>-v<version>` tag for each mod project referenced by at least one `NwnRequiredPackage` whose tag does not already exist. Projects without consumers do not receive API tags. The `api-` prefix visually separates immutable API snapshots from the movable `latest` publishing tag and preserves the source-level NWScript API available at that mod version.

Every `NwnRequiredPackage` version range must have a bounded, inclusive minimum equal to the dependency project's current `Version`; any component mismatch fails the build. Dependency sources are compiled into consumers, so all consumers must be rebuilt against the latest fixes. The equal version uses the local `source` directory.

Snapshot resolution remains available for a future versioning policy: an older minimum resolves `api-<mod-id>-v<minimum>` from `ApiSnapshotRepository`, validates the tagged project's `ModId` and `Version`, and extracts its `.nss` sources beneath `artifacts/api-cache/<mod-id>/<version>/source`. The current validation policy rejects such a minimum before resolution, while snapshots continue to be published.

The cache is shared by parallel mod builds through per-snapshot file locks. Completed entries are immutable and survive `dotnet clean`; deleting `artifacts/api-cache` manually forces snapshots to be downloaded again.
