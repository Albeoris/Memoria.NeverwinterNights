using System.Diagnostics;
using System.IO.Compression;
using System.Net;

namespace Memoria.NeverwinterNights.Toolset;

internal static class ApiSnapshotResolver
{
    private static readonly HttpClient Client = CreateClient();

    public static async Task<IReadOnlyList<string>> ResolveIncludeDirectoriesAsync(ProjectContext context, ModProjectInputs inputs)
    {
        List<string> includeDirectories = [.. inputs.IncludeDirectories];
        foreach (ModDependency dependency in inputs.Dependencies)
        {
            string sourceDirectory;
            if (dependency.MinimumVersion == dependency.CurrentVersion)
            {
                sourceDirectory = Path.Combine(Path.GetDirectoryName(dependency.ProjectPath)!, "source");
                if (!Directory.Exists(sourceDirectory)) throw new DirectoryNotFoundException($"Dependency source directory was not found: {sourceDirectory}");
                Console.WriteLine($"API source [{dependency.ModId} {dependency.MinimumVersion.ToString(3)}]: local project");
            }
            else
            {
                sourceDirectory = await ResolveSnapshotAsync(context, inputs.ApiSnapshotRepository!, dependency);
            }

            includeDirectories.Add(sourceDirectory);
        }

        return includeDirectories;
    }

    private static async Task<string> ResolveSnapshotAsync(ProjectContext context, string repository, ModDependency dependency)
    {
        ValidateRepository(repository);
        ValidateSafeSegment(dependency.ModId, "dependency ModId");
        string version = dependency.MinimumVersion.ToString(3);
        string tag = $"api-{dependency.ModId.ToLowerInvariant()}-v{version}";
        string modCacheDirectory = Path.Combine(context.ApiCacheDirectory, dependency.ModId.ToLowerInvariant());
        string versionDirectory = Path.Combine(modCacheDirectory, version);
        string sourceDirectory = Path.Combine(versionDirectory, "source");
        string marker = Marker(repository, tag, dependency.ProjectPath, context.RepositoryRoot);
        if (IsComplete(versionDirectory, sourceDirectory, marker))
        {
            Console.WriteLine($"API source [{dependency.ModId} {version}]: cache");
            return sourceDirectory;
        }

        Directory.CreateDirectory(Path.Combine(context.ApiCacheDirectory, ".locks"));
        string lockPath = Path.Combine(context.ApiCacheDirectory, ".locks", $"{dependency.ModId.ToLowerInvariant()}-{version}.lock");
        await using FileStream cacheLock = await AcquireLockAsync(lockPath);
        if (IsComplete(versionDirectory, sourceDirectory, marker))
        {
            Console.WriteLine($"API source [{dependency.ModId} {version}]: cache");
            return sourceDirectory;
        }

        if (Directory.Exists(versionDirectory)) Directory.Delete(versionDirectory, true);
        Directory.CreateDirectory(modCacheDirectory);
        string stagingDirectory = Path.Combine(modCacheDirectory, $".download-{version}-{Guid.NewGuid():N}");
        Directory.CreateDirectory(stagingDirectory);
        try
        {
            await DownloadSnapshotAsync(repository, tag, dependency, context.RepositoryRoot, stagingDirectory);
            await File.WriteAllTextAsync(Path.Combine(stagingDirectory, ".complete"), marker);
            Directory.Move(stagingDirectory, versionDirectory);
        }
        catch
        {
            if (Directory.Exists(stagingDirectory)) Directory.Delete(stagingDirectory, true);
            throw;
        }

        Console.WriteLine($"API source [{dependency.ModId} {version}]: downloaded tag {tag}");
        return sourceDirectory;
    }

