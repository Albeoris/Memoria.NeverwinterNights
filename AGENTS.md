# Agent rules

- Generated files go in `artifacts`; retain `api-cache`.
- Every `Mods/<Project>` change bumps `Version`: PATCH compatible/internal, MINOR additive API, MAJOR breaking; update dependents after MAJOR.
- `.proj` is authoritative: wildcard `Nwn*` items, no file lists/generated manifests. Dependencies declare `ModId`, bounded `Versions`, and `PackageName`.
- NWScript is UTF-8. Repository text is English; English in Windows-1252; Russian in Windows-1251; player text is localized.
- After build-logic or multi-mod changes, clean/build Release with zero warnings/errors; validate every GUI layout.
