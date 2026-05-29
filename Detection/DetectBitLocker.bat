:: ===========================================================================
:: Nom       : DetectBitLocker.bat
:: Projet    : WinMigrate
:: Author    : PS81FRT
:: GitHub    : https://github.com/ps81frt/winmigrate
:: Version   : 1.0.0
:: Licence   : MIT
:: Synopsis  : Detect BitLocker encryption status on all drives
:: Usage     : Run as Administrator
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
echo Checking BitLocker status...
manage-bde -status > "%TEMP%\WinMigrate_BitLocker.txt" 2>&1
if errorlevel 1 (
    echo [ERROR] manage-bde failed. BitLocker may not be available on this system.
    exit /b 1
)
type "%TEMP%\WinMigrate_BitLocker.txt"
echo [OK] BitLocker status saved to %TEMP%\WinMigrate_BitLocker.txt
exit /b 0