    private static async Task DownloadSnapshotAsync(string repository, string tag, ModDependency dependency, string repositoryRoot, string stagingDirectory)
    {
        string url = $"https://github.com/{repository}/archive/refs/tags/{Uri.EscapeDataString(tag)}.zip";
        string archivePath = Path.Combine(stagingDirectory, "snapshot.zip");
        using (HttpResponseMessage response = await Client.GetAsync(url, HttpCompletionOption.ResponseHeadersRead))
        {
            if (response.StatusCode == HttpStatusCode.NotFound) throw new InvalidDataException($"API snapshot tag '{tag}' does not exist in GitHub repository {repository}.");
            if (!response.IsSuccessStatusCode) throw new HttpRequestException($"Failed to download API snapshot tag '{tag}' from {repository}: HTTP {(int)response.StatusCode} {response.ReasonPhrase}.");
            await using Stream content = await response.Content.ReadAsStreamAsync();
            await using FileStream archiveFile = new(archivePath, FileMode.CreateNew, FileAccess.Write, FileShare.None);
            await content.CopyToAsync(archiveFile);
        }

        string projectRelativePath = Path.GetRelativePath(repositoryRoot, dependency.ProjectPath).Replace(Path.DirectorySeparatorChar, '/');
        if (projectRelativePath.StartsWith("../", StringComparison.Ordinal) || Path.IsPathFullyQualified(projectRelativePath)) throw new InvalidDataException($"Dependency project must belong to the current repository: {dependency.ProjectPath}");
        using (ZipArchive archive = ZipFile.OpenRead(archivePath))
        {
            ZipArchiveEntry? projectEntry = archive.Entries.SingleOrDefault(entry => entry.FullName.Equals(projectRelativePath, StringComparison.OrdinalIgnoreCase) || entry.FullName.EndsWith('/' + projectRelativePath, StringComparison.OrdinalIgnoreCase));
            if (projectEntry is null) throw new InvalidDataException($"API snapshot tag '{tag}' does not contain dependency project {projectRelativePath}.");
            string archivePrefix = projectEntry.FullName[..^projectRelativePath.Length];
            string temporaryProject = Path.Combine(stagingDirectory, "dependency.proj");
            await using (Stream projectSource = projectEntry.Open())
            await using (FileStream projectTarget = new(temporaryProject, FileMode.CreateNew, FileAccess.Write, FileShare.None))
            {
                await projectSource.CopyToAsync(projectTarget);
            }

            (string snapshotModId, string snapshotVersion, _) = ModDependency.ReadProjectIdentity(temporaryProject);
            if (!string.Equals(snapshotModId, dependency.ModId, StringComparison.Ordinal)) throw new InvalidDataException($"API snapshot tag '{tag}' has ModId '{snapshotModId}', expected '{dependency.ModId}'.");
            if (!string.Equals(snapshotVersion, dependency.MinimumVersion.ToString(3), StringComparison.Ordinal)) throw new InvalidDataException($"API snapshot tag '{tag}' has Version '{snapshotVersion}', expected '{dependency.MinimumVersion.ToString(3)}'.");
            File.Delete(temporaryProject);

            string projectDirectory = projectRelativePath[..projectRelativePath.LastIndexOf('/')];
            string sourcePrefix = archivePrefix + projectDirectory + "/source/";
            ZipArchiveEntry[] sources = archive.Entries.Where(entry => entry.FullName.StartsWith(sourcePrefix, StringComparison.OrdinalIgnoreCase) && entry.Name.Length > 0 && Path.GetExtension(entry.Name).Equals(".nss", StringComparison.OrdinalIgnoreCase)).ToArray();
            if (sources.Length == 0) throw new InvalidDataException($"API snapshot tag '{tag}' contains no NWScript sources beneath {projectDirectory}/source.");
            string sourceDirectory = Path.Combine(stagingDirectory, "source");
            Directory.CreateDirectory(sourceDirectory);
            string normalizedSourceDirectory = Path.GetFullPath(sourceDirectory) + Path.DirectorySeparatorChar;
            foreach (ZipArchiveEntry source in sources)
            {
                string relativePath = source.FullName[sourcePrefix.Length..].Replace('/', Path.DirectorySeparatorChar);
                string destination = Path.GetFullPath(Path.Combine(sourceDirectory, relativePath));
                if (!destination.StartsWith(normalizedSourceDirectory, StringComparison.OrdinalIgnoreCase)) throw new InvalidDataException($"Unsafe path in API snapshot tag '{tag}': {source.FullName}");
                Directory.CreateDirectory(Path.GetDirectoryName(destination)!);
                await using Stream input = source.Open();
                await using FileStream output = new(destination, FileMode.CreateNew, FileAccess.Write, FileShare.None);
                await input.CopyToAsync(output);
            }
        }

        File.Delete(archivePath);
    }

    private static async Task<FileStream> AcquireLockAsync(string path)
    {
        Stopwatch timeout = Stopwatch.StartNew();
        while (true)
        {
            try
            {
                return new FileStream(path, FileMode.OpenOrCreate, FileAccess.ReadWrite, FileShare.None);
            }
            catch (IOException) when (timeout.Elapsed < TimeSpan.FromMinutes(2))
            {
                await Task.Delay(100);
            }
        }
    }

    private static bool IsComplete(string versionDirectory, string sourceDirectory, string marker)
    {
        string markerPath = Path.Combine(versionDirectory, ".complete");
        return File.Exists(markerPath) && Directory.Exists(sourceDirectory) && Directory.EnumerateFiles(sourceDirectory, "*.nss", SearchOption.AllDirectories).Any() && string.Equals(File.ReadAllText(markerPath), marker, StringComparison.Ordinal);
    }

    private static string Marker(string repository, string tag, string projectPath, string repositoryRoot)
    {
        return $"repository={repository}\ntag={tag}\nproject={Path.GetRelativePath(repositoryRoot, projectPath).Replace(Path.DirectorySeparatorChar, '/')}\n";
    }

    private static void ValidateRepository(string repository)
    {
        string[] parts = repository.Split('/');
        if (parts.Length != 2 || parts.Any(part => part.Length == 0 || part.Any(character => !char.IsLetterOrDigit(character) && character is not '.' and not '_' and not '-'))) throw new InvalidDataException($"Invalid GitHub API snapshot repository '{repository}'; expected owner/name.");
    }

    private static void ValidateSafeSegment(string value, string description)
    {
        if (value.Length == 0 || value.Any(character => !char.IsLetterOrDigit(character) && character is not '.' and not '_' and not '-')) throw new InvalidDataException($"Invalid {description} '{value}'.");
    }

    private static HttpClient CreateClient()
    {
        HttpClient client = new() { Timeout = TimeSpan.FromMinutes(5) };
        client.DefaultRequestHeaders.UserAgent.ParseAdd("Memoria.NeverwinterNights.Toolset/1.0");
        return client;
    }
}
