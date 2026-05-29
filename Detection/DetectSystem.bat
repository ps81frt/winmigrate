:: ===========================================================================
:: Nom       : DetectSystem.bat
:: Projet    : WinMigrate
:: Author    : PS81FRT
:: GitHub    : https://github.com/ps81frt/winmigrate
:: Version   : 1.0.0
:: Licence   : MIT
:: Synopsis  : Detect OS version, architecture, and disk layout
:: Usage     : Run as Administrator
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
echo ===========================
echo  System Information
echo ===========================
ver
echo.
echo Computer  : %COMPUTERNAME%
echo Username  : %USERNAME%
echo OS Arch   : %PROCESSOR_ARCHITECTURE%
echo.
echo Windows Product Name:
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName 2>nul | findstr ProductName
echo Windows Build:
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild 2>nul | findstr CurrentBuild
echo Windows Version:
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v DisplayVersion 2>nul | findstr DisplayVersion
echo.
echo === Disk Layout ===
echo list disk > "%TEMP%\wm_ds.txt"
diskpart /s "%TEMP%\wm_ds.txt" 2>&1
del "%TEMP%\wm_ds.txt" >nul 2>&1
exit /b 0