namespace Memoria.NeverwinterNights.Toolset;

internal static class ToolsetLog
{
    public static bool IsVerbose { get; private set; }

    public static void Configure(bool verbose)
    {
        IsVerbose = verbose;
    }

    public static void Verbose(string message)
    {
        if (IsVerbose) Console.WriteLine(message);
    }

    public static string RepositoryPath(ProjectContext context, string path)
    {
        string fullPath = Path.GetFullPath(path);
        string relativePath = Path.GetRelativePath(context.RepositoryRoot, fullPath);
        if (Path.IsPathRooted(relativePath) || relativePath.Equals("..", StringComparison.Ordinal) || relativePath.StartsWith(".." + Path.DirectorySeparatorChar, StringComparison.Ordinal)) return fullPath;
        return Path.DirectorySeparatorChar + relativePath;
    }
}
