@echo off

rem ============================================================================
rem  config.example.bat -- toolchain location template
rem
rem  Copy this file to "config.bat" in the same directory and edit the paths
rem  below to match your machine. config.bat is git-ignored and never published;
rem  THIS template is committed and shipped. The build-*.bat / run-*.bat scripts
rem  each source config.bat automatically via:
rem
rem      if exist "%~dp0config.bat" call "%~dp0config.bat"
rem
rem  and fall back to the documented defaults below for any variable you leave
rem  unset.
rem
rem  None of these tools are redistributed with the project -- install them
rem  yourself and point the variables here:
rem
rem    Kick Assembler : http://theweb.dk/KickAssembler/   (KickAss.jar; needs a JRE)
rem    VICE           : https://vice-emu.sourceforge.io/  (provides x64sc, xvic)
rem    Java (JRE/JDK) : any JRE/JDK on PATH satisfies JAVA_EXE=java
rem ============================================================================

rem --------------------------------------------------------------------------
rem Kick Assembler jar: absolute path to KickAss.jar.
rem --------------------------------------------------------------------------

set "KICKASS_JAR=C:\tools\kickass\KickAss.jar"

rem --------------------------------------------------------------------------
rem Java launcher: "java" works if a JRE/JDK is on PATH.
rem --------------------------------------------------------------------------

set "JAVA_EXE=java"

rem --------------------------------------------------------------------------
rem VICE install root: must contain bin\x64sc.exe and bin\xvic.exe.
rem --------------------------------------------------------------------------

set "VICE_HOME=C:\tools\vice"
