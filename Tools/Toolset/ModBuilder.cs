using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;
using System.Text.RegularExpressions;

namespace Memoria.NeverwinterNights.Toolset;

internal static partial class ModBuilder
{
    public static async Task<int> BuildAsync(ProjectContext context, string[] arguments)
    {
        if (arguments.Length == 0) return Fail("build: specify a generated mod input file.");
        List<string> mutable = arguments.ToList();
        string inputsPath = Path.GetFullPath(mutable[0]);
        mutable.RemoveAt(0);
        string? outputOption = ToolsetApp.TakeOption(mutable, "-o", "--output");
        string? layoutsOutputOption = ToolsetApp.TakeOption(mutable, "--layouts-output");
        bool verifyScripts = mutable.RemoveAll(argument => argument.Equals("--skip-verification", StringComparison.OrdinalIgnoreCase)) == 0;
        if (mutable.Count > 0) return Fail($"build: unknown arguments: {string.Join(' ', mutable)}");
        if (outputOption is null) return Fail("build: --output is required.");

        string outputDirectory = Path.GetFullPath(outputOption);
        string? layoutsOutputDirectory = layoutsOutputOption is null ? null : Path.GetFullPath(layoutsOutputOption);
        EnsureArtifactPath(context, outputDirectory);
        if (layoutsOutputDirectory is not null) EnsureArtifactPath(context, layoutsOutputDirectory);
        RecreateDirectory(outputDirectory);
        if (layoutsOutputDirectory is not null) RecreateDirectory(layoutsOutputDirectory);

        ModProjectInputs inputs = await ModProjectInputs.LoadAsync(inputsPath);
        ValidateOwnedInputs(inputs);
        await Publisher.ValidateWorkshopDescriptionAsync(context, inputs);
        await ValidateLocalizationResourcesAsync(inputs.Resources);
        Console.WriteLine($"Building {inputs.ModDisplayName} {inputs.ModVersion}: {ToolsetLog.RepositoryPath(context, inputs.ProjectDirectory!)} -> {ToolsetLog.RepositoryPath(context, outputDirectory)}");
        string[] includeDirectories = (await ApiSnapshotResolver.ResolveIncludeDirectoriesAsync(context, inputs)).Distinct(StringComparer.OrdinalIgnoreCase).ToArray();
        HashSet<string> outputNames = new(StringComparer.OrdinalIgnoreCase);
        int compiled = 0;
        int includes = 0;
        string[] sources = inputs.Sources.Distinct(StringComparer.OrdinalIgnoreCase).Order().ToArray();
        for (int sourceIndex = 0; sourceIndex < sources.Length; sourceIndex++)
        {
            string source = sources[sourceIndex];
            EnsureFileExists(source);
            string text = await File.ReadAllTextAsync(source, new UTF8Encoding(false, true));
            if (!HasEntrypoint(text))
            {
                includes++;
                ToolsetLog.Verbose($"Skipped[{sourceIndex + 1}/{sources.Length}]: {ToolsetLog.RepositoryPath(context, source)} [include]");
                continue;
            }

            string output = ReserveOutput(outputDirectory, Path.GetFileNameWithoutExtension(source) + ".ncs", outputNames);
            string encoding = SelectNwnEncoding(text, source);
            int exitCode = await ToolsetApp.CompileAsync(context, source, output, includeDirectories, encoding, sourceIndex + 1, sources.Length);
            if (exitCode != 0) return exitCode;
            compiled++;
        }

        int gffConverted = 0;
        int resJsonConverted = 0;
        int jsonTextConverted = 0;
        int manifests = 0;
        int copied = 0;
        foreach (string resource in inputs.Resources.Distinct(StringComparer.OrdinalIgnoreCase).Order())
        {
            EnsureFileExists(resource);
            if (IsResJson(resource))
            {
                string output = ReserveOutput(outputDirectory, Path.GetFileNameWithoutExtension(resource) + ".txt", outputNames);
                await ConvertResJsonAsync(resource, output);
                resJsonConverted++;
            }
            else if (IsGffJson(resource))
            {
                string output = ReserveOutput(outputDirectory, Path.GetFileNameWithoutExtension(resource), outputNames);
                int exitCode = await ToolsetApp.GffConvertAsync(context, resource, output, "json", "gff", true);
                if (exitCode != 0) return exitCode;
                gffConverted++;
            }
            else if (IsJsonTextResource(resource))
            {
                string output = ReserveOutput(outputDirectory, Path.GetFileNameWithoutExtension(resource) + ".txt", outputNames);
                if (await ConvertJsonTextResourceAsync(resource, output, inputs)) manifests++;
                jsonTextConverted++;
            }
            else
            {
                CopyPackageFile(resource, ReserveOutput(outputDirectory, Path.GetFileName(resource), outputNames));
                copied++;
            }
        }

        if (manifests != 1) throw new InvalidDataException($"Each mod project must own exactly one *_memoria.json runtime manifest; found {manifests}.");

        foreach (string packageFile in inputs.PackageFiles.Distinct(StringComparer.OrdinalIgnoreCase).Order())
        {
            EnsureFileExists(packageFile);
            CopyPackageFile(packageFile, ReserveOutput(outputDirectory, Path.GetFileName(packageFile), outputNames));
            copied++;
        }

        int layouts = 0;
        if (inputs.Layouts.Count > 0 && layoutsOutputDirectory is null) return Fail("build: --layouts-output is required when the project contains NUI layouts.");
        foreach (string layout in inputs.Layouts.Distinct(StringComparer.OrdinalIgnoreCase).Order())
        {
            EnsureFileExists(layout);
            string layoutOutput = Path.Combine(layoutsOutputDirectory!, Path.GetFileNameWithoutExtension(layout));
            int exitCode = NuiLayoutTool.Run([layout, "-o", layoutOutput], true);
            if (exitCode != 0) return exitCode;
            layouts++;
        }

        int verified = 0;
        if (verifyScripts)
        {
            VerificationResult verification = await ToolsetApp.VerifyNcsAsync(context, outputDirectory);
            if (verification.Failures > 0)
            {
                string failure = verification.Files == 0 ? "no NCS files were produced" : $"NCS verification failed for {verification.Failures} of {verification.Files} files";
                Console.Error.WriteLine($"Failed {inputs.ModDisplayName} {inputs.ModVersion}: {failure}.");
                return 1;
            }
            verified = verification.Files;
        }

        string verificationSummary = verifyScripts ? $"{verified} verified" : "verification skipped";
        Console.WriteLine($"Built {inputs.ModDisplayName} {inputs.ModVersion}: {compiled} compiled, {verificationSummary}, {includes} skipped, {gffConverted} GFF, {resJsonConverted} ResJSON, {jsonTextConverted} JSON, {copied} copied, {layouts} layouts -> {ToolsetLog.RepositoryPath(context, outputDirectory)}");
        return 0;
    }

