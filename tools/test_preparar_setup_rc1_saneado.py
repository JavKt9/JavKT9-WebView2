"""Pruebas del saneamiento: nunca se imprime el valor de una clave."""
from pathlib import Path
import tempfile
import unittest
from preparar_setup_rc1_saneado import sanitize, make_installer_source

class SanitizerTests(unittest.TestCase):
    def test_solo_reemplaza_valor_y_conserva_codigo(self):
        original = b'head\nmy $apiKey = "antigua-clave-123456789";\nfooter\n'
        recovered = b'head\nmy $apiKey = "";\nfooter\n'
        output, secret = sanitize(original, recovered)
        self.assertEqual(output, recovered)
        self.assertEqual(secret, b'antigua-clave-123456789')

    def test_rechaza_fuentes_distintas(self):
        original = b'head\nmy $apiKey = "antigua-clave-123456789";\nfooter\n'
        recovered = b'changed\nmy $apiKey = "";\nfooter\n'
        with self.assertRaises(ValueError):
            sanitize(original, recovered)

    def test_rechaza_dos_literales(self):
        original = b'my $apiKey = "antigua-clave-123456789";\nmy $apiKey = "otra-clave-123456789";\n'
        with self.assertRaises(ValueError):
            sanitize(original, original)

    def test_ajusta_constantes_instalador_sin_tocar_template(self):
        with tempfile.TemporaryDirectory() as td:
            repo = Path(td)
            path = repo / "src/instalador-rc1/main.go"
            path.parent.mkdir(parents=True)
            path.write_text('''package main
const (
zipSize int64 = 165179057
zipSHA256 = "450ac674047e8df400fcfb242d25a0e4f5253f4cf664692b0ba0471028eb8e46"
installFolder = "JAVkt9-081-RC1-Instalada"
shortcutName = "JAVkt9 0.8.1 RC1 Candidata.lnk"
registryKey = \x60HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\JAVkt9-081-RC1-Candidata\x60
marker = "Paquete original RC1 conservado sin cambios."
)
''', "utf-8")
            out = repo / "build/main_saneado.go"
            result = {"zip_saneado_bytes": 234, "zip_saneado_sha256": "b" * 64}
            make_installer_source(repo, result, out)
            updated = out.read_text("utf-8")
            self.assertIn('zipSize int64 = 234', updated)
            self.assertIn('"'+ "b" * 64 + '"', updated)
            self.assertIn('JavKT9-081-RC1-Saneada', updated)
            self.assertIn('cuatro claves antiguas retiradas', updated)
            self.assertIn('RC1-Instalada', path.read_text("utf-8"))

if __name__ == "__main__":
    unittest.main()
