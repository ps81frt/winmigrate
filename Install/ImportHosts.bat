:: ===========================================================================
:: Nom       : ImportHosts.bat
:: Projet    : WinMigrate
:: Author    : PS81FRT
:: GitHub    : https://github.com/ps81frt/winmigrate
:: Version   : 1.0.0
:: Licence   : MIT
:: Synopsis  : Import a hosts file to replace the system hosts file
:: Usage     : Run as Administrator - arg: [SourceFile]
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
if "%SOURCE%"=="" (
    echo Usage: %~nx0 [SourceFile]
    exit /b 1
)
set "LOG_FILE=%TEMP%\WinMigrate_ImportHosts_%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%.log"
set /p "CONFIRM=Confirm hosts file import from %SOURCE%? (!_YESNO!) : "
if /i not "%CONFIRM%"=="%_YES%" exit /b 1
copy "%SOURCE%" "%windir%\System32\drivers\etc\hosts" > "%LOG_FILE%" 2>&1
if errorlevel 1 (
    echo [ERROR] Hosts file import failed. See %LOG_FILE%
    exit /b 1
)
echo [OK] Hosts file import complete. See %LOG_FILE%
exit /b 0