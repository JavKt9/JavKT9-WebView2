"""Prueba unitaria del armado privado; no necesita el ZIP real de la RC1."""
import hashlib
import importlib.util
from pathlib import Path
import tempfile
import unittest
import zipfile

HERE = Path(__file__).parent
spec = importlib.util.spec_from_file_location("portable", HERE / "armar_portable_publica_desarrollo.py")
portable = importlib.util.module_from_spec(spec)
spec.loader.exec_module(portable)


class PortableTests(unittest.TestCase):
    def test_only_new_executables_and_redacted_sources(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            archive = root / "rc1.zip"
            with zipfile.ZipFile(archive, "w") as z:
                z.writestr("payload/JavKT9.exe", b"old launcher")
                z.writestr("payload/bin/GCJavBridgeLauncher.exe", b"old bridge launcher")
                z.writestr("payload/bin/WebView2Host/JavKT9WebView2.exe", b"old host")
                z.writestr("payload/bin/gcstar.exe", b"gcstar")
                z.writestr("payload/usr/bin/gtk.dll", b"gtk")
                z.writestr("Instalar_JAVkt9_RC1_Publica.ps1", b"do not install")
                for name in portable.REDACT:
                    z.writestr("payload/lib/gcstar/" + name, b'my $apiKey = "old";')
            portable.RC1_SHA256 = hashlib.sha256(archive.read_bytes()).hexdigest()
            repo = root / "repo"
            (repo / "src/perl/lib/gcstar").mkdir(parents=True)
            for name in portable.REDACT:
                path = repo / "src/perl/lib/gcstar" / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(b'my $apiKey = "";')
            (repo / "LICENSE").write_text("GPL v2")
            (repo / "NOTICE.md").write_text("GCstar credits")
            launcher = root / "launcher.exe"
            launcher.write_bytes(b"new launcher")
            host = root / "host"
            host.mkdir()
            (host / "JavKT9WebView2.exe").write_bytes(b"new host")
            output = root / "preview.zip"
            portable.assemble(archive, launcher, host, repo, output)
            with zipfile.ZipFile(output) as z:
                names = z.namelist()
                prefix = portable.ROOT
                self.assertEqual(z.read(prefix + "JavKT9.exe"), b"new launcher")
                self.assertEqual(z.read(prefix + "bin/WebView2Host/JavKT9WebView2.exe"), b"new host")
                self.assertNotIn(prefix + "bin/GCJavBridgeLauncher.exe", names)
                self.assertNotIn("Instalar_JAVkt9_RC1_Publica.ps1", names)
                for name in portable.REDACT:
                    self.assertEqual(z.read(prefix + "lib/gcstar/" + name), b'my $apiKey = "";')
                self.assertIn(prefix + "MANIFIESTO_SHA256.txt", names)


if __name__ == "__main__":
    unittest.main()
