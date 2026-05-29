:: ===========================================================================
:: Nom       : CaptureWim.bat
:: Projet    : WinMigrate
:: Author    : PS81FRT
:: GitHub    : https://github.com/ps81frt/winmigrate
:: Version   : 1.0.0
:: Licence   : MIT
:: Synopsis  : Capture a directory or drive as a WIM image using DISM
:: Usage     : Run as Administrator - args: [SourceDirectory] [ImageFile.wim]
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
set "SOURCE=%~1"
set "DEST=%~2"
if "%SOURCE%"=="" if "%DEST%"=="" (
    echo Usage: %~nx0 [SourceDirectory] [ImageFile.wim]
    exit /b 1
)
set /p "CONFIRM=Confirm capture of %SOURCE% to %DEST%? (!_YESNO!) : "
if /i not "%CONFIRM%"=="%_YES%" exit /b 1
set "LOG_FILE=%TEMP%\WinMigrate_CaptureWim_%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%.log"
dism /Capture-Image /ImageFile:"%DEST%" /CaptureDir:"%SOURCE%" /Name:"WindowsImage" /Compress:Max /CheckIntegrity >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    echo [ERROR] WIM capture failed. See %LOG_FILE%
    exit /b 1
)
echo [OK] WIM capture complete. See %LOG_FILE%
exit /b 0