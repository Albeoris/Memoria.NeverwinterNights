using System.Text;
using System.Text.RegularExpressions;

namespace Memoria.NeverwinterNights.Toolset;

internal static partial class CommonOutputMerger
{
    public static async Task<int> MergeAsync(ProjectContext context, string[] arguments)
    {
        if (arguments.Length == 0) return Fail("merge-output: specify a source directory.");
        List<string> mutable = arguments.ToList();
        string sourceDirectory = Path.GetFullPath(mutable[0]);
        mutable.RemoveAt(0);
        string? outputOption = ToolsetApp.TakeOption(mutable, "-o", "--output");
        string? manifestsOption = ToolsetApp.TakeOption(mutable, "--manifests");
        string? lockFileOption = ToolsetApp.TakeOption(mutable, "--lock-file");
        string? owner = ToolsetApp.TakeOption(mutable, "--owner");
        if (mutable.Count > 0) return Fail($"merge-output: unknown arguments: {string.Join(' ', mutable)}");
        if (!Directory.Exists(sourceDirectory)) return Fail($"Merge source directory not found: {sourceDirectory}");
        if (outputOption is null) return Fail("merge-output: --output is required.");
        if (manifestsOption is null) return Fail("merge-output: --manifests is required.");
        if (lockFileOption is null) return Fail("merge-output: --lock-file is required.");
        if (owner is null || !SafeSegmentRegex().IsMatch(owner)) return Fail("merge-output: --owner must contain only letters, digits, dots, underscores, or hyphens.");

        string outputDirectory = Path.GetFullPath(outputOption);
        string manifestsDirectory = Path.GetFullPath(manifestsOption);
        string lockFile = Path.GetFullPath(lockFileOption);
        EnsureArtifactPath(context, outputDirectory);
        EnsureArtifactPath(context, manifestsDirectory);
        EnsureArtifactPath(context, lockFile);
        Directory.CreateDirectory(outputDirectory);
        Directory.CreateDirectory(manifestsDirectory);
        Directory.CreateDirectory(Path.GetDirectoryName(lockFile)!);

        using FileStream outputLock = await AcquireLockAsync(lockFile);
        Dictionary<string, string> ownedPaths = LoadOwnedPaths(manifestsDirectory, owner);
        string[] sourceFiles = Directory.EnumerateFiles(sourceDirectory, "*", SearchOption.AllDirectories).Order().ToArray();
        foreach (string sourceFile in sourceFiles)
        {
            string relativePath = Path.GetRelativePath(sourceDirectory, sourceFile);
            if (ownedPaths.TryGetValue(relativePath, out string? existingOwner)) return Fail($"Common output collision: {relativePath} is produced by both {existingOwner} and {owner}.");
        }

        foreach (string sourceFile in sourceFiles)
        {
            string relativePath = Path.GetRelativePath(sourceDirectory, sourceFile);
            string destination = Path.GetFullPath(Path.Combine(outputDirectory, relativePath));
            EnsureChildPath(outputDirectory, destination);
            Directory.CreateDirectory(Path.GetDirectoryName(destination)!);
            File.Copy(sourceFile, destination, true);
        }

        await File.WriteAllLinesAsync(Path.Combine(manifestsDirectory, owner + ".inputs"), sourceFiles.Select(sourceFile => Path.GetRelativePath(sourceDirectory, sourceFile)), new UTF8Encoding(false));
        Console.WriteLine($"Common output: merged {sourceFiles.Length} files from {owner} into {outputDirectory}.");
        return 0;
    }

    private static Dictionary<string, string> LoadOwnedPaths(string manifestsDirectory, string currentOwner)
    {
        Dictionary<string, string> ownedPaths = new(StringComparer.OrdinalIgnoreCase);
        foreach (string manifest in Directory.EnumerateFiles(manifestsDirectory, "*.inputs").Order())
        {
            string owner = Path.GetFileNameWithoutExtension(manifest);
            if (owner.Equals(currentOwner, StringComparison.OrdinalIgnoreCase)) continue;
            foreach (string relativePath in File.ReadLines(manifest))
            {
                if (!ownedPaths.TryAdd(relativePath, owner)) throw new InvalidDataException($"Common output manifests assign {relativePath} to both {ownedPaths[relativePath]} and {owner}.");
            }
        }

        return ownedPaths;
    }

    private static async Task<FileStream> AcquireLockAsync(string lockFile)
    {
        DateTime deadline = DateTime.UtcNow.AddMinutes(1);
        while (true)
        {
            try
            {
                return new FileStream(lockFile, FileMode.OpenOrCreate, FileAccess.ReadWrite, FileShare.None);
            }
            catch (IOException) when (DateTime.UtcNow < deadline)
            {
                await Task.Delay(50);
            }
        }
    }

    private static void EnsureArtifactPath(ProjectContext context, string path)
    {
        string artifactsRoot = Path.GetFullPath(Path.Combine(context.RepositoryRoot, "artifacts")) + Path.DirectorySeparatorChar;
        string normalized = Path.GetFullPath(path).TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar) + Path.DirectorySeparatorChar;
        if (!normalized.StartsWith(artifactsRoot, StringComparison.OrdinalIgnoreCase)) throw new InvalidOperationException($"Common output paths must be inside the artifacts directory: {path}");
    }

    private static void EnsureChildPath(string parent, string child)
    {
        string normalizedParent = Path.GetFullPath(parent).TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar) + Path.DirectorySeparatorChar;
        if (!child.StartsWith(normalizedParent, StringComparison.OrdinalIgnoreCase)) throw new InvalidOperationException($"Unsafe common output path: {child}");
    }

    private static int Fail(string message)
    {
        Console.Error.WriteLine(message);
        return 1;
    }

    [GeneratedRegex("^[A-Za-z0-9._-]+$")]
    private static partial Regex SafeSegmentRegex();
}
