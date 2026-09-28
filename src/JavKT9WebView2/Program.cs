using System;
using System.IO;
using System.Windows.Forms;

namespace JavKT9WebView2;

internal static class Program
{
    [STAThread]
    static void Main(string[] args)
    {
        ApplicationConfiguration.Initialize();
        Application.SetUnhandledExceptionMode(UnhandledExceptionMode.CatchException);
        Application.ThreadException += (_, e) => Log.Write("UI ERROR: " + e.Exception);
        AppDomain.CurrentDomain.UnhandledException += (_, e) => Log.Write("FATAL: " + e.ExceptionObject);
        Log.Write("JavKT9 WebView2 host starting");
        Application.Run(new BrowserForm(args));
    }
}

internal static class Log
{
    private static readonly string Dir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "JavKT9");
    private static readonly string FileName = Path.Combine(Dir, "JavKT9-webview2.log");
    public static void Write(string text)
    {
        try { Directory.CreateDirectory(Dir); File.AppendAllText(FileName, $"{DateTime.Now:yyyy-MM-dd HH:mm:ss.fff} {text}{Environment.NewLine}"); } catch { }
    }
}
