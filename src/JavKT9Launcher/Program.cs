using System.Diagnostics;
using System.Runtime.InteropServices;

namespace JavKT9Launcher;

/// <summary>
/// Clean, auditable bootstrapping executable. It does not include Perl code,
/// patch installed files, disable security software or execute PowerShell.
/// The installed GTK/Perl application remains unchanged.
/// </summary>
internal static class Program
{
    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    private static extern int MessageBoxW(IntPtr hWnd, string text, string caption, uint type);

    private static readonly string Root = Path.GetFullPath(AppContext.BaseDirectory);

    [STAThread]
    private static int Main(string[] args)
    {
        try
        {
            var perl = Path.Combine(Root, "app", "bin", "perl.exe");
            var script = Path.Combine(Root, "app", "bin", "gcstar");

            if (!File.Exists(perl) || !File.Exists(script))
            {
                var message = "Faltan componentes de JavKT9:\n" +
                    (!File.Exists(perl) ? "• app\\bin\\perl.exe\n" : "") +
                    (!File.Exists(script) ? "• app\\bin\\gcstar\n" : "") +
                    "\nNo se ha modificado ningún archivo.";
                Log(message.Replace("\n", " "));
                MessageBoxW(IntPtr.Zero, message,
                    "JavKT9 0.9.9.1 — componentes faltantes", 0x10);
                return 2;
            }

            var info = new ProcessStartInfo
            {
                FileName = perl,
                WorkingDirectory = Root,
                UseShellExecute = false,
                CreateNoWindow = true
            };
            info.ArgumentList.Add(script);
            foreach (var arg in args) info.ArgumentList.Add(arg);

            // Preserve the caller's configuration and prepend only packaged runtime paths.
            var runtimeDirs = new[]
            {
                Path.Combine(Root, "app", "bin"),
                Path.Combine(Root, "bin"),
                Path.Combine(Root, "app", "lib"),
                Path.Combine(Root, "lib")
            };
            var existingPath = info.Environment.TryGetValue("PATH", out var value)
                ? value ?? "" : "";
            info.Environment["PATH"] = string.Join(Path.PathSeparator,
                runtimeDirs.Where(Directory.Exists)) +
                Path.PathSeparator + existingPath;

            // Reproduce Iniciar-JavKT9.cmd directly in the executable.
            // Profile is local to the child and does not mutate the user profile.
            info.Environment["JAVKT9_PROFILE_DIR"] = "JavKT9";
            info.Environment["GCJAV_ROOT"] = Root;

            Log("JavKT9 0.9.9.1 RC1: iniciar motor Perl sin archivo CMD.");
            using var child = Process.Start(info);
            if (child is null)
            {
                Log("Unable to start packaged Perl process.");
                MessageBoxW(IntPtr.Zero, "No se pudo iniciar el motor Perl.",
                    "JavKT9", 0x10);
                return 3;
            }

            // Native GTK window belongs to the Perl child process.
            // Restore DWM caption and installed icon while the app is running.
            using var appearanceCancel = new CancellationTokenSource();
            var appearanceTask = Task.Run(() =>
                WindowAppearance.Monitor(child, Root, appearanceCancel.Token));

            child.WaitForExit();
            appearanceCancel.Cancel();
            try { appearanceTask.Wait(TimeSpan.FromSeconds(3)); }
            catch (AggregateException ex)
            {
                Log("Appearance task: " + ex.GetBaseException().Message);
            }

            Log("Application process exit code: " + child.ExitCode);
            if (child.ExitCode != 0)
            {
                MessageBoxW(IntPtr.Zero,
                    "La aplicación terminó con código " + child.ExitCode +
                    ". Revisá el registro de JavKT9 en AppData local.",
                    "JavKT9 — error al iniciar", 0x30);
            }
            return child.ExitCode;
        }
        catch (Exception ex)
        {
            Log("Launcher error: " + ex.GetType().Name + ": " + ex.Message);
            MessageBoxW(IntPtr.Zero,
                "No se pudo iniciar JavKT9.\n" + ex.Message,
                "JavKT9 — error", 0x10);
            return 1;
        }
    }

    internal static void Log(string message)
    {
        try
        {
            var folder = Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                "JavKT9");
            Directory.CreateDirectory(folder);
            File.AppendAllText(Path.Combine(folder, "JavKT9-launcher-rc1.log"),
                DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") +
                " " + message + Environment.NewLine);
        }
        catch
        {
            // Logging failure must never prevent application startup.
        }
    }
}
