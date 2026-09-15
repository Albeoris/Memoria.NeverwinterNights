// Extension point: set METACT_META_DECISION to -1 to reject or 1 to force-allow.
// Inputs on OBJECT_SELF: METACT_META_SPELL (int), METACT_META_TARGET (object).
void main()
{
    DeleteLocalInt(OBJECT_SELF, "METACT_META_DECISION");
}
