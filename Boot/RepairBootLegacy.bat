:: ===========================================================================
:: Nom       : RepairBootLegacy.bat
:: Projet    : WinMigrate
:: Author    : PS81FRT
:: GitHub    : https://github.com/ps81frt/winmigrate
:: Version   : 1.0.0
:: Licence   : MIT
:: Synopsis  : Repair legacy BIOS boot using bootrec and bcdboot
:: Usage     : Run as Administrator - optional arg: Windows path (default C:\Windows)
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
set "WINPATH=%~1"
if "%WINPATH%"=="" set "WINPATH=C:\Windows"
set /p "CONFIRM=Confirm legacy BIOS boot repair for %WINPATH%? (!_YESNO!) : "
if /i not "%CONFIRM%"=="%_YES%" exit /b 1
bootrec /fixmbr >nul 2>&1
if errorlevel 1 (
    echo [ERROR] bootrec /fixmbr failed.
    exit /b 1
)
bootrec /fixboot >nul 2>&1
if errorlevel 1 (
    echo [ERROR] bootrec /fixboot failed.
    exit /b 1
)
bcdboot "%WINPATH%" /f BIOS /v >nul 2>&1
if errorlevel 1 (
    echo [ERROR] bcdboot BIOS failed.
    exit /b 1
)
echo [OK] BIOS boot repair complete.
exit /b 0