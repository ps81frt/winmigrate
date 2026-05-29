:: ===========================================================================
:: Nom       : ConvertMbrToGpt.bat
:: Projet    : WinMigrate
:: Author    : PS81FRT
:: GitHub    : https://github.com/ps81frt/winmigrate
:: Version   : 1.0.0
:: Licence   : MIT
:: Synopsis  : Convert a MBR disk to GPT using MBR2GPT (non-destructive)
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
where MBR2GPT >nul 2>&1
if errorlevel 1 (
    if /i "%WINMIGRATE_LANG%"=="FR" (echo [ERREUR] MBR2GPT introuvable. Windows 10 build 15063+ requis.) else (echo [ERROR] MBR2GPT not found. Windows 10 build 15063+ required.)
    exit /b 1
)
for /f "tokens=3" %%B in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild 2^>nul') do set "_BUILD=%%B"
if defined _BUILD (
    if !_BUILD! LSS 15063 (
        if /i "%WINMIGRATE_LANG%"=="FR" (echo [ERREUR] Build Windows !_BUILD! detecte. MBR2GPT requiert build 15063 minimum.) else (echo [ERROR] Windows build !_BUILD! detected. MBR2GPT requires build 15063 minimum.)
        exit /b 1
    )
)
set "DISK=%~1"
if "%DISK%"=="" (
    if /i "%WINMIGRATE_LANG%"=="FR" (echo Usage: %~nx0 [IndexDisque]) else (echo Usage: %~nx0 [DiskIndex])
    exit /b 1
)
if /i "%WINMIGRATE_LANG%"=="FR" (echo Validation MBR2GPT sur le disque %DISK%...) else (echo Validating MBR2GPT on disk %DISK%...)
MBR2GPT /validate /disk:%DISK%
if errorlevel 1 (
    if /i "%WINMIGRATE_LANG%"=="FR" (echo [ERREUR] Validation MBR2GPT echouee sur le disque %DISK%.) else (echo [ERROR] MBR2GPT validation failed on disk %DISK%. Disk may not be convertible.)
    exit /b 1
)
if /i "%WINMIGRATE_LANG%"=="FR" (
    set /p "CONFIRM=Confirmer la conversion MBR vers GPT du disque %DISK% ? (%_YESNO%) : "
) else (
    set /p "CONFIRM=Confirm MBR to GPT conversion for disk %DISK%? Data will be preserved. (%_YESNO%) : "
)
if /i not "%CONFIRM%"=="%_YES%" exit /b 1
MBR2GPT /convert /disk:%DISK%
if errorlevel 1 (
    if /i "%WINMIGRATE_LANG%"=="FR" (echo [ERREUR] Conversion MBR2GPT echouee sur le disque %DISK%.) else (echo [ERROR] MBR2GPT conversion failed on disk %DISK%.)
    exit /b 1
)
if /i "%WINMIGRATE_LANG%"=="FR" (echo [OK] Conversion MBR2GPT reussie.) else (echo [OK] MBR2GPT conversion successful.)
exit /b 0