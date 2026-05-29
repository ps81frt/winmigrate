:: ===========================================================================
:: Nom       : ExportSoftware.bat
:: Projet    : WinMigrate
:: Author    : PS81FRT
:: GitHub    : https://github.com/ps81frt/winmigrate
:: Version   : 1.0.0
:: Licence   : MIT
:: Synopsis  : Export 64-bit installed software list using winget or registry
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
set "LOG_FILE=%TEMP%\WinMigrate_ExportSoftware_%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%.log"
where winget >nul 2>&1
if errorlevel 1 goto :FALLBACK
echo Exporting software list with winget...
winget export -o "%DEST%\SoftwareList_x64.json" --include-versions > "%LOG_FILE%" 2>&1
if errorlevel 1 (
    echo [WARN] winget export failed, falling back to registry. See %LOG_FILE%
    goto :FALLBACK
)
echo [OK] Software list exported to: %DEST%\SoftwareList_x64.json
goto :END
:FALLBACK
echo Exporting software list from registry (fallback)...
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s > "%DEST%\SoftwareList_x64.txt" 2>> "%LOG_FILE%"
echo [OK] Software list exported to: %DEST%\SoftwareList_x64.txt
:END
echo [OK] See %LOG_FILE%
exit /b 0