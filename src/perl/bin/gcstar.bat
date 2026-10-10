@echo off
cd %0\..
set PATH=..\usr\bin;..\usr\lib;%PATH%
set GI_TYPELIB_PATH=..\usr\lib\typelib
set GSETTINGS_SCHEMA_DIR=..\usr\lib\schema

set LANG=ES
start gcstar.exe %1
