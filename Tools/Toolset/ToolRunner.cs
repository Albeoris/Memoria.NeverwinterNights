using System.Diagnostics;
using System.Text;

namespace Memoria.NeverwinterNights.Toolset;

internal sealed record ToolResult(int ExitCode, string StandardOutput, string StandardError);

internal static class ToolRunner
{
    public static async Task<int> RunAsync(string executable, IEnumerable<string> arguments, string? workingDirectory = null)
    {
        using Process process = CreateProcess(executable, arguments, workingDirectory, false);
        process.Start();
        await process.WaitForExitAsync();
        return process.ExitCode;
    }

    public static async Task<ToolResult> CaptureAsync(string executable, IEnumerable<string> arguments, string? workingDirectory = null)
    {
        using Process process = CreateProcess(executable, arguments, workingDirectory, true);
        process.Start();
        Task<string> stdout = process.StandardOutput.ReadToEndAsync();
        Task<string> stderr = process.StandardError.ReadToEndAsync();
        await process.WaitForExitAsync();
        return new ToolResult(process.ExitCode, await stdout, await stderr);
    }

    private static Process CreateProcess(string executable, IEnumerable<string> arguments, string? workingDirectory, bool capture)
    {
        ProcessStartInfo startInfo = new ProcessStartInfo(executable) { UseShellExecute = false, WorkingDirectory = workingDirectory ?? Directory.GetCurrentDirectory(), RedirectStandardOutput = capture, RedirectStandardError = capture, StandardOutputEncoding = capture ? Encoding.UTF8 : null, StandardErrorEncoding = capture ? Encoding.UTF8 : null };
        foreach (string argument in arguments) startInfo.ArgumentList.Add(argument);
        return new Process { StartInfo = startInfo };
    }
}
