// SPDX-License-Identifier: GPL-2.0-or-later
// Public edition ONLY: isolates the browser profile and captured HTML.
// The original src/JavKT9WebView2/ project remains untouched.
using System;
using System.IO;

namespace JavKT9WebView2;

internal static class PublicPaths
{
    internal static string LocalAppData
    {
        get
        {
            string? local = Environment.GetEnvironmentVariable("LOCALAPPDATA");
            if (!string.IsNullOrWhiteSpace(local) &&
                local.Contains("JavKT9-Publica-Desarrollo", StringComparison.OrdinalIgnoreCase))
            {
                return Path.GetFullPath(local);
            }

            // Safe fallback when the host is accidentally launched by itself:
            // never share the original RC1's WebView2 profile.
            return Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                "JavKT9-Publica-Desarrollo",
                "Runtime");
        }
    }
}