    private static bool HasEntrypoint(string text)
    {
        string withoutComments = CommentsRegex().Replace(text, string.Empty);
        return EntrypointRegex().IsMatch(withoutComments);
    }

    private static string SelectNwnEncoding(string text, string source)
    {
        if (CanEncode(text, 1252)) return "windows-1252";
        if (CanEncode(text, 1251)) return "windows-1251";
        throw new InvalidDataException($"Text contains characters unsupported by Windows-1252 and Windows-1251: {source}");
    }

    private static bool CanEncode(string text, int codePage)
    {
        try
        {
            Encoding.GetEncoding(codePage, EncoderFallback.ExceptionFallback, DecoderFallback.ExceptionFallback).GetBytes(text);
            return true;
        }
        catch (EncoderFallbackException)
        {
            return false;
        }
    }

    private static bool IsGffJson(string path)
    {
        if (!Path.GetExtension(path).Equals(".json", StringComparison.OrdinalIgnoreCase)) return false;
        string innerExtension = Path.GetExtension(Path.GetFileNameWithoutExtension(path));
        return innerExtension.Length == 4 && innerExtension[1..].All(char.IsLetterOrDigit);
    }

    private static bool IsResJson(string path)
    {
        return Path.GetExtension(path).Equals(".resjson", StringComparison.OrdinalIgnoreCase);
    }

    private static bool IsJsonTextResource(string path)
    {
        return Path.GetExtension(path).Equals(".json", StringComparison.OrdinalIgnoreCase);
    }

