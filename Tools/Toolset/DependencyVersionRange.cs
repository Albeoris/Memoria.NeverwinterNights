namespace Memoria.NeverwinterNights.Toolset;

internal sealed class DependencyVersionRange
{
    private readonly IReadOnlyList<VersionInterval> intervals;

    private DependencyVersionRange(string text, IReadOnlyList<VersionInterval> intervals, Version minimumVersion)
    {
        Text = text;
        this.intervals = intervals;
        MinimumVersion = minimumVersion;
    }

    public string Text { get; }
    public Version MinimumVersion { get; }

    public static DependencyVersionRange Parse(string text)
    {
        if (string.IsNullOrWhiteSpace(text)) throw new FormatException("Dependency versions must not be empty.");
        string[] parts = text.Split(';', StringSplitOptions.TrimEntries);
        if (parts.Any(part => part.Length == 0)) throw new FormatException($"Invalid dependency versions '{text}': empty interval.");
        List<VersionInterval> intervals = parts.Select(part => VersionInterval.Parse(part, text)).ToList();
        VersionInterval first = intervals.OrderBy(interval => interval.Minimum).First();
        if (first.Minimum is null) throw new FormatException($"Invalid dependency versions '{text}': API validation requires a bounded minimum version.");
        if (!first.IncludeMinimum) throw new FormatException($"Invalid dependency versions '{text}': API validation requires an inclusive minimum version.");
        return new DependencyVersionRange(text, intervals, first.Minimum);
    }

    public bool Contains(Version version)
    {
        return intervals.Any(interval => interval.Contains(version));
    }

    private sealed record VersionInterval(Version? Minimum, bool IncludeMinimum, Version? Maximum, bool IncludeMaximum)
    {
        public static VersionInterval Parse(string part, string fullText)
        {
            if (part.Length < 3 || (part[0] != '[' && part[0] != '(') || (part[^1] != ']' && part[^1] != ')')) throw new FormatException($"Invalid dependency versions '{fullText}': '{part}' must use NuGet interval brackets.");
            string body = part[1..^1];
            int comma = body.IndexOf(',');
            if (comma < 0)
            {
                if (part[0] != '[' || part[^1] != ']' || body.Length == 0) throw new FormatException($"Invalid dependency versions '{fullText}': exact versions must use [version].");
                Version exact = ParseEndpoint(body, fullText);
                return new VersionInterval(exact, true, exact, true);
            }
            if (body.IndexOf(',', comma + 1) >= 0) throw new FormatException($"Invalid dependency versions '{fullText}': '{part}' contains too many separators.");
            string minimumText = body[..comma].Trim();
            string maximumText = body[(comma + 1)..].Trim();
            Version? minimum = minimumText.Length == 0 ? null : ParseEndpoint(minimumText, fullText);
            Version? maximum = maximumText.Length == 0 ? null : ParseEndpoint(maximumText, fullText);
            if (minimum is null && part[0] == '[') throw new FormatException($"Invalid dependency versions '{fullText}': an unbounded minimum must use '('.");
            if (maximum is null && part[^1] == ']') throw new FormatException($"Invalid dependency versions '{fullText}': an unbounded maximum must use ')'.");
            if (minimum is not null && maximum is not null && (minimum > maximum || (minimum == maximum && (part[0] != '[' || part[^1] != ']')))) throw new FormatException($"Invalid dependency versions '{fullText}': '{part}' is empty.");
            return new VersionInterval(minimum, part[0] == '[', maximum, part[^1] == ']');
        }

        public bool Contains(Version version)
        {
            if (Minimum is not null && (version < Minimum || (version == Minimum && !IncludeMinimum))) return false;
            if (Maximum is not null && (version > Maximum || (version == Maximum && !IncludeMaximum))) return false;
            return true;
        }

        private static Version ParseEndpoint(string text, string fullText)
        {
            string[] components = text.Split('.');
            if (components.Length is < 1 or > 3 || components.Any(component => component.Length == 0 || !component.All(char.IsDigit) || (component.Length > 1 && component[0] == '0'))) throw new FormatException($"Invalid dependency versions '{fullText}': endpoint '{text}' must contain one to three numeric components.");
            int[] values = components.Select(component => int.Parse(component, System.Globalization.CultureInfo.InvariantCulture)).ToArray();
            return new Version(values[0], values.Length > 1 ? values[1] : 0, values.Length > 2 ? values[2] : 0);
        }
    }
}
