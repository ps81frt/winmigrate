:: ===========================================================================
:: Nom       : ExportBrowserProfiles.bat
:: Projet    : WinMigrate
:: Author    : PS81FRT
:: GitHub    : https://github.com/ps81frt/winmigrate
:: Version   : 1.0.0
:: Licence   : MIT
:: Synopsis  : Export Chrome, Edge, and Firefox browser profile folders
:: Usage     : Run as Administrator - optional arg: [DestinationFolder]
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
set "DEST=%~1"
if "%DEST%"=="" set "DEST=%USERPROFILE%\Desktop\WinMigrate_Backup"
set "BRDEST=%DEST%\BrowserProfiles"
if not exist "%BRDEST%" mkdir "%BRDEST%"
set "LOG_FILE=%TEMP%\WinMigrate_ExportBrowserProfiles_%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%.log"
echo [WARN] Close Chrome, Edge, and Firefox before continuing.
set /p "CONFIRM=Confirm browsers are closed and export can start? (!_YESNO!) : "
if /i not "%CONFIRM%"=="%_YES%" exit /b 1
set "CHROME_SRC=%LOCALAPPDATA%\Google\Chrome\User Data"
set "EDGE_SRC=%LOCALAPPDATA%\Microsoft\Edge\User Data"
set "FIREFOX_SRC=%APPDATA%\Mozilla\Firefox\Profiles"
if exist "%CHROME_SRC%" (
    echo Exporting Chrome profile...
    robocopy "%CHROME_SRC%" "%BRDEST%\Chrome" /MIR /R:2 /W:5 /XD "Cache" "Code Cache" "GPUCache" "ShaderCache" "CacheStorage" /LOG+:"%LOG_FILE%" 2>&1
) else (
    echo [INFO] Chrome profile not found, skipping.
)
if exist "%EDGE_SRC%" (
    echo Exporting Edge profile...
    robocopy "%EDGE_SRC%" "%BRDEST%\Edge" /MIR /R:2 /W:5 /XD "Cache" "Code Cache" "GPUCache" "ShaderCache" "CacheStorage" /LOG+:"%LOG_FILE%" 2>&1
) else (
    echo [INFO] Edge profile not found, skipping.
)
if exist "%FIREFOX_SRC%" (
    echo Exporting Firefox profiles...
    robocopy "%FIREFOX_SRC%" "%BRDEST%\Firefox" /MIR /R:2 /W:5 /LOG+:"%LOG_FILE%" 2>&1
) else (
    echo [INFO] Firefox profiles not found, skipping.
)
echo [OK] Browser profile export complete. See %LOG_FILE%
exit /b 0