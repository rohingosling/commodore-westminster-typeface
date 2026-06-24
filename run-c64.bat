@echo off
setlocal

rem =============================================================================
rem run-c64.bat -- build the C64 installer, then launch it in VICE x64sc.
rem =============================================================================

rem --------------------------------------------------------------------------
rem Configurable tool locations (override via environment / config.bat)
rem --------------------------------------------------------------------------

if exist "%~dp0config.bat" call "%~dp0config.bat"
if not defined KICKASS_JAR set "KICKASS_JAR=C:\tools\kickass\KickAss.jar"
if not defined JAVA_EXE    set "JAVA_EXE=java"
if not defined VICE_HOME   set "VICE_HOME=C:\tools\vice"

rem --------------------------------------------------------------------------
rem Resolve every relative path from the project root
rem --------------------------------------------------------------------------

cd /d "%~dp0"

set "OUTPUT_PRG=dist\westminster-c64.prg"
set "X64SC=%VICE_HOME%\bin\x64sc.exe"

rem --------------------------------------------------------------------------
rem 1. Build
rem --------------------------------------------------------------------------

call "%~dp0build-c64.bat"
if errorlevel 1 exit /b 1

rem --------------------------------------------------------------------------
rem 2. Run in VICE x64sc
rem --------------------------------------------------------------------------

if not exist "%X64SC%" (
    echo ERROR: VICE x64sc not found at "%X64SC%".
    echo        Set VICE_HOME -- copy config.example.bat to config.bat and edit it.
    exit /b 1
)
"%X64SC%" -autostart "%OUTPUT_PRG%"

endlocal
