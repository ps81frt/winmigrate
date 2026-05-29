:: ===========================================================================
:: Nom       : ExportProductKey.bat
:: Projet    : WinMigrate
:: Author    : PS81FRT
:: GitHub    : https://github.com/ps81frt/winmigrate
:: Version   : 1.0.0
:: Licence   : MIT
:: Synopsis  : Export Windows product key information and license details
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
set "LOG_FILE=%TEMP%\WinMigrate_ExportProductKey_%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%.log"
set "OUT=%DEST%\ProductKey_%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%.txt"
echo === WinMigrate ProductKey Export === > "%OUT%"
echo Date: %DATE% %TIME% >> "%OUT%"
echo. >> "%OUT%"
echo --- Windows License Info (slmgr /dli) --- >> "%OUT%"
cscript //nologo "%WINDIR%\system32\slmgr.vbs" /dli >> "%OUT%" 2>&1
echo. >> "%OUT%"
echo --- Windows License Expiry (slmgr /xpr) --- >> "%OUT%"
cscript //nologo "%WINDIR%\system32\slmgr.vbs" /xpr >> "%OUT%" 2>&1
echo. >> "%OUT%"
echo --- Registry ProductId --- >> "%OUT%"
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductId >> "%OUT%" 2>&1
echo. >> "%OUT%"
echo --- Registry ProductName --- >> "%OUT%"
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName >> "%OUT%" 2>&1
echo. >> "%OUT%"
echo --- Registry EditionID --- >> "%OUT%"
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v EditionID >> "%OUT%" 2>&1
echo [OK] Product key info exported to: %OUT%
exit /b 0