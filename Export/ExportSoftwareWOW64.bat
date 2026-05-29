:: ===========================================================================
:: Nom       : ExportSoftwareWOW64.bat
:: Projet    : WinMigrate
:: Author    : PS81FRT
:: GitHub    : https://github.com/ps81frt/winmigrate
:: Version   : 1.0.0
:: Licence   : MIT
:: Synopsis  : Export 32-bit (WOW64) installed software list from registry
:: Usage     : Run as Administrator - optional arg: [DestinationFolder]
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
set "DEST=%~1"
if "%DEST%"=="" set "DEST=%USERPROFILE%\Desktop\WinMigrate_Backup"
if not exist "%DEST%" mkdir "%DEST%"
set "LOG_FILE=%TEMP%\WinMigrate_ExportSoftwareWOW64_%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%.log"
echo Exporting 32-bit software list from WOW6432Node registry key...
reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /s > "%DEST%\SoftwareList_WOW64.txt" 2>> "%LOG_FILE%"
if errorlevel 1 (
    echo [ERROR] 32-bit software list export failed. See %LOG_FILE%
    exit /b 1
)
echo [OK] 32-bit software list exported to: %DEST%\SoftwareList_WOW64.txt
echo [OK] See %LOG_FILE%
exit /b 0