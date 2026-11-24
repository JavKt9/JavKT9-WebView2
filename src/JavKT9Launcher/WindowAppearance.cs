using System.Diagnostics;
using System.Globalization;
using System.Runtime.InteropServices;
using System.Text;

namespace JavKT9Launcher;

/// <summary>
/// Reapplies the native Windows 11 title-bar color based on JavKT9's
/// persisted palette. Uses Windows DWM; never changes global Windows settings.
/// This operates on the GTK window belonging to the child Perl process.
/// </summary>
internal static class WindowAppearance
{
    private delegate bool EnumWindowCallback(nint handle, nint data);

    [DllImport("user32.dll")]
    private static extern bool EnumWindows(EnumWindowCallback callback, nint data);

    [DllImport("user32.dll")]
    private static extern uint GetWindowThreadProcessId(nint handle, out uint processId);

    [DllImport("user32.dll")]
    private static extern bool IsWindowVisible(nint handle);

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    private static extern int GetWindowTextW(nint handle, StringBuilder text, int capacity);

    [DllImport("dwmapi.dll")]
    private static extern int DwmSetWindowAttribute(
        nint handle, int attribute, ref int value, int size);

    [DllImport("user32.dll", CharSet = CharSet.Unicode, EntryPoint = "LoadImageW")]
    private static extern nint LoadImage(
        nint instance, string name, uint type, int width, int height, uint flags);

    [DllImport("user32.dll", CharSet = CharSet.Unicode, EntryPoint = "SendMessageW")]
    private static extern nint SendMessage(
        nint handle, uint message, nint wparam, nint lparam);

    [DllImport("user32.dll")]
    private static extern bool DestroyIcon(nint icon);

    private const uint WmSetIcon = 0x80;
    private const uint ImageIcon = 1;
    private const uint LoadFromFile = 0x10;
    private const int DwmBorderColor = 34;
    private const int DwmCaptionColor = 35;
    private const int DwmTextColor = 36;

    private static readonly Dictionary<string, (string Caption, string Border)>
        Themes = new(StringComparer.OrdinalIgnoreCase)
    {
        ["KT9V1"]          = ("#85223F", "#3E303A"),
        ["Obsidiana"]      = ("#9C2866", "#463249"),
        ["Zafiro"]         = ("#1764BD", "#254966"),
        ["Esmeralda"]      = ("#018659", "#21533F"),
        ["Carmesí"]        = ("#BA2944", "#67303A"),
        ["Marfil"]         = ("#8B552D", "#D2B8A3"),
        ["Dark Purple"]    = ("#8F5BC8", "#3A3049"),
        ["Midnight Blue"]  = ("#428BD4", "#30465B"),
        ["Silver Light"]   = ("#2B7DE9", "#C2D1E0"),
        ["Pink Pulse"]     = ("#FF2E93", "#6A2452"),
        ["Obsidian Cyan"]  = ("#18BFEA", "#26384A"),
        ["Noir Gold"]      = ("#E7C64A", "#4B421E"),
        ["Sakura Crimson"] = ("#E63E63", "#6E2435")
    };

    internal static void Monitor(Process child, string root, CancellationToken cancellation)
    {
        // The installed custom icon is the original asset used by JavKT9.
        // It is optional: a failure must not prevent app startup.
        var icoPath = Path.Combine(root, "assets", "JavKT9-Logo.ico");
        nint bigIcon = 0;
        nint smallIcon = 0;
        try
        {
            if (File.Exists(icoPath))
            {
                bigIcon = LoadImage(0, icoPath, ImageIcon, 32, 32, LoadFromFile);
                smallIcon = LoadImage(0, icoPath, ImageIcon, 16, 16, LoadFromFile);
            }

            nint lastWindow = 0;
            string lastTheme = "";
            var logged = false;

            while (!cancellation.IsCancellationRequested)
            {
                if (child.HasExited) break;

                nint handle = FindWindow((uint)child.Id);
                if (handle != 0)
                {
                    var theme = CurrentTheme();
                    if (handle != lastWindow || theme != lastTheme)
                    {
                        if (Themes.TryGetValue(theme, out var palette))
                        {
                            var caption = ColorRef(palette.Caption);
                            var border = ColorRef(palette.Border);
                            var text = ColorRef(ReadableTextColor(palette.Caption));
                            int a = DwmSetWindowAttribute(handle, DwmCaptionColor, ref caption, 4);
                            int b = DwmSetWindowAttribute(handle, DwmBorderColor, ref border, 4);
                            int c = DwmSetWindowAttribute(handle, DwmTextColor, ref text, 4);
                            if (a == 0 && b == 0 && c == 0 && !logged)
                            {
                                Program.Log("DWM caption restored for palette: " + theme);
                                logged = true;
                            }
                            else if (a != 0 && !logged)
                            {
                                Program.Log("DWM caption unsupported or rejected: HRESULT " +
                                    a.ToString("X8"));
                                logged = true;
                            }
                        }

                        if (bigIcon != 0)
                            SendMessage(handle, WmSetIcon, 1, bigIcon);
                        if (smallIcon != 0)
                            SendMessage(handle, WmSetIcon, 0, smallIcon);

                        lastWindow = handle;
                        lastTheme = theme;
                    }
                }

                if (cancellation.WaitHandle.WaitOne(900)) break;
            }
        }
        catch (Exception ex)
        {
            Program.Log("Window appearance: " + ex.GetType().Name + ": " + ex.Message);
        }
        finally
        {
            if (smallIcon != 0) DestroyIcon(smallIcon);
            if (bigIcon != 0) DestroyIcon(bigIcon);
        }
    }

