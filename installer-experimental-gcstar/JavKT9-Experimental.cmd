@echo off
setlocal
set "JAVKT9_PROFILE_DIR=JavKT9-081-RC1-Experimental"
set "PATH=%~dp0bin;%SystemRoot%\System32;%SystemRoot%"
set "PERL5LIB=%~dp0app\lib;%~dp0lib\perl5\site_perl;%~dp0lib\perl5\vendor_perl;%~dp0lib\perl5\core_perl"
set "GI_TYPELIB_PATH=%~dp0lib\girepository-1.0"
set "XDG_DATA_DIRS=%~dp0share"
cd /d "%~dp0app"
"%~dp0bin\perl.exe" "%~dp0app\bin\gcstar" %*
