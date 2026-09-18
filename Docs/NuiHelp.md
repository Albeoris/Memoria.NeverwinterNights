# Shared NUI help

Memoria-owned windows use `MEMORIA_NUI_Create` and annotate contextual-help elements with `MEMORIA_NUI_Help`. The wrapper removes the need for per-control event logic: it assigns event identifiers where needed and registers static or bound help text for the window. Each owning NUI event script calls `MEMORIA_NUI_HandleHelpEvent`; right-clicking a registered element opens the shared help window. Windows created directly with `NuiCreate` are unaffected.

The registration is intentionally scoped to each window token. This keeps the behavior global across Memoria packages without intercepting unrelated module or third-party NUI windows.
