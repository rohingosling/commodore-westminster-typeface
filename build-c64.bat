@echo off
setlocal

rem =============================================================================
rem  build-c64.bat -- assemble the Commodore 64 Westminster installer.
rem
rem  Assembles src\c64\westminster-c64.asm (which imports the shared macros and
rem  the committed overlay table src\shared\charset.asm) into dist\westminster-
rem  c64.prg. No code generation step: the charset table is source you can edit
rem  directly (src\shared\charset.asm).
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

rem --------------------------------------------------------------------------
rem Project paths
rem --------------------------------------------------------------------------

set "MAIN_SOURCE=src\c64\westminster-c64.asm"
set "OUTPUT_PRG=dist\westminster-c64.prg"

rem --------------------------------------------------------------------------
rem Assemble: Kick Assembler main + shared sources -> dist\*.prg
rem --------------------------------------------------------------------------

if not exist "%KICKASS_JAR%" (
    echo ERROR: Kick Assembler jar not found at "%KICKASS_JAR%".
    echo        Set KICKASS_JAR -- copy config.example.bat to config.bat and edit it.
    exit /b 1
)
if not exist dist md dist
"%JAVA_EXE%" -jar "%KICKASS_JAR%" "%MAIN_SOURCE%" -libdir src\shared -o "%OUTPUT_PRG%"
if errorlevel 1 (
    echo ERROR: assembly failed.
    exit /b 1
)

rem --------------------------------------------------------------------------
rem NFR-1: the PRG must be well under 4 KB
rem --------------------------------------------------------------------------

set "PRG_BYTES=0"
for %%F in ("%OUTPUT_PRG%") do set "PRG_BYTES=%%~zF"
if %PRG_BYTES% GEQ 4096 (
    echo ERROR: %OUTPUT_PRG% is %PRG_BYTES% bytes, not well under 4 KB ^(NFR-1^).
    exit /b 1
)
echo [build-c64] Built %OUTPUT_PRG% ^(%PRG_BYTES% bytes^).

endlocal
