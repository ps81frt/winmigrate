:: ===========================================================================
:: Nom       : ExportPrinters.bat
:: Projet    : WinMigrate
:: Author    : PS81FRT
:: GitHub    : https://github.com/ps81frt/winmigrate
:: Version   : 1.0.0
:: Licence   : MIT
:: Synopsis  : Export installed printers list and registry config - no deprecated tools
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
set "LOG_FILE=%TEMP%\WinMigrate_ExportPrinters_%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%.log"
set "OUT=%DEST%\Printers_%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%.txt"
echo === WinMigrate Printer Export === > "%OUT%"
echo Date: %DATE% %TIME% >> "%OUT%"
echo. >> "%OUT%"
echo --- Installed Printers (registry) --- >> "%OUT%"
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Print\Printers" >> "%OUT%" 2>> "%LOG_FILE%"
echo. >> "%OUT%"
echo --- Printer Connections (HKCU) --- >> "%OUT%"
reg query "HKCU\Printers\Connections" /s >> "%OUT%" 2>> "%LOG_FILE%"
echo. >> "%OUT%"
echo --- Default Printer --- >> "%OUT%"
reg query "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows" /v Device >> "%OUT%" 2>> "%LOG_FILE%"
echo [OK] Printer list exported to: %OUT%
exit /b 0