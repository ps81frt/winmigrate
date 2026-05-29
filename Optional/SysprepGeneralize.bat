:: ===========================================================================
:: Nom       : SysprepGeneralize.bat
:: Projet    : WinMigrate
:: Author    : PS81FRT
:: GitHub    : https://github.com/ps81frt/winmigrate
:: Version   : 1.0.0
:: Licence   : MIT
:: Synopsis  : Run Sysprep /generalize /shutdown /oobe to prepare for deployment
:: Usage     : Run as Administrator - WARNING: this will shut down the machine
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
echo [WARN] Sysprep /generalize will remove machine-specific information.
echo [WARN] The system will SHUT DOWN after Sysprep completes.
set /p "CONFIRM=Confirm Sysprep generalize + shutdown? (!_YESNO!) : "
if /i not "%CONFIRM%"=="%_YES%" exit /b 1
"%WINDIR%\System32\Sysprep\sysprep.exe" /generalize /shutdown /oobe
if errorlevel 1 (
    echo [ERROR] Sysprep failed.
    exit /b 1
)
exit /b 0