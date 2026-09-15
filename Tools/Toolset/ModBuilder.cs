using System.Text;
using System.Text.Json;
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
        if (mutable.Count > 0) return Fail($"build: unknown arguments: {string.Join(' ', mutable)}");
        if (outputOption is null) return Fail("build: --output is required.");

        string outputDirectory = Path.GetFullPath(outputOption);
        string? layoutsOutputDirectory = layoutsOutputOption is null ? null : Path.GetFullPath(layoutsOutputOption);
        EnsureArtifactPath(context, outputDirectory);
        if (layoutsOutputDirectory is not null) EnsureArtifactPath(context, layoutsOutputDirectory);
        RecreateDirectory(outputDirectory);
        if (layoutsOutputDirectory is not null) RecreateDirectory(layoutsOutputDirectory);

        ModProjectInputs inputs = await ModProjectInputs.LoadAsync(inputsPath);
        string[] includeDirectories = inputs.IncludeDirectories.Distinct(StringComparer.OrdinalIgnoreCase).ToArray();
        HashSet<string> outputNames = new(StringComparer.OrdinalIgnoreCase);
        int compiled = 0;
        int includes = 0;
        foreach (string source in inputs.Sources.Distinct(StringComparer.OrdinalIgnoreCase).Order())
        {
            EnsureFileExists(source);
            string text = await File.ReadAllTextAsync(source, new UTF8Encoding(false, true));
            if (!HasEntrypoint(text))
            {
                includes++;
                continue;
            }

            string output = ReserveOutput(outputDirectory, Path.GetFileNameWithoutExtension(source) + ".ncs", outputNames);
            string encoding = SelectNwnEncoding(text, source);
            int exitCode = await ToolsetApp.CompileAsync(context, source, output, includeDirectories, encoding);
            if (exitCode != 0) return exitCode;
            compiled++;
        }

        int gffConverted = 0;
        int resJsonConverted = 0;
        int jsonTextConverted = 0;
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
                int exitCode = await ToolsetApp.GffConvertAsync(context, resource, output, "json", "gff");
                if (exitCode != 0) return exitCode;
                gffConverted++;
            }
            else if (IsJsonTextResource(resource))
            {
                string output = ReserveOutput(outputDirectory, Path.GetFileNameWithoutExtension(resource) + ".txt", outputNames);
                await ConvertJsonTextResourceAsync(resource, output);
                jsonTextConverted++;
            }
            else
            {
                CopyPackageFile(resource, ReserveOutput(outputDirectory, Path.GetFileName(resource), outputNames));
                copied++;
            }
        }

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
            int exitCode = NuiLayoutTool.Run([layout, "-o", layoutOutput]);
            if (exitCode != 0) return exitCode;
            layouts++;
        }

        Console.WriteLine($"Mod build completed: {compiled} scripts, {includes} includes, {gffConverted} GFF resources, {resJsonConverted} ResJSON resources, {jsonTextConverted} JSON text resources, {copied} copied files, {layouts} layouts.");
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
            Console.WriteLine($"Converted ResJSON [{encodingName}]: {source} -> {output}");
        }
        catch (JsonException exception)
        {
            throw new InvalidDataException($"Invalid ResJSON resource: {source}", exception);
        }
    }

    private static async Task ConvertJsonTextResourceAsync(string source, string output)
    {
        try
        {
            string text = await File.ReadAllTextAsync(source, new UTF8Encoding(false, true));
            using JsonDocument document = JsonDocument.Parse(text);
            if (text.Any(character => character > 127)) throw new InvalidDataException($"JSON text resources must contain English ASCII text only: {source}");
            await File.WriteAllTextAsync(output, text, new UTF8Encoding(false));
            Console.WriteLine($"Converted JSON text resource: {source} -> {output}");
        }
        catch (JsonException exception)
        {
            throw new InvalidDataException($"Invalid JSON text resource: {source}", exception);
        }
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
        Console.WriteLine($"Copied: {source} -> {output}");
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
