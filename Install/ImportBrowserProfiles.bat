:: ===========================================================================
:: Nom       : ImportBrowserProfiles.bat
:: Projet    : WinMigrate
:: Author    : PS81FRT
:: GitHub    : https://github.com/ps81frt/winmigrate
:: Version   : 1.0.0
:: Licence   : MIT
:: Synopsis  : Restore Chrome, Edge, and Firefox browser profiles from backup
:: Usage     : Run as Administrator - arg: [SourceFolder\BrowserProfiles]
:: WARNING   : Close all browsers before running this script
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
    echo Usage: %~nx0 [SourceFolder]
    exit /b 1
)
set "LOG_FILE=%TEMP%\WinMigrate_ImportBrowserProfiles_%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%.log"
echo [WARN] Close Chrome, Edge, and Firefox before continuing.
set /p "CONFIRM=Confirm browsers are closed and import can start? (!_YESNO!) : "
if /i not "%CONFIRM%"=="%_YES%" exit /b 1
set "CHROME_DEST=%LOCALAPPDATA%\Google\Chrome\User Data"
set "EDGE_DEST=%LOCALAPPDATA%\Microsoft\Edge\User Data"
set "FIREFOX_DEST=%APPDATA%\Mozilla\Firefox\Profiles"
if exist "%SOURCE%\Chrome" (
    echo Restoring Chrome profile...
    robocopy "%SOURCE%\Chrome" "%CHROME_DEST%" /MIR /R:2 /W:5 /LOG+:"%LOG_FILE%" 2>&1
) else (
    echo [INFO] No Chrome backup found, skipping.
)
if exist "%SOURCE%\Edge" (
    echo Restoring Edge profile...
    robocopy "%SOURCE%\Edge" "%EDGE_DEST%" /MIR /R:2 /W:5 /LOG+:"%LOG_FILE%" 2>&1
) else (
    echo [INFO] No Edge backup found, skipping.
)
if exist "%SOURCE%\Firefox" (
    echo Restoring Firefox profiles...
    robocopy "%SOURCE%\Firefox" "%FIREFOX_DEST%" /MIR /R:2 /W:5 /LOG+:"%LOG_FILE%" 2>&1
) else (
    echo [INFO] No Firefox backup found, skipping.
)
echo [OK] Browser profile import complete. See %LOG_FILE%
exit /b 0