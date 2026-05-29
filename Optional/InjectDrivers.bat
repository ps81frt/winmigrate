:: ===========================================================================
:: Nom       : InjectDrivers.bat
:: Projet    : WinMigrate
:: Author    : PS81FRT
:: GitHub    : https://github.com/ps81frt/winmigrate
:: Version   : 1.0.0
:: Licence   : MIT
:: Synopsis  : Inject drivers into an offline Windows image using DISM
:: Usage     : Run as Administrator - args: [OfflineImagePath] [DriverFolder]
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
set "IMAGE=%~1"
set "DRIVERS=%~2"
if "%IMAGE%"=="" if "%DRIVERS%"=="" (
    echo Usage: %~nx0 [OfflineImagePath] [DriverFolder]
    exit /b 1
)
set "LOG_FILE=%TEMP%\WinMigrate_InjectDrivers_%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%.log"
set /p "CONFIRM=Confirm driver injection into %IMAGE% from %DRIVERS%? (!_YESNO!) : "
if /i not "%CONFIRM%"=="%_YES%" exit /b 1
dism /Image:"%IMAGE%" /Add-Driver /Driver:"%DRIVERS%" /Recurse >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    echo [ERROR] Driver injection failed. See %LOG_FILE%
    exit /b 1
)
echo [OK] Driver injection complete. See %LOG_FILE%
exit /b 0