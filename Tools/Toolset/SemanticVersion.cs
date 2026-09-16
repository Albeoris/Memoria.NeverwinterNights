using System.Text.RegularExpressions;

namespace Memoria.NeverwinterNights.Toolset;

internal static partial class SemanticVersion
{
    public static bool IsValid(string value)
    {
        return VersionRegex().IsMatch(value);
    }

    public static bool IsRelease(string value)
    {
        return ReleaseRegex().IsMatch(value);
    }

    [GeneratedRegex(@"^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(?:-(?:0|[1-9][0-9]*|[0-9]*[A-Za-z-][0-9A-Za-z-]*)(?:\.(?:0|[1-9][0-9]*|[0-9]*[A-Za-z-][0-9A-Za-z-]*))*)?(?:\+[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?$")]
    private static partial Regex VersionRegex();

    [GeneratedRegex(@"^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$")]
    private static partial Regex ReleaseRegex();
}
