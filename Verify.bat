:: ===========================================================================
:: Nom       : Verify.bat
:: Projet    : WinMigrate
:: Author    : PS81FRT
:: GitHub    : https://github.com/ps81frt/winmigrate
:: Version   : 1.0.0
:: Licence   : MIT
:: Synopsis  : Verify that all required WinMigrate project files are present
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
    echo [ERROR] Verification requires administrator rights.
    exit /b 1
)
:ADMIN_OK
set "BASE=%~dp0"
pushd "%BASE%" >nul 2>&1 || (
    echo [ERROR] Unable to access project folder %BASE%
    exit /b 1
)
set "LOG_TIME=%TIME: =0%"
set "LOG_FILE=%TEMP%\WinMigrate_Verify_%LOG_TIME:~0,2%%LOG_TIME:~3,2%%LOG_TIME:~6,2%_%RANDOM%.log"
set "TOTAL=0"
if /i "%WINMIGRATE_LANG%"=="FR" (
    echo Rapport de verification WinMigrate > "%LOG_FILE%"
) else (
    echo WinMigrate Verification Report > "%LOG_FILE%"
)
echo Date: %DATE% %TIME% >> "%LOG_FILE%"
echo Base: %BASE% >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"
for /r "%BASE%" %%F in (*.bat *.md) do (
    set /a TOTAL+=1
    set "_REL=%%F"
    set "_REL=!_REL:%BASE%=!"
    echo [OK] !_REL!
    echo [OK] !_REL! >> "%LOG_FILE%"
    certutil -hashfile "%%F" SHA256 2>nul | findstr /r "^[0-9a-fA-F]" >> "%LOG_FILE%"
)
echo.
if /i "%WINMIGRATE_LANG%"=="FR" (
    echo [OK] %TOTAL% fichiers trouves et verifies. Rapport : %LOG_FILE%
) else (
    echo [OK] %TOTAL% files found and verified. Report: %LOG_FILE%
)
popd >nul 2>&1
exit /b 0
