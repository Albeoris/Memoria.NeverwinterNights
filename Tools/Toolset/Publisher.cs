using System.IO.Compression;
using System.Text;
using System.Text.RegularExpressions;

namespace Memoria.NeverwinterNights.Toolset;

internal static partial class Publisher
{
    public static async Task<int> PublishAsync(ProjectContext context, string[] arguments)
    {
        if (arguments.Length == 0) return Fail("publish: specify a generated mod input file.");
        List<string> mutable = arguments.ToList();
        string inputsPath = Path.GetFullPath(mutable[0]);
        mutable.RemoveAt(0);
        string? id = ToolsetApp.TakeOption(mutable, "--id");
        string? displayName = ToolsetApp.TakeOption(mutable, "--display-name");
        string? buildDirectoryOption = ToolsetApp.TakeOption(mutable, "--build-directory");
        string? version = ToolsetApp.TakeOption(mutable, "--version");
        string outputRoot = Path.GetFullPath(ToolsetApp.TakeOption(mutable, "-o", "--output") ?? Path.Combine(context.RepositoryRoot, "artifacts", "publish"));
        if (mutable.Count > 0) return Fail($"publish: unknown arguments: {string.Join(' ', mutable)}");
        if (id is null || !SafeSegmentRegex().IsMatch(id)) return Fail("publish: --id must contain only letters, digits, dots, underscores, or hyphens.");
        if (string.IsNullOrWhiteSpace(displayName)) return Fail("publish: --display-name is required.");
        if (buildDirectoryOption is null) return Fail("publish: --build-directory is required.");
        if (version is null || !SafeSegmentRegex().IsMatch(version)) return Fail("publish: --version must contain only letters, digits, dots, underscores, or hyphens.");

        ModProjectInputs inputs = await ModProjectInputs.LoadAsync(inputsPath);
        string buildDirectory = Path.GetFullPath(buildDirectoryOption);
        if (!Directory.Exists(buildDirectory)) return Fail($"Build directory not found: {buildDirectory}");

        string packageRoot = Path.Combine(outputRoot, id, version);
        string workshopRoot = Path.Combine(packageRoot, "workshop", displayName);
        string workshopOverride = Path.Combine(workshopRoot, "override");
        string nexusRoot = Path.Combine(packageRoot, "nexus-stage", displayName);
        string nexusOverride = Path.Combine(nexusRoot, "override");
        Directory.CreateDirectory(workshopOverride);
        Directory.CreateDirectory(nexusOverride);
        CopyTree(buildDirectory, workshopOverride);
        CopyTree(buildDirectory, nexusOverride);

        foreach (string document in inputs.Documents.Distinct(StringComparer.OrdinalIgnoreCase))
        {
            if (!File.Exists(document)) return Fail($"Package document not found: {document}");
            File.Copy(document, Path.Combine(workshopRoot, Path.GetFileName(document)), true);
            File.Copy(document, Path.Combine(nexusRoot, Path.GetFileName(document)), true);
        }

        foreach (string document in new[] { Path.Combine(context.RepositoryRoot, "LICENSE"), Path.Combine(context.RepositoryRoot, "THIRD_PARTY_NOTICES.md") })
        {
            if (!File.Exists(document)) continue;
            File.Copy(document, Path.Combine(workshopRoot, Path.GetFileName(document)), true);
            File.Copy(document, Path.Combine(nexusRoot, Path.GetFileName(document)), true);
        }

        if (inputs.Dependencies.Count > 0)
        {
            string[] dependencyLines = ["Required packages, installed first:", .. inputs.Dependencies.Distinct(StringComparer.OrdinalIgnoreCase).Select((dependency, index) => $"{index + 1}. {dependency}")];
            await File.WriteAllLinesAsync(Path.Combine(workshopRoot, "dependencies.txt"), dependencyLines, new UTF8Encoding(false));
            await File.WriteAllLinesAsync(Path.Combine(nexusRoot, "dependencies.txt"), dependencyLines, new UTF8Encoding(false));
        }

        if (inputs.WorkshopTags.Count > 0) await File.WriteAllLinesAsync(Path.Combine(workshopRoot, "tags.txt"), inputs.WorkshopTags.Distinct(StringComparer.OrdinalIgnoreCase), new UTF8Encoding(false));

        string? workshopManifest = await CreateWorkshopManifestAsync(inputs, packageRoot, workshopRoot, displayName, version);

        string nexusDirectory = Path.Combine(packageRoot, "nexus");
        Directory.CreateDirectory(nexusDirectory);
        string zipPath = Path.Combine(nexusDirectory, $"{id}-{version}.zip");
        if (File.Exists(zipPath)) File.Delete(zipPath);
        ZipFile.CreateFromDirectory(Path.Combine(packageRoot, "nexus-stage"), zipPath, CompressionLevel.Optimal, false);
        Directory.Delete(Path.Combine(packageRoot, "nexus-stage"), true);
        Console.WriteLine($"Workshop package: {workshopRoot}");
        Console.WriteLine(workshopManifest is null ? "Workshop upload manifest: skipped because WorkshopPublishedFileId is not configured." : $"Workshop upload manifest: {workshopManifest}");
        Console.WriteLine($"Nexus package:    {zipPath}");
        return 0;
    }

