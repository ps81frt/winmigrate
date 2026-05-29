:: ===========================================================================
:: Nom       : CreateLegacyLayout.bat
:: Projet    : WinMigrate
:: Author    : PS81FRT
:: GitHub    : https://github.com/ps81frt/winmigrate
:: Version   : 1.0.0
:: Licence   : MIT
:: Synopsis  : Create a Legacy BIOS MBR partition layout on a disk
:: Usage     : Run as Administrator - arg: [DiskIndex]
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
set "DISK=%~1"
if "%DISK%"=="" (
    echo Usage: %~nx0 [DiskIndex]
    exit /b 1
)
set /p "CONFIRM=Confirm creation of MBR BIOS layout on disk %DISK%? ALL DATA WILL BE LOST. (Y/N) : "
if /i not "%CONFIRM%"=="%_YES%" exit /b 1
set "SCRIPT=%TEMP%\wm_legacy_%DISK%.txt"
echo select disk %DISK%> "%SCRIPT%"
echo clean>> "%SCRIPT%"
echo convert mbr>> "%SCRIPT%"
echo create partition primary>> "%SCRIPT%"
echo format quick fs=ntfs label=Windows>> "%SCRIPT%"
echo assign letter=W>> "%SCRIPT%"
diskpart /s "%SCRIPT%" 2>&1
if errorlevel 1 (
    echo [ERROR] Legacy BIOS layout creation failed on disk %DISK%.
    del "%SCRIPT%" >nul 2>&1
    exit /b 1
)
del "%SCRIPT%" >nul 2>&1
echo [OK] Legacy BIOS layout created on disk %DISK%.
exit /b 0