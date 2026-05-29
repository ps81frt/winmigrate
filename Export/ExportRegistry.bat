:: ===========================================================================
:: Nom       : ExportRegistry.bat
:: Projet    : WinMigrate
:: Author    : PS81FRT
:: GitHub    : https://github.com/ps81frt/winmigrate
:: Version   : 1.0.0
:: Licence   : MIT
:: Synopsis  : Export full registry hives (HKLM/HKCU/HKCR/HKU/HKCC) as backup
:: Usage     : Run as Administrator - optional arg: [DestinationFolder]
:: WARNING   : HKLM export can exceed several GB. Ensure enough disk space.
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
set "REGDEST=%DEST%\Registry_%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%"
if not exist "%REGDEST%" mkdir "%REGDEST%"
set "LOG_FILE=%TEMP%\WinMigrate_ExportRegistry_%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%.log"
echo [WARN] Full registry export (HKLM included) can be very large (several GB).
set /p "CONFIRM=Confirm full registry backup to %REGDEST%? (!_YESNO!) : "
if /i not "%CONFIRM%"=="%_YES%" exit /b 1
echo Exporting HKCU...
reg export HKCU "%REGDEST%\HKCU.reg" /y >> "%LOG_FILE%" 2>&1
echo Exporting HKLM (may take minutes)...
reg export HKLM "%REGDEST%\HKLM.reg" /y >> "%LOG_FILE%" 2>&1
echo Exporting HKCR...
reg export HKCR "%REGDEST%\HKCR.reg" /y >> "%LOG_FILE%" 2>&1
echo Exporting HKU...
reg export HKU "%REGDEST%\HKU.reg" /y >> "%LOG_FILE%" 2>&1
echo Exporting HKCC...
reg export HKCC "%REGDEST%\HKCC.reg" /y >> "%LOG_FILE%" 2>&1
echo [OK] Registry export complete. See %LOG_FILE%
echo [OK] Files saved to: %REGDEST%
exit /b 0