    private static async Task<string?> CreateWorkshopManifestAsync(ModProjectInputs inputs, string packageRoot, string workshopRoot, string displayName, string version)
    {
        if (string.IsNullOrWhiteSpace(inputs.WorkshopPublishedFileId)) return null;
        if (!ulong.TryParse(inputs.WorkshopAppId, out ulong appId) || appId == 0) throw new InvalidDataException("WorkshopAppId must be a positive integer.");
        if (!ulong.TryParse(inputs.WorkshopPublishedFileId, out ulong publishedFileId) || publishedFileId == 0) throw new InvalidDataException("WorkshopPublishedFileId must be the positive ID of an existing item. The release pipeline never creates Workshop items implicitly.");
        if (!int.TryParse(inputs.WorkshopVisibility, out int visibility) || visibility is < 0 or > 3) throw new InvalidDataException("WorkshopVisibility must be 0 (public), 1 (friends-only), 2 (private), or 3 (unlisted).");
        if (inputs.WorkshopDescriptionFile is null || !File.Exists(inputs.WorkshopDescriptionFile)) throw new FileNotFoundException("Workshop description file was not found.", inputs.WorkshopDescriptionFile);
        if (inputs.WorkshopPreviewFile is null || !File.Exists(inputs.WorkshopPreviewFile)) throw new FileNotFoundException("Workshop preview file was not found.", inputs.WorkshopPreviewFile);
        if (inputs.WorkshopChangeNoteFile is null || !File.Exists(inputs.WorkshopChangeNoteFile)) throw new FileNotFoundException("Workshop change-note file was not found.", inputs.WorkshopChangeNoteFile);
        string extension = Path.GetExtension(inputs.WorkshopPreviewFile).ToLowerInvariant();
        if (extension is not ".png" and not ".jpg" and not ".jpeg" and not ".gif") throw new InvalidDataException("Workshop preview must be a PNG, JPG, or GIF image.");
        if (new FileInfo(inputs.WorkshopPreviewFile).Length >= 1024 * 1024) throw new InvalidDataException("Workshop preview must be smaller than 1 MB.");

        string preview = Path.Combine(packageRoot, "workshop-preview" + extension);
        File.Copy(inputs.WorkshopPreviewFile, preview, true);
        string description = (await File.ReadAllTextAsync(inputs.WorkshopDescriptionFile, Encoding.UTF8)).Trim();
        string changeNote = (await File.ReadAllTextAsync(inputs.WorkshopChangeNoteFile, Encoding.UTF8)).Trim();
        if (string.IsNullOrWhiteSpace(description)) throw new InvalidDataException("Workshop description must not be empty.");
        if (string.IsNullOrWhiteSpace(changeNote)) changeNote = $"Release {version}";

        string manifest = Path.Combine(packageRoot, "steam-workshop.vdf");
        string[] lines = ["\"workshopitem\"", "{", VdfEntry("appid", appId.ToString()), VdfEntry("publishedfileid", publishedFileId.ToString()), VdfEntry("contentfolder", Path.GetFullPath(workshopRoot)), VdfEntry("previewfile", Path.GetFullPath(preview)), VdfEntry("visibility", visibility.ToString()), VdfEntry("title", displayName), VdfEntry("description", description), VdfEntry("changenote", changeNote), "}"];
        await File.WriteAllLinesAsync(manifest, lines, new UTF8Encoding(false));
        return manifest;
    }

    private static string VdfEntry(string key, string value)
    {
        return $"\t\"{EscapeVdf(key)}\"\t\t\"{EscapeVdf(value)}\"";
    }

    private static string EscapeVdf(string value)
    {
        return value.Replace("\\", "\\\\", StringComparison.Ordinal).Replace("\"", "\\\"", StringComparison.Ordinal).Replace("\r\n", "\\n", StringComparison.Ordinal).Replace("\r", "\\n", StringComparison.Ordinal).Replace("\n", "\\n", StringComparison.Ordinal).Replace("\t", "\\t", StringComparison.Ordinal);
    }

    private static void CopyTree(string sourceDirectory, string destinationDirectory)
    {
        foreach (string source in Directory.EnumerateFiles(sourceDirectory, "*", SearchOption.AllDirectories))
        {
            string relative = Path.GetRelativePath(sourceDirectory, source);
            string destination = Path.GetFullPath(Path.Combine(destinationDirectory, relative));
            if (!destination.StartsWith(Path.GetFullPath(destinationDirectory) + Path.DirectorySeparatorChar, StringComparison.OrdinalIgnoreCase)) throw new InvalidOperationException($"Unsafe package path: {destination}");
            Directory.CreateDirectory(Path.GetDirectoryName(destination)!);
            File.Copy(source, destination, true);
        }
    }

    private static int Fail(string message)
    {
        Console.Error.WriteLine(message);
        return 1;
    }

    [GeneratedRegex("^[A-Za-z0-9._-]+$")]
    private static partial Regex SafeSegmentRegex();
}
