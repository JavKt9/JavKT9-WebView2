#!/usr/bin/env bash
# EXPERIMENTAL ONLY: Cygwin Perl/GTK3 creates a Cygwin-dependent executable.
set -euo pipefail
cd "$(dirname "$0")/.."
root="$PWD"
src="$root/src/perl/par_embebido/script/gcstar.pl"
lib="$root/src/perl/lib/gcstar"
out="$root/out-gcstar-cygwin-experimental"
test -f "$src" && test -f "$lib/GCOptions.pm"
mkdir -p "$out"
test ! -e "$out/gcstar-cygwin-experimental.exe"

echo "Perl Cygwin: $(perl -e 'print $^V')"
for module in Gtk3 Glib Glib::Object::Introspection Cairo Pango PAR::Packer XML::Simple; do
  echo "Verificando $module"
  perl "-M${module}" -e 'print "OK\n"'
done

echo "Comprobando sintaxis del script recuperado PAR con los modulos de Cygwin"
perl -I "$lib" -c "$src"

echo "Empaquetando solamente en entorno experimental; NO instalador RC1"
pp -I "$lib" -M Gtk3 -M Glib::Object::Introspection \
   -o "$out/gcstar-cygwin-experimental.exe" "$src"

sha256sum "$out/gcstar-cygwin-experimental.exe" | tee "$out/SHA256.txt"
echo "Este EXE requiere runtime Cygwin/GTK3, pruebas GUI y auditoria de licencias."