    private static async Task ConvertResJsonAsync(string source, string output)
    {
        try
        {
            string text = await File.ReadAllTextAsync(source, new UTF8Encoding(false, true));
            using JsonDocument document = JsonDocument.Parse(text);
            string encodingName = SelectNwnEncoding(text, source);
            Encoding targetEncoding = Encoding.GetEncoding(encodingName, EncoderFallback.ExceptionFallback, DecoderFallback.ExceptionFallback);
            await File.WriteAllTextAsync(output, text, targetEncoding);
            ToolsetLog.Verbose($"Converted ResJSON [{encodingName}]: {source} -> {output}");
        }
        catch (JsonException exception)
        {
            throw new InvalidDataException($"Invalid ResJSON resource: {source}", exception);
        }
    }

    private static async Task ValidateLocalizationResourcesAsync(IEnumerable<string> resources)
    {
        string[] languages = ["en", "de", "es", "fr", "it", "ru"];
        Dictionary<string, Dictionary<string, string>> groups = new(StringComparer.OrdinalIgnoreCase);
        foreach (string resource in resources.Where(IsResJson))
        {
            string stem = Path.GetFileNameWithoutExtension(resource);
            int marker = stem.LastIndexOf("_loc_", StringComparison.OrdinalIgnoreCase);
            if (marker <= 0) continue;
            string language = stem[(marker + 5)..].ToLowerInvariant();
            if (!languages.Contains(language, StringComparer.Ordinal)) continue;
            string group = Path.Combine(Path.GetDirectoryName(resource)!, stem[..marker]);
            if (!groups.TryGetValue(group, out Dictionary<string, string>? files))
            {
                files = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
                groups.Add(group, files);
            }
            files.Add(language, resource);
        }

        foreach ((string group, Dictionary<string, string> files) in groups)
        {
            if (!files.TryGetValue("en", out string? englishPath)) throw new InvalidDataException($"Localization group is missing its English table: {group}");
            JsonObject english = await ReadLocalizationObjectAsync(englishPath);
            HashSet<string> englishKeys = english.Select(entry => entry.Key).ToHashSet(StringComparer.Ordinal);
            foreach ((string language, string localizedPath) in files)
            {
                if (language.Equals("en", StringComparison.OrdinalIgnoreCase)) continue;
                JsonObject localized = await ReadLocalizationObjectAsync(localizedPath);
                HashSet<string> localizedKeys = localized.Select(entry => entry.Key).ToHashSet(StringComparer.Ordinal);
                string[] missing = englishKeys.Except(localizedKeys, StringComparer.Ordinal).Order(StringComparer.Ordinal).ToArray();
                string[] extra = localizedKeys.Except(englishKeys, StringComparer.Ordinal).Order(StringComparer.Ordinal).ToArray();
                if (missing.Length > 0 || extra.Length > 0)
                    throw new InvalidDataException($"Localization keys do not match English table for {localizedPath}. Missing: {string.Join(", ", missing)}. Extra: {string.Join(", ", extra)}.");
            }
        }
    }

    private static async Task<JsonObject> ReadLocalizationObjectAsync(string path)
    {
        string text = await File.ReadAllTextAsync(path, new UTF8Encoding(false, true));
        JsonNode? node = JsonNode.Parse(text);
        if (node is not JsonObject root) throw new InvalidDataException($"Localization resource must contain a JSON object: {path}");
        foreach ((string key, JsonNode? value) in root)
        {
            if (value is not JsonValue jsonValue || !jsonValue.TryGetValue(out string? textValue) || string.IsNullOrWhiteSpace(key) || string.IsNullOrWhiteSpace(textValue))
                throw new InvalidDataException($"Localization entry '{key}' must contain non-empty text: {path}");
        }
        return root;
    }