    private static nint FindWindow(uint ownerPid)
    {
        nint result = 0;
        EnumWindows((handle, _) =>
        {
            if (!IsWindowVisible(handle)) return true;
            GetWindowThreadProcessId(handle, out uint pid);
            if (pid != ownerPid) return true;
            var title = new StringBuilder(512);
            GetWindowTextW(handle, title, title.Capacity);
            if (!title.ToString().Contains("JavKT9", StringComparison.OrdinalIgnoreCase))
                return true;
            result = handle;
            return false;
        }, 0);
        return result;
    }

    private static string CurrentTheme()
    {
        var appData = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
        var folder = Path.Combine(appData, "JavKT9");
        var appearance = Path.Combine(folder, "GCJavAppearance099.conf");
        if (File.Exists(appearance))
        {
            try
            {
                var prefs = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
                foreach (var raw in File.ReadLines(appearance))
                {
                    int sep = raw.IndexOf('=');
                    if (sep < 1) continue;
                    prefs[raw[..sep].Trim()] = raw[(sep + 1)..].Trim();
                }
                var mode = prefs.GetValueOrDefault("mode", "v2");
                if (mode is not ("clasico" or "v1" or "v2")) mode = "v2";
                var fallback = mode switch
                {
                    "clasico" => "Silver Light",
                    "v1" => "Midnight Blue",
                    _ => "KT9V1"
                };
                var name = prefs.GetValueOrDefault(mode, fallback);
                return Themes.ContainsKey(name) ? name : fallback;
            }
            catch (IOException) { /* Preference file may be written during theme change. */ }
            catch (UnauthorizedAccessException) { /* Keep active default. */ }
        }

        var skin = Path.Combine(folder, "GCJavSkin.conf");
        try
        {
            if (File.Exists(skin))
            {
                var value = File.ReadLines(skin).FirstOrDefault()?.Trim() ?? "";
                if (Themes.ContainsKey(value)) return value;
            }
        }
        catch (IOException) { }
        catch (UnauthorizedAccessException) { }
        return "KT9V1";
    }

    private static string ReadableTextColor(string hex)
    {
        int r = int.Parse(hex.AsSpan(1, 2), NumberStyles.HexNumber, CultureInfo.InvariantCulture);
        int g = int.Parse(hex.AsSpan(3, 2), NumberStyles.HexNumber, CultureInfo.InvariantCulture);
        int b = int.Parse(hex.AsSpan(5, 2), NumberStyles.HexNumber, CultureInfo.InvariantCulture);
        // Contrast threshold for caption readability.
        return (r * 299 + g * 587 + b * 114) / 1000 >= 145
            ? "#101317" : "#FFFFFF";
    }

    private static int ColorRef(string hex)
    {
        int r = int.Parse(hex.AsSpan(1, 2), NumberStyles.HexNumber, CultureInfo.InvariantCulture);
        int g = int.Parse(hex.AsSpan(3, 2), NumberStyles.HexNumber, CultureInfo.InvariantCulture);
        int b = int.Parse(hex.AsSpan(5, 2), NumberStyles.HexNumber, CultureInfo.InvariantCulture);
        // Windows COLORREF uses 0x00BBGGRR, unlike RGB hex.
        return r | (g << 8) | (b << 16);
    }
}
