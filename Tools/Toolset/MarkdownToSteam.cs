using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;

namespace Memoria.NeverwinterNights.Toolset;

internal static partial class MarkdownToSteam
{
    private const string FeedbackUrl = "https://github.com/Albeoris/Memoria.NeverwinterNights/issues";

    public static string Convert(string markdown, string readmeUrl)
    {
        string[] lines = markdown.Replace("\r\n", "\n", StringComparison.Ordinal).Replace('\r', '\n').Split('\n');
        StringBuilder result = new();
        bool inCodeBlock = false;
        bool skippingSection = false;
        int skippedHeadingLevel = 0;

        foreach (string line in lines)
        {
            Match heading = HeadingRegex().Match(line);
            if (!inCodeBlock && heading.Success)
            {
                int level = heading.Groups[1].Length;
                string headingText = heading.Groups[2].Value.Trim().TrimEnd('#').Trim();
                if (skippingSection)
                {
                    if (level > skippedHeadingLevel) continue;
                    skippingSection = false;
                }
                if (headingText.Equals("Installation", StringComparison.OrdinalIgnoreCase))
                {
                    skippingSection = true;
                    skippedHeadingLevel = level;
                    continue;
                }
            }

            if (skippingSection) continue;

            if (FenceRegex().IsMatch(line))
            {
                result.AppendLine(inCodeBlock ? "[/code]" : "[code]");
                inCodeBlock = !inCodeBlock;
                continue;
            }

            if (inCodeBlock)
            {
                result.AppendLine(line);
                continue;
            }

            if (heading.Success)
            {
                int level = heading.Groups[1].Length;
                string headingText = heading.Groups[2].Value.Trim().TrimEnd('#').Trim();
                string convertedHeading = ConvertInline(headingText);
                result.AppendLine(level <= 3 ? $"[h{level}]{convertedHeading}[/h{level}]" : $"[b]{convertedHeading}[/b]");
                continue;
            }

            if (HorizontalRuleRegex().IsMatch(line))
            {
                result.AppendLine("[hr][/hr]");
                continue;
            }

            Match bullet = BulletRegex().Match(line);
            if (bullet.Success)
            {
                result.AppendLine($"{bullet.Groups[1].Value}• {ConvertInline(bullet.Groups[2].Value)}");
                continue;
            }

            result.AppendLine(ConvertInline(line));
        }

        if (inCodeBlock) result.AppendLine("[/code]");
        string description = result.ToString().Trim();
        if (description.Length == 0) throw new InvalidDataException("README.md produced an empty Workshop description.");
        string updateTime = DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm 'UTC'", CultureInfo.InvariantCulture);
        return $"{description}{Environment.NewLine}{Environment.NewLine}[hr][/hr]{Environment.NewLine}[i]Last updated: {updateTime}[/i]{Environment.NewLine}[url={FeedbackUrl}]Report feedback and issues[/url]{Environment.NewLine}[url={readmeUrl}]Sources on GitHub[/url]";
    }

    private static string ConvertInline(string text)
    {
        Dictionary<string, string> protectedText = [];
        string Protect(string value)
        {
            string token = $"\u001A{protectedText.Count}\u001A";
            protectedText.Add(token, value);
            return token;
        }

        text = InlineCodeRegex().Replace(text, match => Protect($"[b]{match.Groups[1].Value}[/b]"));
        text = LinkRegex().Replace(text, match => Protect($"[url={match.Groups[2].Value}]{ConvertInline(match.Groups[1].Value)}[/url]"));
        text = BoldAsteriskRegex().Replace(text, "[b]$1[/b]");
        text = BoldUnderscoreRegex().Replace(text, "[b]$1[/b]");
        text = StrikeRegex().Replace(text, "[strike]$1[/strike]");
        text = ItalicAsteriskRegex().Replace(text, "[i]$1[/i]");
        text = ItalicUnderscoreRegex().Replace(text, "[i]$1[/i]");
        foreach ((string token, string value) in protectedText) text = text.Replace(token, value, StringComparison.Ordinal);
        return text;
    }

    [GeneratedRegex("^(#{1,6})[ \\t]+(.+?)\\s*$")]
    private static partial Regex HeadingRegex();

    [GeneratedRegex("^[ \\t]*```|^[ \\t]*~~~")]
    private static partial Regex FenceRegex();

    [GeneratedRegex("^[ \\t]{0,3}(?:(?:-[ \\t]*){3,}|(?:\\*[ \\t]*){3,}|(?:_[ \\t]*){3,})$")]
    private static partial Regex HorizontalRuleRegex();

    [GeneratedRegex("^([ \\t]*)[-+*][ \\t]+(.+)$")]
    private static partial Regex BulletRegex();

    [GeneratedRegex("`([^`]+)`")]
    private static partial Regex InlineCodeRegex();

    [GeneratedRegex("\\[([^]\\r\\n]+)\\]\\(([^)\\s]+)\\)")]
    private static partial Regex LinkRegex();

    [GeneratedRegex("\\*\\*(.+?)\\*\\*")]
    private static partial Regex BoldAsteriskRegex();

    [GeneratedRegex("__(.+?)__")]
    private static partial Regex BoldUnderscoreRegex();

    [GeneratedRegex("~~(.+?)~~")]
    private static partial Regex StrikeRegex();

    [GeneratedRegex("(?<!\\*)\\*([^*\\r\\n]+)\\*(?!\\*)")]
    private static partial Regex ItalicAsteriskRegex();

    [GeneratedRegex("(?<![\\w_])_([^_\\r\\n]+)_(?![\\w_])")]
    private static partial Regex ItalicUnderscoreRegex();
}
