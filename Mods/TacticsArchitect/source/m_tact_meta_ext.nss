// Extension point: set M_TACT_META_DECISION to -1 to reject or 1 to force-allow.
// Inputs on OBJECT_SELF: M_TACT_META_SPELL (int), M_TACT_META_TARGET (object).
void main()
{
    DeleteLocalInt(OBJECT_SELF, "M_TACT_META_DECISION");
}
