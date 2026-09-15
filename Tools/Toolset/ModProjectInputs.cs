namespace Memoria.NeverwinterNights.Toolset;

internal sealed class ModProjectInputs
{
    public List<string> Sources { get; } = [];
    public List<string> Resources { get; } = [];
    public List<string> Layouts { get; } = [];
    public List<string> PackageFiles { get; } = [];
    public List<string> IncludeDirectories { get; } = [];
    public List<string> Documents { get; } = [];
    public List<string> Dependencies { get; } = [];
    public List<string> WorkshopTags { get; } = [];
    public string? WorkshopAppId { get; private set; }
    public string? WorkshopPublishedFileId { get; private set; }
    public string? WorkshopVisibility { get; private set; }
    public string? WorkshopDescriptionFile { get; private set; }
    public string? WorkshopPreviewFile { get; private set; }
    public string? WorkshopChangeNoteFile { get; private set; }

    public static async Task<ModProjectInputs> LoadAsync(string path)
    {
        if (!File.Exists(path)) throw new FileNotFoundException("Generated mod input file was not found.", path);
        ModProjectInputs inputs = new();
        foreach (string rawLine in await File.ReadAllLinesAsync(path))
        {
            if (string.IsNullOrWhiteSpace(rawLine)) continue;
            int separator = rawLine.IndexOf('|');
            if (separator <= 0 || separator == rawLine.Length - 1) throw new InvalidDataException($"Invalid mod input line: {rawLine}");
            string kind = rawLine[..separator].Trim().ToLowerInvariant();
            string value = rawLine[(separator + 1)..].Trim();
            switch (kind)
            {
                case "source": inputs.Sources.Add(Path.GetFullPath(value)); break;
                case "resource": inputs.Resources.Add(Path.GetFullPath(value)); break;
                case "layout": inputs.Layouts.Add(Path.GetFullPath(value)); break;
                case "package": inputs.PackageFiles.Add(Path.GetFullPath(value)); break;
                case "include": inputs.IncludeDirectories.Add(Path.GetFullPath(value)); break;
                case "document": inputs.Documents.Add(Path.GetFullPath(value)); break;
                case "dependency": inputs.Dependencies.Add(value); break;
                case "workshop-app-id": inputs.WorkshopAppId = SetOnce(inputs.WorkshopAppId, value, kind); break;
                case "workshop-published-file-id": inputs.WorkshopPublishedFileId = SetOnce(inputs.WorkshopPublishedFileId, value, kind); break;
                case "workshop-visibility": inputs.WorkshopVisibility = SetOnce(inputs.WorkshopVisibility, value, kind); break;
                case "workshop-description": inputs.WorkshopDescriptionFile = SetOnce(inputs.WorkshopDescriptionFile, Path.GetFullPath(value), kind); break;
                case "workshop-preview": inputs.WorkshopPreviewFile = SetOnce(inputs.WorkshopPreviewFile, Path.GetFullPath(value), kind); break;
                case "workshop-change-note": inputs.WorkshopChangeNoteFile = SetOnce(inputs.WorkshopChangeNoteFile, Path.GetFullPath(value), kind); break;
                case "workshop-tag": inputs.WorkshopTags.Add(value); break;
                default: throw new InvalidDataException($"Unknown mod input kind: {kind}");
            }
        }

        return inputs;
    }

    private static string SetOnce(string? current, string value, string kind)
    {
        if (current is not null) throw new InvalidDataException($"Duplicate mod input kind: {kind}");
        return value;
    }
}
