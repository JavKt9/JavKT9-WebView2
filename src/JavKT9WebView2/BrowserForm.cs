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
    private bool captureDone;
    private bool checkingPage;

    public BrowserForm(string[] args)
    {
        code = args.FirstOrDefault(a => !a.StartsWith("--")) ?? "DASS-786";

        profile = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            "JavKT9",
            "WebView2");

        Text = $"JavKT9 WebView2 Experimental 0.7.2 - {code}";
        Width = 1100;
        Height = 800;

        Controls.Add(web);

        Shown += async (_, _) => await StartAsync();
    }

    private async Task StartAsync()
    {
        try
        {
            Directory.CreateDirectory(profile);

            Log.Write("========================================");
            Log.Write("JavKT9 WebView2 0.7.2 starting");
            Log.Write($"code={code}");
            Log.Write($"UserDataFolder={profile}");

            var environment =
                await CoreWebView2Environment.CreateAsync(
                    browserExecutableFolder: null,
                    userDataFolder: profile);

            Log.Write("CoreWebView2Environment created");

            await web.EnsureCoreWebView2Async(environment);

            Log.Write("CoreWebView2 initialized");
            Log.Write($"BrowserVersion={web.CoreWebView2.Environment.BrowserVersionString}");

            web.CoreWebView2.NavigationStarting += (_, e) =>
            {
                Log.Write($"NavigationStarting={e.Uri}");
            };

            web.CoreWebView2.NavigationCompleted += async (_, e) =>
            {
                Log.Write(
                    $"NavigationCompleted success={e.IsSuccess} " +
                    $"status={e.WebErrorStatus}");

                Log.Write($"FinalURL={web.Source}");

                await InspectPageAsync();
            };

            web.CoreWebView2.ProcessFailed += (_, e) =>
            {
                Log.Write($"ProcessFailed={e.ProcessFailedKind}");
            };

            string url =
                "https://www.javlibrary.com/en/vl_searchbyid.php?keyword=" +
                Uri.EscapeDataString(code);

            Log.Write($"Navigate={url}");

            web.Source = new Uri(url);
        }
        catch (Exception ex)
        {
            Log.Write($"START ERROR: {ex}");
            MessageBox.Show(
                ex.ToString(),
                "JavKT9 WebView2 Error",
                MessageBoxButtons.OK,
                MessageBoxIcon.Error);
        }
    }

    private async Task InspectPageAsync()
    {
        if (checkingPage || captureDone || web.CoreWebView2 == null)
            return;

        checkingPage = true;

        try
        {
            // JavLibrary/Cloudflare may still be modifying the document
            // after NavigationCompleted.
            await Task.Delay(1500);

            string readyState = await JsStringAsync(
                "document.readyState");

            string title = await JsStringAsync(
                "document.title || ''");

            string bodyText = await JsStringAsync(
                "document.body ? document.body.innerText : ''");

            string currentUrl = web.Source?.ToString() ?? "";

            Log.Write($"document.readyState={readyState}");
            Log.Write($"title={title}");
            Log.Write($"url={currentUrl}");

            bool termsDetected =
                bodyText.Contains("I agree", StringComparison.OrdinalIgnoreCase) &&
                bodyText.Contains("I do not agree", StringComparison.OrdinalIgnoreCase);

            bool cloudflareDetected =
                bodyText.Contains("Verify you are human", StringComparison.OrdinalIgnoreCase) ||
                bodyText.Contains("Checking your browser", StringComparison.OrdinalIgnoreCase) ||
                title.Contains("Just a moment", StringComparison.OrdinalIgnoreCase);

            bool codeFound =
                bodyText.Contains(code, StringComparison.OrdinalIgnoreCase);

            Log.Write($"termsDetected={termsDetected}");
            Log.Write($"cloudflareDetected={cloudflareDetected}");
            Log.Write($"codeFound={codeFound}");

            if (termsDetected)
            {
                Log.Write(
                    "Human interaction required: JavLibrary terms/age confirmation.");

                // Do NOT capture the consent overlay as the final page.
                // Keep WebView2 visible so the user can press I agree.
                await ScheduleRecheckAsync();
                return;
            }

            if (cloudflareDetected)
            {
                Log.Write(
                    "Human interaction required: Cloudflare verification.");

                await ScheduleRecheckAsync();
                return;
            }

            if (!codeFound)
            {
                Log.Write(
                    "Target code not found yet; waiting before capture.");

                await ScheduleRecheckAsync();
                return;
            }

            // Give dynamically generated fields a little more time.
            await Task.Delay(1000);

            string html = await JsStringAsync(
                "document.documentElement.outerHTML");

            if (string.IsNullOrWhiteSpace(html))
            {
                Log.Write("HTML capture returned empty content.");
                await ScheduleRecheckAsync();
                return;
            }

            string captureDir = Path.Combine(
                Environment.GetFolderPath(
                    Environment.SpecialFolder.LocalApplicationData),
                "JavKT9",
                "WebView2Capture");

            Directory.CreateDirectory(captureDir);

            string safeCode = string.Concat(
                code.Select(c =>
                    Path.GetInvalidFileNameChars().Contains(c) ? '_' : c));

            string output = Path.Combine(
                captureDir,
                $"{safeCode}.html");

            await File.WriteAllTextAsync(output, html);

            captureDone = true;

            Log.Write($"HTML saved={output}");
            Log.Write($"HTML length={html.Length}");
            Log.Write("CAPTURE SUCCESS");
        }
        catch (Exception ex)
        {
            Log.Write($"INSPECT ERROR: {ex}");
            await ScheduleRecheckAsync();
        }
        finally
        {
            checkingPage = false;
        }
    }

    private async Task ScheduleRecheckAsync()
    {
        await Task.Delay(2000);

        BeginInvoke(new Action(async () =>
        {
            await InspectPageAsync();
        }));
    }

    private async Task<string> JsStringAsync(string expression)
    {
        string json = await web.CoreWebView2.ExecuteScriptAsync(expression);

        try
        {
            return JsonSerializer.Deserialize<string>(json) ?? "";
        }
        catch
        {
            return json ?? "";
        }
    }

    private static class Log
    {
        private static readonly string DirectoryPath =
            Path.Combine(
                Environment.GetFolderPath(
                    Environment.SpecialFolder.LocalApplicationData),
                "JavKT9");

        private static readonly string FilePath =
            Path.Combine(
                DirectoryPath,
                "JavKT9-webview2.log");

        public static void Write(string message)
        {
            try
            {
                Directory.CreateDirectory(DirectoryPath);

                File.AppendAllText(
                    FilePath,
                    $"{DateTime.Now:yyyy-MM-dd HH:mm:ss.fff} {message}" +
                    Environment.NewLine);
            }
            catch
            {
                // Logging must never stop the browser.
            }
        }
    }
}