    private static async Task<bool> ConvertJsonTextResourceAsync(string source, string output, ModProjectInputs inputs)
    {
        try
        {
            string text = await File.ReadAllTextAsync(source, new UTF8Encoding(false, true));
            if (text.Any(character => character > 127)) throw new InvalidDataException($"JSON text resources must contain English ASCII text only: {source}");
            JsonNode? node = JsonNode.Parse(text);
            if (node is not JsonObject root) throw new InvalidDataException($"JSON text resources must contain an object: {source}");
            bool isManifest = Path.GetFileNameWithoutExtension(source).EndsWith("_memoria", StringComparison.OrdinalIgnoreCase);
            if (isManifest)
            {
                if (root["schema"]?.GetValue<int>() != 1) throw new InvalidDataException($"Runtime manifest schema must be 1: {source}");
                string? id = root["id"]?.GetValue<string>();
                if (!string.Equals(id, inputs.ModId, StringComparison.Ordinal)) throw new InvalidDataException($"Runtime manifest id '{id}' does not match project ModId '{inputs.ModId}': {source}");
                root["name"] = inputs.ModDisplayName;
                root["version"] = inputs.ModVersion;
                JsonArray dependencies = [];
                foreach (ModDependency dependency in inputs.Dependencies) dependencies.Add(new JsonObject { ["id"] = dependency.ModId, ["versions"] = dependency.Versions });
                root["dependencies"] = dependencies;
                text = root.ToJsonString(new JsonSerializerOptions { WriteIndented = true }) + Environment.NewLine;
            }
            await File.WriteAllTextAsync(output, text, new UTF8Encoding(false));
            ToolsetLog.Verbose($"Converted JSON text resource: {source} -> {output}");
            return isManifest;
        }
        catch (JsonException exception)
        {
            throw new InvalidDataException($"Invalid JSON text resource: {source}", exception);
        }
    }

    private static void ValidateOwnedInputs(ModProjectInputs inputs)
    {
        foreach (string path in inputs.Sources) EnsureOwnedInput(inputs, path, "NwnSource");
        foreach (string path in inputs.Resources) EnsureOwnedInput(inputs, path, "NwnResource");
        foreach (string path in inputs.Layouts) EnsureOwnedInput(inputs, path, "NwnLayout");
        foreach (string path in inputs.PackageFiles) EnsureOwnedInput(inputs, path, "NwnPackageFile");
        foreach (string path in inputs.Documents) EnsureOwnedInput(inputs, path, "PackageDocument");
    }

    private static void EnsureOwnedInput(ModProjectInputs inputs, string path, string itemType)
    {
        string projectRoot = Path.GetFullPath(inputs.ProjectDirectory!).TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar) + Path.DirectorySeparatorChar;
        string candidate = Path.GetFullPath(path);
        if (!candidate.StartsWith(projectRoot, StringComparison.OrdinalIgnoreCase)) throw new InvalidDataException($"{itemType} must belong to the current mod project. Use NwnRequiredPackage for cross-project compilation dependencies: {path}");
    }

    private static string ReserveOutput(string outputDirectory, string fileName, HashSet<string> outputNames)
    {
        if (!outputNames.Add(fileName)) throw new InvalidDataException($"Multiple project files produce the same override resource: {fileName}");
        return Path.Combine(outputDirectory, fileName);
    }

    private static void CopyPackageFile(string source, string output)
    {
        Directory.CreateDirectory(Path.GetDirectoryName(output)!);
        File.Copy(source, output, true);
        ToolsetLog.Verbose($"Copied: {source} -> {output}");
    }

    private static void EnsureFileExists(string path)
    {
        if (!File.Exists(path)) throw new FileNotFoundException("Project input was not found.", path);
    }

    private static void EnsureArtifactPath(ProjectContext context, string path)
    {
        string artifactsRoot = Path.GetFullPath(Path.Combine(context.RepositoryRoot, "artifacts")) + Path.DirectorySeparatorChar;
        string normalized = Path.GetFullPath(path).TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar) + Path.DirectorySeparatorChar;
        if (!normalized.StartsWith(artifactsRoot, StringComparison.OrdinalIgnoreCase)) throw new InvalidOperationException($"Build output must be inside the artifacts directory: {path}");
    }

    private static void RecreateDirectory(string path)
    {
        if (Directory.Exists(path)) Directory.Delete(path, true);
        Directory.CreateDirectory(path);
    }

    private static int Fail(string message)
    {
        Console.Error.WriteLine(message);
        return 1;
    }

    [GeneratedRegex(@"//[^\r\n]*|/\*.*?\*/", RegexOptions.Singleline)]
    private static partial Regex CommentsRegex();

    [GeneratedRegex(@"\b(?:void\s+main|int\s+StartingConditional)\s*\(")]
    private static partial Regex EntrypointRegex();
}
