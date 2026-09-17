using System.Xml.Linq;

namespace Memoria.NeverwinterNights.Toolset;

internal sealed class ModProjectInputs
{
    public string? ProjectDirectory { get; private set; }
    public string? ModId { get; private set; }
    public string? ModDisplayName { get; private set; }
    public string? ModVersion { get; private set; }
    public string? ApiSnapshotRepository { get; private set; }
    public List<string> Sources { get; } = [];
    public List<string> Resources { get; } = [];
    public List<string> Layouts { get; } = [];
    public List<string> PackageFiles { get; } = [];
    public List<string> IncludeDirectories { get; } = [];
    public List<string> Documents { get; } = [];
    public List<ModDependency> Dependencies { get; } = [];
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
                case "project-directory": inputs.ProjectDirectory = SetOnce(inputs.ProjectDirectory, Path.GetFullPath(value), kind); break;
                case "mod-id": inputs.ModId = SetOnce(inputs.ModId, value, kind); break;
                case "mod-display-name": inputs.ModDisplayName = SetOnce(inputs.ModDisplayName, value, kind); break;
                case "mod-version": inputs.ModVersion = SetOnce(inputs.ModVersion, value, kind); break;
                case "api-snapshot-repository": inputs.ApiSnapshotRepository = SetOnce(inputs.ApiSnapshotRepository, value, kind); break;
                case "source": inputs.Sources.Add(Path.GetFullPath(value)); break;
                case "resource": inputs.Resources.Add(Path.GetFullPath(value)); break;
                case "layout": inputs.Layouts.Add(Path.GetFullPath(value)); break;
                case "package": inputs.PackageFiles.Add(Path.GetFullPath(value)); break;
                case "include": inputs.IncludeDirectories.Add(Path.GetFullPath(value)); break;
                case "document": inputs.Documents.Add(Path.GetFullPath(value)); break;
                case "dependency": inputs.Dependencies.Add(ModDependency.Parse(value)); break;
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

        if (inputs.ProjectDirectory is null) throw new InvalidDataException("Missing project-directory mod input.");
        if (string.IsNullOrWhiteSpace(inputs.ModId)) throw new InvalidDataException("Missing mod-id mod input.");
        if (string.IsNullOrWhiteSpace(inputs.ModDisplayName)) throw new InvalidDataException("Missing mod-display-name mod input.");
        if (inputs.ModVersion is null || !SemanticVersion.IsValid(inputs.ModVersion)) throw new InvalidDataException($"Mod version must be SemVer: {inputs.ModVersion}");
        if (string.IsNullOrWhiteSpace(inputs.ApiSnapshotRepository)) throw new InvalidDataException("Missing api-snapshot-repository mod input.");
        string? duplicateDependency = inputs.Dependencies.GroupBy(dependency => dependency.ModId, StringComparer.OrdinalIgnoreCase).FirstOrDefault(group => group.Count() > 1)?.Key;
        if (duplicateDependency is not null) throw new InvalidDataException($"Duplicate runtime dependency: {duplicateDependency}");

        return inputs;
    }

    private static string SetOnce(string? current, string value, string kind)
    {
        if (current is not null) throw new InvalidDataException($"Duplicate mod input kind: {kind}");
        return value;
    }
}

internal sealed record ModDependency(string ModId, string Versions, string DisplayName, string ProjectPath, Version MinimumVersion, Version CurrentVersion)
{
    public static ModDependency Parse(string value)
    {
        string[] fields = value.Split('|', 4);
        if (fields.Length != 4 || fields.Any(string.IsNullOrWhiteSpace)) throw new InvalidDataException($"Invalid dependency mod input: {value}");
        DependencyVersionRange versions;
        try { versions = DependencyVersionRange.Parse(fields[1]); }
        catch (FormatException exception) { throw new InvalidDataException(exception.Message, exception); }
        string projectPath = Path.GetFullPath(fields[3]);
        if (!File.Exists(projectPath)) throw new FileNotFoundException("Dependency project was not found.", projectPath);
        (string projectModId, string currentVersionText, Version currentVersion) = ReadProjectIdentity(projectPath);
        if (!string.Equals(fields[0], projectModId, StringComparison.Ordinal)) throw new InvalidDataException($"Dependency ModId '{fields[0]}' does not match project ModId '{projectModId}': {projectPath}");
        ValidateVersions(fields[0], versions, currentVersionText, currentVersion, projectPath);
        return new ModDependency(fields[0], fields[1], fields[2], projectPath, versions.MinimumVersion, currentVersion);
    }

    internal static (string ModId, string VersionText, Version Version) ReadProjectIdentity(string projectPath)
    {
        XDocument project = XDocument.Load(projectPath, LoadOptions.SetLineInfo);
        string? modId = project.Descendants().Where(element => element.Name.LocalName == "ModId" && element.Attribute("Condition") is null && element.Ancestors().All(ancestor => ancestor.Attribute("Condition") is null)).Select(element => element.Value.Trim()).LastOrDefault(value => value.Length > 0);
        string? currentVersionText = project.Descendants().Where(element => element.Name.LocalName == "Version" && element.Attribute("Condition") is null && element.Ancestors().All(ancestor => ancestor.Attribute("Condition") is null)).Select(element => element.Value.Trim()).LastOrDefault(value => value.Length > 0);
        if (modId is null) throw new InvalidDataException($"Dependency project {projectPath} must declare an unconditional ModId.");
        if (currentVersionText is null || !SemanticVersion.IsRelease(currentVersionText)) throw new InvalidDataException($"Dependency project {projectPath} must declare an unconditional release Version in X.Y.Z notation.");
        return (modId, currentVersionText, SemanticVersion.ParseRelease(currentVersionText));
    }

    private static void ValidateVersions(string modId, DependencyVersionRange versions, string currentVersionText, Version currentVersion, string projectPath)
    {
        if (versions.MinimumVersion > currentVersion) throw new InvalidDataException($"Dependency {modId} minimum version {versions.MinimumVersion.ToString(3)} is newer than its current version {currentVersionText}: {projectPath}");
        if (!versions.Contains(currentVersion)) throw new InvalidDataException($"Dependency {modId} versions {versions.Text} do not include its current mod version {currentVersionText}: {projectPath}");
    }
}
