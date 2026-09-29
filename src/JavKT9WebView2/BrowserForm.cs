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
    private readonly WebView2 web =
        new() { Dock = DockStyle.Fill };

    private readonly string code;
    private readonly string profile;
    private readonly bool hiddenMode;

    private bool captureDone;
    private bool checkingPage;
    private bool humanWindowShown;
    private bool exactResultNavigationAttempted;

    private DateTime startedAt;

    private const int MaximumRunSeconds = 90;

    public BrowserForm(string[] args)
    {
        code =
            args.FirstOrDefault(
                a => !a.StartsWith("--",
                    StringComparison.OrdinalIgnoreCase))
            ?? "DASS-786";

        hiddenMode =
            args.Any(
                a => a.Equals(
                    "--hidden",
                    StringComparison.OrdinalIgnoreCase));

        profile =
            Path.Combine(
                Environment.GetFolderPath(
                    Environment.SpecialFolder.LocalApplicationData),
                "JavKT9",
                "WebView2");

        Text =
            $"JavKT9 WebView2 Experimental 0.7.23 - {code}";

        Width = 1100;
        Height = 800;

        StartPosition = FormStartPosition.CenterScreen;

        Controls.Add(web);

        if (hiddenMode)
        {
            ShowInTaskbar = false;
            Opacity = 0;
        }

        Shown += async (_, _) => await StartAsync();
    }

    private async Task StartAsync()
    {
        try
        {
            startedAt = DateTime.Now;

            Directory.CreateDirectory(profile);

            Log.Write("JavKT9 WebView2 0.7.23");
            Log.Write($"code={code}");
            Log.Write($"hiddenMode={hiddenMode}");
            Log.Write($"UserDataFolder={profile}");

            var environment =
                await CoreWebView2Environment.CreateAsync(
                    browserExecutableFolder: null,
                    userDataFolder: profile);

            Log.Write("CoreWebView2Environment created");

            await web.EnsureCoreWebView2Async(environment);

            Log.Write("CoreWebView2 initialized");

            Log.Write(
                $"BrowserVersion=" +
                $"{web.CoreWebView2.Environment.BrowserVersionString}");

            web.CoreWebView2.NavigationStarting +=
                (_, e) =>
                {
                    Log.Write(
                        $"NavigationStarting={e.Uri}");
                };

            web.CoreWebView2.NavigationCompleted +=
                async (_, e) =>
                {
                    Log.Write(
                        $"NavigationCompleted " +
                        $"success={e.IsSuccess} " +
                        $"status={e.WebErrorStatus}");

                    Log.Write(
                        $"FinalURL={web.Source}");

                    await InspectPageAsync();
                };

            web.CoreWebView2.ProcessFailed +=
                (_, e) =>
                {
                    Log.Write(
                        $"ProcessFailed={e.ProcessFailedKind}");
                };

            string url =
                "https://www.javlibrary.com/en/" +
                "vl_searchbyid.php?keyword=" +
                Uri.EscapeDataString(code);

            Log.Write($"Navigate={url}");

            web.Source = new Uri(url);
        }
        catch (Exception ex)
        {
            Fail(
                20,
                "START ERROR: " + ex,
                true);
        }
    }

    private async Task InspectPageAsync()
    {
        if (captureDone || checkingPage)
            return;

        if (web.CoreWebView2 == null)
            return;

        checkingPage = true;

        bool needsRecheck = false;

        try
        {
            if ((DateTime.Now - startedAt).TotalSeconds >
                MaximumRunSeconds)
            {
                Fail(
                    30,
                    "TIMEOUT waiting for JavLibrary.",
                    true);

                return;
            }

            await Task.Delay(1200);

            string readyState =
                await JsStringAsync(
                    "document.readyState");

            string title =
                await JsStringAsync(
                    "document.title || ''");

            string bodyText =
                await JsStringAsync(
                    "document.body ? " +
                    "document.body.innerText : ''");

            string currentUrl =
                web.Source?.ToString() ?? "";

            Log.Write(
                $"document.readyState={readyState}");

            Log.Write($"title={title}");
            Log.Write($"url={currentUrl}");

            bool termsDetected =
                bodyText.Contains(
                    "I agree",
                    StringComparison.OrdinalIgnoreCase)
                &&
                bodyText.Contains(
                    "I do not agree",
                    StringComparison.OrdinalIgnoreCase);

            bool cloudflareDetected =
                bodyText.Contains(
                    "Verify you are human",
                    StringComparison.OrdinalIgnoreCase)
                ||
                bodyText.Contains(
                    "Checking your browser",
                    StringComparison.OrdinalIgnoreCase)
                ||
                title.Contains(
                    "Just a moment",
                    StringComparison.OrdinalIgnoreCase)
                ||
                title.Contains(
                    "Un momento",
                    StringComparison.OrdinalIgnoreCase);

            bool codeFound =
                bodyText.Contains(
                    code,
                    StringComparison.OrdinalIgnoreCase)
                ||
                title.Contains(
                    code,
                    StringComparison.OrdinalIgnoreCase);

            Log.Write(
                $"termsDetected={termsDetected}");

            Log.Write(
                $"cloudflareDetected={cloudflareDetected}");

            Log.Write(
                $"codeFound={codeFound}");

            if (termsDetected)
            {
                Log.Write(
                    "JavLibrary terms/age confirmation detected.");

                ShowForHumanInteraction(
                    "JavLibrary requires confirmation.");

                needsRecheck = true;
                return;
            }

            if (cloudflareDetected)
            {
                Log.Write(
                    "Cloudflare human verification detected.");

                ShowForHumanInteraction(
                    "Cloudflare verification required.");

                needsRecheck = true;
                return;
            }

            if (!codeFound)
            {
                Log.Write(
                    "Target code not found yet.");

                needsRecheck = true;
                return;
            }

            // Some older JavLibrary IDs do not redirect directly from
            // vl_searchbyid.php.  If we are still on a search/results page,
            // follow the first link whose visible text contains the exact ID.
            // Modern direct redirects are untouched.
            bool looksLikeFinalVideoPage =
                currentUrl.IndexOf(
                    "vl_searchbyid.php",
                    StringComparison.OrdinalIgnoreCase) < 0
                &&
                (
                    bodyText.Contains(
                        "Release Date:",
                        StringComparison.OrdinalIgnoreCase)
                    ||
                    bodyText.Contains(
                        "Length:",
                        StringComparison.OrdinalIgnoreCase)
                    ||
                    bodyText.Contains(
                        "Genre(s):",
                        StringComparison.OrdinalIgnoreCase)
                );

            if (!looksLikeFinalVideoPage &&
                !exactResultNavigationAttempted)
            {
                exactResultNavigationAttempted = true;

                string jsCode =
                    JsonSerializer.Serialize(code);

                string href =
                    await JsStringAsync(
                        "(() => {" +
                        " const target = " + jsCode + ".toUpperCase();" +
                        " const links = Array.from(document.querySelectorAll('a[href]'));" +
                        " const hit = links.find(a => ((a.innerText || a.textContent || '').trim().toUpperCase()).includes(target));" +
                        " return hit ? hit.href : '';" +
                        "})()");

                if (!string.IsNullOrWhiteSpace(href))
                {
                    Log.Write(
                        $"Exact result fallback navigate={href}");

                    web.Source = new Uri(href);

                    return;
                }

                Log.Write(
                    "Exact result fallback: no matching link found.");
            }

            if (!readyState.Equals(
                    "complete",
                    StringComparison.OrdinalIgnoreCase))
            {
                Log.Write(
                    "Document is not complete yet.");

                needsRecheck = true;
                return;
            }

            await Task.Delay(800);

            string html =
                await JsStringAsync(
                    "document.documentElement.outerHTML");

            if (string.IsNullOrWhiteSpace(html))
            {
                Log.Write(
                    "HTML capture returned empty content.");

                needsRecheck = true;
                return;
            }

            string captureDir =
                Path.Combine(
                    Environment.GetFolderPath(
                        Environment.SpecialFolder
                            .LocalApplicationData),
                    "JavKT9",
                    "WebView2Capture");

            Directory.CreateDirectory(captureDir);

            string safeCode =
                string.Concat(
                    code.Select(
                        c =>
                            Path.GetInvalidFileNameChars()
                                .Contains(c)
                            ? '_'
                            : c));

            string output =
                Path.Combine(
                    captureDir,
                    $"{safeCode}.html");

            await File.WriteAllTextAsync(
                output,
                html);

            captureDone = true;

            Log.Write($"HTML saved={output}");
            Log.Write($"HTML length={html.Length}");
            Log.Write("CAPTURE SUCCESS");

            Environment.ExitCode = 0;

            await Task.Delay(300);

            Close();
        }
        catch (Exception ex)
        {
            Log.Write(
                $"INSPECT ERROR: {ex}");

            needsRecheck = true;
        }
        finally
        {
            checkingPage = false;

            if (needsRecheck && !captureDone)
            {
                ScheduleRecheck();
            }
        }
    }

    private void ScheduleRecheck()
    {
        _ = Task.Run(
            async () =>
            {
                await Task.Delay(2000);

                if (IsDisposed || captureDone)
                    return;

                try
                {
                    BeginInvoke(
                        new Action(
                            async () =>
                            {
                                await InspectPageAsync();
                            }));
                }
                catch
                {
                }
            });
    }

    private void ShowForHumanInteraction(
        string reason)
    {
        if (humanWindowShown)
            return;

        humanWindowShown = true;

        Log.Write(
            $"Showing WebView2 window: {reason}");

        ShowInTaskbar = true;
        Opacity = 1;

        WindowState = FormWindowState.Normal;

        Activate();
        BringToFront();
    }

    private async Task<string> JsStringAsync(
        string expression)
    {
        string json =
            await web.CoreWebView2
                .ExecuteScriptAsync(expression);

        try
        {
            return
                JsonSerializer.Deserialize<string>(json)
                ?? "";
        }
        catch
        {
            return json ?? "";
        }
    }

    private void Fail(
        int exitCode,
        string message,
        bool showMessage)
    {
        Log.Write(message);

        Environment.ExitCode = exitCode;

        if (showMessage && !hiddenMode)
        {
            MessageBox.Show(
                message,
                "JavKT9 WebView2 Error",
                MessageBoxButtons.OK,
                MessageBoxIcon.Error);
        }

        try
        {
            Close();
        }
        catch
        {
        }
    }
}
