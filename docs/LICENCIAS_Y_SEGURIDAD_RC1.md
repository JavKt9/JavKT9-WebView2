# Licencias y seguridad — JAVkt9 RC1

**No publicar todavía.** La auditoría detallada se encuentra en [AUDITORIA_LICENCIAS_RC1.md](AUDITORIA_LICENCIAS_RC1.md).

- GPL v2 completa en `LICENSE`, con atribución GCstar/kt9 en `NOTICE.md`.
- 1115 archivos Perl incorporados y 4 claves antiguas retiradas.
- 348 recursos GCstar (imágenes, logos, temas, tipografía) todavía no incorporados; la tipografía Liberation Sans declara SIL OFL 1.1 en el paquete original.
- El payload incluye dependencias Perl/GTK y .NET/WebView2 cuya procedencia, versiones, licencias y avisos aún deben revisarse.
- Faltan fuentes originales de `JavKT9.exe` y `GCJavBridgeLauncher.exe`; no se puede afirmar que el código correspondiente esté completo.
- Gitleaks sin hallazgos no garantiza privacidad ni cumplimiento de licencias.

Revisar fuentes, licencias de terceros, logos, recursos, perfiles/cookies y todo el historial antes de cambiar visibilidad o publicar binarios. La rama `main` y la release RC1 no se modifican.
