using System.IO.Compression;
using System.Text;
using System.Text.RegularExpressions;

namespace Memoria.NeverwinterNights.Toolset;

internal static partial class Publisher
{
    private const int WorkshopDescriptionMaxUtf8Bytes = 7999;

    internal static async Task ValidateWorkshopDescriptionAsync(ProjectContext context, ModProjectInputs inputs)
    {
        if (string.IsNullOrWhiteSpace(inputs.WorkshopPublishedFileId)) return;
        await CreateWorkshopDescriptionAsync(context, inputs, inputs.ModDisplayName!);
    }

    public static async Task<int> PublishAsync(ProjectContext context, string[] arguments)
    {
        if (arguments.Length == 0) return Fail("publish: specify a generated mod input file.");
        List<string> mutable = arguments.ToList();
        string inputsPath = Path.GetFullPath(mutable[0]);
        mutable.RemoveAt(0);
        string? buildDirectoryOption = ToolsetApp.TakeOption(mutable, "--build-directory");
        string outputRoot = Path.GetFullPath(ToolsetApp.TakeOption(mutable, "-o", "--output") ?? Path.Combine(context.RepositoryRoot, "artifacts", "publish"));
        if (mutable.Count > 0) return Fail($"publish: unknown arguments: {string.Join(' ', mutable)}");
        if (buildDirectoryOption is null) return Fail("publish: --build-directory is required.");

        ModProjectInputs inputs = await ModProjectInputs.LoadAsync(inputsPath);
        string id = inputs.ModId!.ToLowerInvariant();
        string displayName = inputs.ModDisplayName!;
        string version = inputs.ModVersion!;
        if (!SafeSegmentRegex().IsMatch(id)) return Fail("publish: ModId must contain only letters, digits, dots, underscores, or hyphens.");
        string buildDirectory = Path.GetFullPath(buildDirectoryOption);
        if (!Directory.Exists(buildDirectory)) return Fail($"Build directory not found: {buildDirectory}");

        string packageRoot = Path.GetFullPath(Path.Combine(outputRoot, id, version));
        string normalizedOutputRoot = outputRoot.TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar) + Path.DirectorySeparatorChar;
        if (!packageRoot.StartsWith(normalizedOutputRoot, StringComparison.OrdinalIgnoreCase)) throw new InvalidOperationException($"Unsafe publish package path: {packageRoot}");
        if (Directory.Exists(packageRoot)) Directory.Delete(packageRoot, true);
        string packageDirectoryName = SanitizeDirectoryName(displayName);
        string workshopRoot = Path.Combine(packageRoot, "workshop", packageDirectoryName);
        string workshopOverride = Path.Combine(workshopRoot, "override");
        string nexusRoot = Path.Combine(packageRoot, "nexus-stage", packageDirectoryName);
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
            string[] dependencyLines = ["Required mods, installed first:", .. inputs.Dependencies.Select((dependency, index) => $"{index + 1}. {dependency.DisplayName}: {dependency.Versions}")];
            await File.WriteAllLinesAsync(Path.Combine(workshopRoot, "dependencies.txt"), dependencyLines, new UTF8Encoding(false));
            await File.WriteAllLinesAsync(Path.Combine(nexusRoot, "dependencies.txt"), dependencyLines, new UTF8Encoding(false));
        }

        if (inputs.WorkshopTags.Count > 0) await File.WriteAllLinesAsync(Path.Combine(workshopRoot, "tags.txt"), inputs.WorkshopTags.Distinct(StringComparer.OrdinalIgnoreCase), new UTF8Encoding(false));

        string? workshopManifest = await CreateWorkshopManifestAsync(context, inputs, packageRoot, workshopRoot, displayName);

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

    private static async Task<string?> CreateWorkshopManifestAsync(ProjectContext context, ModProjectInputs inputs, string packageRoot, string workshopRoot, string displayName)
    {
        if (string.IsNullOrWhiteSpace(inputs.WorkshopPublishedFileId)) return null;
        if (!ulong.TryParse(inputs.WorkshopAppId, out ulong appId) || appId == 0) throw new InvalidDataException("WorkshopAppId must be a positive integer.");
        if (!ulong.TryParse(inputs.WorkshopPublishedFileId, out ulong publishedFileId) || publishedFileId == 0) throw new InvalidDataException("WorkshopPublishedFileId must be the positive ID of an existing item. The release pipeline never creates Workshop items implicitly.");
        string description = await CreateWorkshopDescriptionAsync(context, inputs, displayName);

        string manifest = Path.Combine(packageRoot, "steam-workshop.vdf");
        string[] lines = ["\"workshopitem\"", "{", VdfEntry("appid", appId.ToString()), VdfEntry("publishedfileid", publishedFileId.ToString()), VdfEntry("contentfolder", Path.GetFullPath(workshopRoot)), VdfEntry("title", displayName), VdfEntry("description", description), "}"];
        await File.WriteAllLinesAsync(manifest, lines, new UTF8Encoding(false));
        return manifest;
    }

    private static async Task<string> CreateWorkshopDescriptionAsync(ProjectContext context, ModProjectInputs inputs, string displayName)
    {
        string[] readmes = inputs.Documents.Where(document => Path.GetFileName(document).Equals("README.md", StringComparison.OrdinalIgnoreCase)).Distinct(StringComparer.OrdinalIgnoreCase).ToArray();
        if (readmes.Length != 1) throw new InvalidDataException($"Workshop packaging requires exactly one README.md PackageDocument; found {readmes.Length}.");
        string readmePath = readmes[0];
        string relativeReadmePath = Path.GetRelativePath(context.RepositoryRoot, readmePath);
        if (relativeReadmePath.StartsWith(".." + Path.DirectorySeparatorChar, StringComparison.Ordinal) || Path.IsPathRooted(relativeReadmePath)) throw new InvalidDataException($"README.md must be inside the repository: {readmePath}");
        string readmeUrl = $"https://github.com/{inputs.ApiSnapshotRepository}/blob/main/{string.Join('/', relativeReadmePath.Split(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar).Select(Uri.EscapeDataString))}";
        string description = MarkdownToSteam.Convert(await File.ReadAllTextAsync(readmePath, Encoding.UTF8), readmeUrl);
        int descriptionUtf8Bytes = Encoding.UTF8.GetByteCount(EscapeVdf(description));
        if (descriptionUtf8Bytes > WorkshopDescriptionMaxUtf8Bytes) throw new InvalidDataException($"Workshop description for {displayName} is {descriptionUtf8Bytes} UTF-8 bytes; Steam allows at most {WorkshopDescriptionMaxUtf8Bytes} bytes plus the terminating null byte.");
        return description;
    }

    private static string VdfEntry(string key, string value)
    {
        return $"\t\"{EscapeVdf(key)}\"\t\t\"{EscapeVdf(value)}\"";
    }

    private static string EscapeVdf(string value)
    {
        // SteamCMD does not enable KeyValues escape sequences for Workshop manifests, so \" would terminate the quoted token instead of escaping it.
        // Keep real line breaks in descriptions and replace embedded quotes with their display-safe Unicode equivalent.
        return value.Replace("\\", "\\\\", StringComparison.Ordinal).Replace("\"", "\uFF02", StringComparison.Ordinal).Replace("\t", "    ", StringComparison.Ordinal);
    }

    private static string SanitizeDirectoryName(string value)
    {
        string result = InvalidFileNameCharactersRegex().Replace(value, " - ");
        result = WhitespaceRegex().Replace(result, " ").Trim().TrimEnd('.');
        if (result.Length == 0) throw new InvalidDataException("Mod display name does not contain a valid directory name.");
        if (ReservedDeviceNameRegex().IsMatch(result)) result = "_" + result;
        return result;
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

    [GeneratedRegex("[<>:\"/\\\\|?*\\x00-\\x1F]+")]
    private static partial Regex InvalidFileNameCharactersRegex();

    [GeneratedRegex("\\s+")]
    private static partial Regex WhitespaceRegex();

    [GeneratedRegex("^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(?:\\.|$)", RegexOptions.IgnoreCase)]
    private static partial Regex ReservedDeviceNameRegex();
}
