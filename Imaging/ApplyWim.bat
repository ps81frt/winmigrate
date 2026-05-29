:: ===========================================================================
:: Nom       : ApplyWim.bat
:: Projet    : WinMigrate
:: Author    : PS81FRT
:: GitHub    : https://github.com/ps81frt/winmigrate
:: Version   : 1.0.0
:: Licence   : MIT
:: Synopsis  : Apply a WIM image to a target drive using DISM
:: Usage     : Run as Administrator - args: [WIMFile] [Index] [TargetDrive]
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
set "WIM=%~1"
set "INDEX=%~2"
set "TARGET=%~3"
if "%WIM%"=="" if "%TARGET%"=="" (
    echo Usage: %~nx0 [WIMFile] [Index] [TargetDrive]
    exit /b 1
)
if "%INDEX%"=="" set "INDEX=1"
set "LOG_FILE=%TEMP%\WinMigrate_ApplyWim_%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%.log"
set /p "CONFIRM=Confirm applying %WIM% index %INDEX% to %TARGET%? (!_YESNO!) : "
if /i not "%CONFIRM%"=="%_YES%" exit /b 1
dism /Apply-Image /ImageFile:"%WIM%" /Index:%INDEX% /ApplyDir:%TARGET%\ >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    echo [ERROR] WIM apply failed. See %LOG_FILE%
    exit /b 1
)
echo [OK] WIM apply complete. See %LOG_FILE%
exit /b 0