using System.Text;

namespace Memoria.NeverwinterNights.Toolset;

internal static class ToolsetApp
{
    public static async Task<int> RunAsync(string[] arguments)
    {
        Console.OutputEncoding = Encoding.UTF8;
        Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);
        List<string> commandLine = arguments.ToList();
        bool verbose = commandLine.RemoveAll(argument => argument.Equals("--verbose", StringComparison.OrdinalIgnoreCase)) > 0;
        ToolsetLog.Configure(verbose);
        arguments = commandLine.ToArray();
        if (arguments.Length == 0 || arguments[0] is "help" or "--help" or "-h")
        {
            PrintHelp();
            return 0;
        }

        try
        {
            ProjectContext context = ProjectContext.Load();
            string command = arguments[0].ToLowerInvariant();
            string[] tail = arguments.Skip(1).ToArray();
            return command switch
            {
                "doctor" => await DoctorAsync(context),
                "compile" => await CompileCommandAsync(context, tail),
                "build" => await ModBuilder.BuildAsync(context, tail),
                "merge-output" => await CommonOutputMerger.MergeAsync(context, tail),
                "verify" => await VerifyAsync(context, tail),
                "gff-to-json" => await GffCommandAsync(context, tail, "gff", "json"),
                "gff-from-json" => await GffCommandAsync(context, tail, "json", "gff"),
                "nui-layout" => NuiLayoutTool.Run(tail),
                "aoe-sim" => AoeSimulator.Run(tail),
                "publish" => await Publisher.PublishAsync(context, tail),
                _ => Fail($"Unknown command: {arguments[0]}. Use help.")
            };
        }
        catch (Exception exception)
        {
            Console.Error.WriteLine($"Error: {exception.Message}");
            return 1;
        }
    }

    private static async Task<int> DoctorAsync(ProjectContext context)
    {
        Console.WriteLine($"Repository: {context.RepositoryRoot}");
        Console.WriteLine($"Compiler:   {context.Tool("nwn_script_comp")}");
        Console.WriteLine($"Includes:   {context.IncludeDirectory} [{Status(Directory.Exists(context.IncludeDirectory))}]");
        foreach (string tool in Directory.EnumerateFiles(context.ToolsDirectory, "*.exe").OrderBy(Path.GetFileName))
        {
            ToolResult version = await ToolRunner.CaptureAsync(tool, ["--version"]);
            string versionLine = version.StandardOutput.Split(['\r', '\n'], StringSplitOptions.RemoveEmptyEntries).LastOrDefault(line => line.StartsWith("neverwinter ", StringComparison.OrdinalIgnoreCase)) ?? $"exit {version.ExitCode}";
            Console.WriteLine($"{Path.GetFileName(tool),-24} {versionLine}");
        }

        return 0;
    }

    private static async Task<int> CompileCommandAsync(ProjectContext context, string[] arguments)
    {
        if (arguments.Length == 0) return Fail("compile: specify a source .nss file.");
        List<string> mutable = arguments.ToList();
        string source = Path.GetFullPath(mutable[0]);
        mutable.RemoveAt(0);
        string output = Path.GetFullPath(TakeOption(mutable, "-o", "--output") ?? Path.ChangeExtension(source, ".ncs"));
        string encoding = TakeOption(mutable, "--encoding") ?? "windows-1252";
        string[] includes = SplitPaths(TakeOption(mutable, "--includes")).Select(Path.GetFullPath).ToArray();
        if (mutable.Count > 0) return Fail($"compile: unknown arguments: {string.Join(' ', mutable)}");
        return await CompileAsync(context, source, output, includes, encoding);
    }

    internal static async Task<int> CompileAsync(ProjectContext context, string source, string output, IReadOnlyCollection<string> includeDirectories, string encodingName, int? progress = null, int? total = null)
    {
        if (!File.Exists(source)) return Fail($"Source file not found: {source}");
        Directory.CreateDirectory(Path.GetDirectoryName(output)!);
        string compilerSource = source;
        string? temporaryDirectory = null;
        try
        {
            if (!encodingName.Equals("utf-8", StringComparison.OrdinalIgnoreCase) && !encodingName.Equals("utf8", StringComparison.OrdinalIgnoreCase))
            {
                Encoding targetEncoding = Encoding.GetEncoding(encodingName, EncoderFallback.ExceptionFallback, DecoderFallback.ExceptionFallback);
                temporaryDirectory = Path.Combine(Path.GetTempPath(), "memoria-neverwinter-nights-toolset-" + Guid.NewGuid().ToString("N"));
                Directory.CreateDirectory(temporaryDirectory);
                compilerSource = Path.Combine(temporaryDirectory, Path.GetFileName(source));
                await File.WriteAllTextAsync(compilerSource, await File.ReadAllTextAsync(source, Encoding.UTF8), targetEncoding);
            }

            string[] effectiveIncludes = includeDirectories.Prepend(Path.GetDirectoryName(source)!).Append(context.IncludeDirectory).Distinct(StringComparer.OrdinalIgnoreCase).ToArray();
            List<string> toolArguments = [.. context.ResManArguments(), "--quiet", "--dirs", string.Join(',', effectiveIncludes), "--nwn-encoding", encodingName, "-o", output, compilerSource];
            ToolResult result = await ToolRunner.CaptureAsync(context.Tool("nwn_script_comp"), toolArguments, Path.GetDirectoryName(source));
            if (result.ExitCode == 0)
            {
                string counter = progress.HasValue && total.HasValue ? $"[{progress}/{total}]" : string.Empty;
                string encoding = encodingName.Equals("windows-1252", StringComparison.OrdinalIgnoreCase) ? string.Empty : $" [{encodingName}]";
                string message = $"Compiled{counter}: {ToolsetLog.RepositoryPath(context, source)} -> {ToolsetLog.RepositoryPath(context, output)}{encoding}";
                if (progress.HasValue) ToolsetLog.Verbose(message);
                else Console.WriteLine(message);
            }
            else
            {
                WriteCompilerErrors(result, source, effectiveIncludes);
                string counter = progress.HasValue && total.HasValue ? $"[{progress}/{total}]" : string.Empty;
                Console.Error.WriteLine($"Failed{counter}: {ToolsetLog.RepositoryPath(context, source)} -> {ToolsetLog.RepositoryPath(context, output)}");
            }

            return result.ExitCode;
        }
        finally
        {
            if (temporaryDirectory is not null && Directory.Exists(temporaryDirectory)) Directory.Delete(temporaryDirectory, true);
        }
    }

    private static void WriteCompilerErrors(ToolResult result, string source, IReadOnlyCollection<string> includeDirectories)
    {
        bool wroteError = false;
        foreach (string line in result.StandardOutput.Split(['\r', '\n'], StringSplitOptions.RemoveEmptyEntries).Concat(result.StandardError.Split(['\r', '\n'], StringSplitOptions.RemoveEmptyEntries)))
        {
            const string marker = "): ERROR: ";
            int markerIndex = line.IndexOf(marker, StringComparison.OrdinalIgnoreCase);
            int openingParenthesis = markerIndex < 0 ? -1 : line.LastIndexOf('(', markerIndex);
            if (openingParenthesis < 0 || !int.TryParse(line.AsSpan(openingParenthesis + 1, markerIndex - openingParenthesis - 1), out int lineNumber)) continue;
            int fileSeparator = line.LastIndexOf(": ", openingParenthesis, StringComparison.Ordinal);
            string reportedFile = line[(fileSeparator < 0 ? 0 : fileSeparator + 2)..openingParenthesis].Trim();
            string diagnosticFile = ResolveCompilerDiagnosticFile(reportedFile, source, includeDirectories);
            Console.Error.WriteLine($"{diagnosticFile}({lineNumber}): ERROR: {line[(markerIndex + marker.Length)..].Trim()}");
            wroteError = true;
        }

        if (wroteError) return;
        Console.Write(result.StandardOutput);
        Console.Error.Write(result.StandardError);
    }

    private static string ResolveCompilerDiagnosticFile(string reportedFile, string source, IReadOnlyCollection<string> includeDirectories)
    {
        if (Path.GetFileName(source).Equals(reportedFile, StringComparison.OrdinalIgnoreCase)) return source;
        if (Path.IsPathFullyQualified(reportedFile) && File.Exists(reportedFile)) return Path.GetFullPath(reportedFile);
        foreach (string directory in includeDirectories)
        {
            string candidate = Path.GetFullPath(Path.Combine(directory, reportedFile));
            if (File.Exists(candidate)) return candidate;
        }

        return reportedFile;
    }

    private static async Task<int> VerifyAsync(ProjectContext context, string[] arguments)
    {
        if (arguments.Length != 1) return Fail("verify: specify an .ncs file or directory.");
        string path = Path.GetFullPath(arguments[0]);
        string[] files = File.Exists(path) ? [path] : Directory.Exists(path) ? Directory.GetFiles(path, "*.ncs", SearchOption.AllDirectories) : [];
        if (files.Length == 0) return Fail($"No NCS files found: {path}");
        int failures = 0;
        foreach (string file in files.Order())
        {
            ToolResult result = await ToolRunner.CaptureAsync(context.Tool("nwn_asm"), ["--silent", "--no-color", "--term-width", "0", .. context.ResManArguments(), "--dirs", context.IncludeDirectory, "-d", file]);
            if (result.ExitCode == 0) ToolsetLog.Verbose($"Verified: {ToolsetLog.RepositoryPath(context, file)}");
            else
            {
                failures++;
                Console.Error.WriteLine($"ERR {file}: {result.StandardError.Trim()}");
            }
        }

        Console.WriteLine($"Verified: {files.Length}; failures: {failures}.");
        return failures == 0 ? 0 : 1;
    }

    private static async Task<int> GffCommandAsync(ProjectContext context, string[] arguments, string inputFormat, string outputFormat)
    {
        if (arguments.Length != 2) return Fail($"gff-{(outputFormat == "json" ? "to-json" : "from-json")}: specify input and output files.");
        return await GffConvertAsync(context, Path.GetFullPath(arguments[0]), Path.GetFullPath(arguments[1]), inputFormat, outputFormat);
    }

    internal static async Task<int> GffConvertAsync(ProjectContext context, string input, string output, string inputFormat, string outputFormat, bool verboseOnly = false)
    {
        Directory.CreateDirectory(Path.GetDirectoryName(output)!);
        List<string> toolArguments = ["-i", input, "-l", inputFormat, "-o", output, "-k", outputFormat, "--other-encoding", "utf-8"];
        if (outputFormat == "json") toolArguments.Add("--pretty");
        ToolResult result = await ToolRunner.CaptureAsync(context.Tool("nwn_gff"), toolArguments);
        if (result.ExitCode == 0)
        {
            string message = $"Converted GFF: {ToolsetLog.RepositoryPath(context, input)} -> {ToolsetLog.RepositoryPath(context, output)}";
            if (verboseOnly) ToolsetLog.Verbose(message);
            else Console.WriteLine(message);
        }
        else
        {
            Console.Write(result.StandardOutput);
            Console.Error.Write(result.StandardError);
        }
        return result.ExitCode;
    }

    internal static string? TakeOption(List<string> arguments, params string[] names)
    {
        for (int index = 0; index < arguments.Count; index++)
        {
            if (!names.Contains(arguments[index], StringComparer.OrdinalIgnoreCase)) continue;
            if (index + 1 >= arguments.Count) throw new ArgumentException($"{arguments[index]} requires a value.");
            string value = arguments[index + 1];
            arguments.RemoveRange(index, 2);
            return value;
        }

        return null;
    }

    private static string[] SplitPaths(string? paths)
    {
        return paths?.Split([',', ';'], StringSplitOptions.TrimEntries | StringSplitOptions.RemoveEmptyEntries) ?? [];
    }

    private static string Status(bool exists)
    {
        return exists ? "OK" : "MISSING";
    }

    private static int Fail(string message)
    {
        Console.Error.WriteLine(message);
        return 1;
    }

    private static void PrintHelp()
    {
        Console.WriteLine("Memoria Toolset");
        Console.WriteLine();
        Console.WriteLine("  [--verbose] doctor");
        Console.WriteLine("  [--verbose] compile <source.nss> [-o output.ncs] [--includes dir1,dir2] [--encoding utf-8|windows-1251|windows-1252]");
        Console.WriteLine("  build <generated-inputs> --output directory [--layouts-output directory]");
        Console.WriteLine("  merge-output <source-directory> --output directory --manifests directory --lock-file file --owner name");
        Console.WriteLine("  verify <file.ncs|directory>");
        Console.WriteLine("  gff-to-json <input> <output.json>");
        Console.WriteLine("  gff-from-json <input.json> <output>");
        Console.WriteLine("  nui-layout <layout.json> [-o output-directory]");
        Console.WriteLine("  aoe-sim <output.json>");
        Console.WriteLine("  publish <generated-inputs> --build-directory directory [-o output-directory]");
    }
}
