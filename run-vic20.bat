@echo off
setlocal

rem =============================================================================
rem  run-vic20.bat -- build the VIC-20 installer, then launch it in VICE xvic
rem  pinned to the unexpanded configuration (-memory none).
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

set "OUTPUT_PRG=dist\westminster-vic20.prg"
set "XVIC=%VICE_HOME%\bin\xvic.exe"

rem --------------------------------------------------------------------------
rem 1. Build
rem --------------------------------------------------------------------------

call "%~dp0build-vic20.bat"
if errorlevel 1 exit /b 1

rem --------------------------------------------------------------------------
rem 2. Run in VICE xvic, unexpanded (-memory none)
rem --------------------------------------------------------------------------

if not exist "%XVIC%" (
    echo ERROR: VICE xvic not found at "%XVIC%".
    echo        Set VICE_HOME -- copy config.example.bat to config.bat and edit it.
    exit /b 1
)
"%XVIC%" -memory none -autostart "%OUTPUT_PRG%"

endlocal
