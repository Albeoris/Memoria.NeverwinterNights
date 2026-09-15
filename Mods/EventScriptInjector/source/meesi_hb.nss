// Loader registration point for Event Script Injector.
// ESI itself is initialized by consumers when they register event handlers.
// Relicensed under the MIT License by Albeoris. See THIRD_PARTY_NOTICES.md.

void main()
{
    object oModule = GetModule();
    if (GetLocalString(oModule, "MEESI_RUNTIME") != "1.0.0") SetLocalString(oModule, "MEESI_RUNTIME", "1.0.0");
}
