namespace Memoria.NeverwinterNights.Toolset;

internal sealed class ProjectContext
{
    public string RepositoryRoot { get; }
    public string ToolsDirectory => Path.Combine(RepositoryRoot, "Tools", "NeverwinterNim");
    public string IncludeDirectory => Path.Combine(RepositoryRoot, "Tools", "NwnIncludes");
    public string CompilerRoot => Path.Combine(RepositoryRoot, "Tools", "NwnRoot");
    public string CompilerUserDirectory => Path.Combine(RepositoryRoot, "artifacts", "nwn-user");
    public string ApiCacheDirectory => Path.Combine(RepositoryRoot, "artifacts", "api-cache");

    private ProjectContext(string repositoryRoot)
    {
        RepositoryRoot = repositoryRoot;
        Directory.CreateDirectory(CompilerUserDirectory);
    }

    public static ProjectContext Load()
    {
        foreach (string start in new[] { Directory.GetCurrentDirectory(), AppContext.BaseDirectory })
        {
            DirectoryInfo? directory = new DirectoryInfo(start);
            while (directory is not null)
            {
                if (File.Exists(Path.Combine(directory.FullName, "Memoria.NeverwinterNights.slnx"))) return new ProjectContext(directory.FullName);
                directory = directory.Parent;
            }
        }

        throw new FileNotFoundException("Could not locate the Memoria.NeverwinterNights repository root.");
    }

    public string Tool(string fileName)
    {
        string safeName = Path.GetFileName(fileName);
        if (!string.Equals(safeName, fileName, StringComparison.Ordinal)) throw new ArgumentException("Tool names cannot contain a path.", nameof(fileName));
        string path = Path.Combine(ToolsDirectory, safeName.EndsWith(".exe", StringComparison.OrdinalIgnoreCase) ? safeName : safeName + ".exe");
        if (!File.Exists(path)) throw new FileNotFoundException($"Tool not found: {path}");
        return path;
    }

    public IEnumerable<string> ResManArguments()
    {
        yield return "--root";
        yield return CompilerRoot;
        yield return "--userdirectory";
        yield return CompilerUserDirectory;
        yield return "--no-keys";
        yield return "--no-ovr";
    }
}
