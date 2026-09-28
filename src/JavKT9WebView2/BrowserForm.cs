using Microsoft.Web.WebView2.Core;
using Microsoft.Web.WebView2.WinForms;
using System;
using System.IO;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace JavKT9WebView2;

public sealed class BrowserForm : Form
{
    private readonly WebView2 web = new() { Dock = DockStyle.Fill };
    private readonly string code;
    private readonly string profile;

    public BrowserForm(string[] args)
    {
        code = args.FirstOrDefault(a => !a.StartsWith("--")) ?? "DASS-786";
        profile = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "JavKT9", "WebView2");
        Text = "JavKT9 WebView2 Experimental";
        Width = 1100; Height = 800;
        Controls.Add(web);
        Shown += async (_, _) => await StartAsync();
    }

    private async Task StartAsync()
    {
        try
        {
            Directory.CreateDirectory(profile);
            Log.Write($"profile={profile}");
            Log.Write($"code={code}");
            var env = await CoreWebView2Environment.CreateAsync(null, profile);
            await web.EnsureCoreWebView2Async(env);
            Log.Write("WebView2 initialized version=" + web.CoreWebView2.Environment.BrowserVersionString);
            web.CoreWebView2.Settings.AreDevToolsEnabled = true;
            web.CoreWebView2.NavigationStarting += (_, e) => Log.Write("NAV START " + e.Uri);
            web.CoreWebView2.NavigationCompleted += async (_, e) => await NavigationDone(e);
            var url = "https://www.javlibrary.com/en/vl_searchbyid.php?keyword=" + Uri.EscapeDataString(code);
            Log.Write("NAVIGATE " + url);
            web.CoreWebView2.Navigate(url);
        }
        catch (Exception ex)
        {
            Log.Write("START ERROR: " + ex);
            MessageBox.Show("No se pudo iniciar WebView2.\n\n" + ex.Message + "\n\nLog: %LOCALAPPDATA%\\JavKT9\\JavKT9-webview2.log", Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private async Task NavigationDone(CoreWebView2NavigationCompletedEventArgs e)
    {
        Log.Write($"NAV DONE success={e.IsSuccess} status={e.HttpStatusCode} error={e.WebErrorStatus} url={web.Source}");
        if (!e.IsSuccess) return;
        try
        {
            string titleJson = await web.CoreWebView2.ExecuteScriptAsync("document.title");
            string htmlJson = await web.CoreWebView2.ExecuteScriptAsync("document.documentElement.outerHTML");
            string title = JsonSerializer.Deserialize<string>(titleJson) ?? "";
            string html = JsonSerializer.Deserialize<string>(htmlJson) ?? "";
            Log.Write($"DOM title={title} htmlLength={html.Length}");
            var outDir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "JavKT9", "WebView2Capture");
            Directory.CreateDirectory(outDir);
            var safe = string.Concat(code.Select(c => char.IsLetterOrDigit(c) || c == '-' ? c : '_'));
            File.WriteAllText(Path.Combine(outDir, safe + ".html"), html);
            Log.Write("HTML SAVED " + Path.Combine(outDir, safe + ".html"));
        }
        catch (Exception ex) { Log.Write("DOM ERROR: " + ex); }
    }
}
