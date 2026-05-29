:: ===========================================================================
:: Nom       : ExportFirewall.bat
:: Projet    : WinMigrate
:: Author    : PS81FRT
:: GitHub    : https://github.com/ps81frt/winmigrate
:: Version   : 1.0.0
:: Licence   : MIT
:: Synopsis  : Export Windows Firewall rules to a .wfw file using netsh
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
set "LOG_FILE=%TEMP%\WinMigrate_ExportFirewall_%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%.log"
set "OUT=%DEST%\FirewallRules.wfw"
if /i "%WINMIGRATE_LANG%"=="FR" (
    set /p "CONFIRM=Confirmer l export des regles pare-feu vers %DEST%? (!_YESNO!) : "
) else (
    set /p "CONFIRM=Confirm firewall rules export to %DEST%? (!_YESNO!) : "
)
if /i not "%CONFIRM%"=="%_YES%" exit /b 1
netsh advfirewall export "%OUT%" > "%LOG_FILE%" 2>&1
if errorlevel 1 (
    if /i "%WINMIGRATE_LANG%"=="FR" (echo [ERREUR] Export pare-feu echoue. Voir %LOG_FILE%) else (echo [ERROR] Firewall export failed. See %LOG_FILE%)
    exit /b 1
)
if /i "%WINMIGRATE_LANG%"=="FR" (
    echo [OK] Regles pare-feu exportees vers : %OUT%
    echo [OK] Voir %LOG_FILE%
) else (
    echo [OK] Firewall rules exported to: %OUT%
    echo [OK] See %LOG_FILE%
)
exit /b 0