:: ===========================================================================
:: Nom       : CreateBootableUsb.bat
:: Projet    : WinMigrate
:: Author    : PS81FRT
:: GitHub    : https://github.com/ps81frt/winmigrate
:: Version   : 1.0.0
:: Licence   : MIT
:: Synopsis  : Create a bootable Windows USB drive from an ISO mount point
:: Usage     : Run as Administrator - args: [SourcePath] [USBDisk]
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
set "SOURCE=%~1"
set "USBDISK=%~2"
if "%SOURCE%"=="" if "%USBDISK%"=="" (
    echo Usage: %~nx0 [SourcePath] [USBDisk]
    echo   SourcePath : path to mounted ISO or Windows setup files
    echo   USBDisk    : disk index of USB drive (from ListDisks.bat)
    exit /b 1
)
set "LOG_FILE=%TEMP%\WinMigrate_CreateUSB_%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%.log"
echo Current disk layout:
echo list disk > "%TEMP%\wm_usb_ls.txt"
diskpart /s "%TEMP%\wm_usb_ls.txt" 2>&1
del "%TEMP%\wm_usb_ls.txt" >nul 2>&1
echo.
echo [WARN] USB disk %USBDISK% will be WIPED and formatted as FAT32.
set /p "CONFIRM=Confirm creation of bootable USB on disk %USBDISK% from %SOURCE%? (!_YESNO!) : "
if /i not "%CONFIRM%"=="%_YES%" exit /b 1
set "SCRIPT=%TEMP%\wm_usb_%USBDISK%.txt"
echo select disk %USBDISK%> "%SCRIPT%"
echo clean>> "%SCRIPT%"
echo create partition primary>> "%SCRIPT%"
echo format quick fs=fat32 label=WINPE>> "%SCRIPT%"
echo assign letter=U>> "%SCRIPT%"
echo active>> "%SCRIPT%"
diskpart /s "%SCRIPT%" >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    echo [ERROR] USB disk preparation failed. See %LOG_FILE%
    del "%SCRIPT%" >nul 2>&1
    exit /b 1
)
del "%SCRIPT%" >nul 2>&1
echo Copying Windows files to USB (this may take several minutes)...
robocopy "%SOURCE%" U:\ /MIR /R:2 /W:5 /LOG+:"%LOG_FILE%" 2>&1
if errorlevel 1 (
    echo [WARN] Some files may not have been copied. Check %LOG_FILE%
)
bootsect /nt60 U: /mbr >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    echo [WARN] bootsect failed. USB may not be bootable on BIOS systems.
)
echo [OK] Bootable USB creation complete. See %LOG_FILE%
exit /b 0