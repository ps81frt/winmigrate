:: ===========================================================================
:: Nom       : Checksums.bat
:: Projet    : WinMigrate
:: Author    : PS81FRT
:: GitHub    : https://github.com/ps81frt/winmigrate
:: Version   : 1.0.0
:: Licence   : MIT
:: Synopsis  : Verify SHA256 checksums of all files in a folder using certutil
:: Usage     : Run as Administrator - arg: [TargetFolder]
:: ===========================================================================
@echo off
chcp 437 > nul
setlocal enabledelayedexpansion
if not defined WINMIGRATE_LANG (
    for /f "tokens=3" %%L in ('reg query "HKCU\Control Panel\International" /v LocaleName 2^>nul') do set "_WML=%%L"
    if "!_WML:~0,2!"=="fr" (set "WINMIGRATE_LANG=FR") else (set "WINMIGRATE_LANG=EN")
    set "_WML="
)
if /i "%WINMIGRATE_LANG%"=="FR" (set "_YES=O" & set "_YESNO=O/N") else (set "_YES=Y" & set "_YESNO=Y/N")
net session >nul 2>&1
if not errorlevel 1 goto :ADMIN_OK
fsutil dirty query %SystemDrive% >nul 2>&1
if errorlevel 1 (
    if /i "%WINMIGRATE_LANG%"=="FR" (echo [ERREUR] Droits administrateur requis.) else (echo [ERROR] Administrator rights required.)
    exit /b 1
)
:ADMIN_OK
set "TARGET=%~1"
if "%TARGET%"=="" (
    echo Usage: %~nx0 [TargetFolder]
    exit /b 1
)
set "LOG_FILE=%TEMP%\WinMigrate_Checksums_%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%.log"
set "OUT=%TARGET%\checksums_%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%.txt"
echo === WinMigrate SHA256 Checksums === > "%OUT%"
echo Date: %DATE% %TIME% >> "%OUT%"
echo Folder: %TARGET% >> "%OUT%"
echo. >> "%OUT%"
set "ERRORS=0"
for %%F in ("%TARGET%\*") do (
    if /i not "%%~nxF"=="checksums_%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%.txt" (
        certutil -hashfile "%%F" SHA256 >> "%OUT%" 2>> "%LOG_FILE%"
        if errorlevel 1 (
            echo [ERROR] Hash failed for: %%~nxF >> "%OUT%"
            set "ERRORS=1"
        )
    )
)
if "%ERRORS%"=="1" (
    echo [WARN] Some checksum operations failed. See %LOG_FILE%
) else (
    echo [OK] All checksums complete. See %OUT%
)
exit /b 0