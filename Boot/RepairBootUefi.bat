:: ===========================================================================
:: Nom       : RepairBootUefi.bat
:: Projet    : WinMigrate
:: Author    : PS81FRT
:: GitHub    : https://github.com/ps81frt/winmigrate
:: Version   : 1.0.0
:: Licence   : MIT
:: Synopsis  : Repair UEFI boot using bcdboot targeting the EFI partition
:: Usage     : Run as Administrator - args: [WindowsPath] [EFI_Letter]
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
set "WINPATH=%~1"
if "%WINPATH%"=="" set "WINPATH=C:\Windows"
set "EFI_LETTER=%~2"
if "%EFI_LETTER%"=="" (
    echo Searching for EFI partition...
    echo list vol > "%TEMP%\wm_listvol.txt"
    for /f "skip=8 tokens=2,4,8" %%A in ('diskpart /s "%TEMP%\wm_listvol.txt" 2^>nul') do (
        if /i "%%C"=="System" (
            if not "%%A"=="" set "EFI_LETTER=%%A"
        )
    )
    del "%TEMP%\wm_listvol.txt" >nul 2>&1
)
if "%EFI_LETTER%"=="" (
    echo [ERROR] EFI partition not found. Specify drive letter as second argument.
    exit /b 1
)
echo EFI partition: %EFI_LETTER%:
set /p "CONFIRM=Confirm UEFI boot repair for %WINPATH% on %EFI_LETTER%:? (!_YESNO!) : "
if /i not "%CONFIRM%"=="%_YES%" exit /b 1
bcdboot "%WINPATH%" /s %EFI_LETTER%: /f UEFI /v
if errorlevel 1 (
    echo [ERROR] bcdboot UEFI failed.
    exit /b 1
)
echo [OK] UEFI boot repair complete.
exit /b 0