:: ===========================================================================
:: Nom       : CloneDisk.bat
:: Projet    : WinMigrate
:: Author    : PS81FRT
:: GitHub    : https://github.com/ps81frt/winmigrate
:: Version   : 1.0.0
:: Licence   : MIT
:: Synopsis  : Clone source disk to target using DISM WIM capture and apply
:: Usage     : Run as Administrator - args: [SourceDisk] [TargetDisk]
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
set "SOURCE_DISK=%~1"
set "TARGET_DISK=%~2"
if "%SOURCE_DISK%"=="" (
    echo Usage: %~nx0 [SourceDisk] [TargetDisk]
    exit /b 1
)
if "%TARGET_DISK%"=="" (
    echo Usage: %~nx0 [SourceDisk] [TargetDisk]
    exit /b 1
)
if "%SOURCE_DISK%"=="%TARGET_DISK%" (
    echo [ERROR] Source and target disk index cannot be the same.
    exit /b 1
)
echo Verifying disk IDs (source vs target)...
echo list disk > "%TEMP%\wm_ls.txt"
echo Current disk layout:
diskpart /s "%TEMP%\wm_ls.txt" 2>&1
del "%TEMP%\wm_ls.txt" >nul 2>&1
echo.
set "SRC_DP=%TEMP%\wm_src.txt"
echo select disk %SOURCE_DISK%> "%SRC_DP%"
echo detail disk>> "%SRC_DP%"
for /f "tokens=*" %%L in ('diskpart /s "%SRC_DP%" 2^>nul ^| findstr /i "Disk ID"') do set "SOURCE_SIG=%%L"
del "%SRC_DP%" >nul 2>&1
if "%SOURCE_SIG%"=="" (
    echo [ERROR] Cannot read source disk ID. Verify disk index %SOURCE_DISK% exists.
    exit /b 1
)
set "TGT_DP=%TEMP%\wm_tgt.txt"
echo select disk %TARGET_DISK%> "%TGT_DP%"
echo detail disk>> "%TGT_DP%"
for /f "tokens=*" %%L in ('diskpart /s "%TGT_DP%" 2^>nul ^| findstr /i "Disk ID"') do set "TARGET_SIG=%%L"
del "%TGT_DP%" >nul 2>&1
if "%TARGET_SIG%"=="" (
    echo [ERROR] Cannot read target disk ID. Verify disk index %TARGET_DISK% exists.
    exit /b 1
)
if /i "%SOURCE_SIG%"=="%TARGET_SIG%" (
    echo [ERROR] Source and target have the same disk ID. Cannot clone a disk to itself.
    exit /b 1
)
echo Source disk ID: %SOURCE_SIG%
echo Target disk ID: %TARGET_SIG%
echo [WARN] Confirm target disk size is >= source disk size in the listing above.
set /p "CONFIRM=Confirm clone disk %SOURCE_DISK% to disk %TARGET_DISK%? Target will be WIPED. (Y/N) : "
if /i not "%CONFIRM%"=="%_YES%" exit /b 1
set "LOG_FILE=%TEMP%\WinMigrate_CloneDisk_%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%.log"
echo Capturing system image from C: to temporary WIM... > "%LOG_FILE%"
set "TEMP_WIM=%TEMP%\WinMigrateClone.wim"
dism /Capture-Image /ImageFile:"%TEMP_WIM%" /CaptureDir:C: /Name:"CloneImage" /Compress:Max /CheckIntegrity >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    echo [ERROR] WIM capture failed. See %LOG_FILE%
    exit /b 1
)
echo Preparing target disk layout with DiskPart... >> "%LOG_FILE%"
set "SCRIPT=%TEMP%\CloneDisk_%TARGET_DISK%.txt"
echo select disk %TARGET_DISK%> "%SCRIPT%"
echo clean>> "%SCRIPT%"
echo convert gpt>> "%SCRIPT%"
echo create partition efi size=512>> "%SCRIPT%"
echo format quick fs=fat32 label=EFI>> "%SCRIPT%"
echo assign letter=S>> "%SCRIPT%"
echo create partition msr size=128>> "%SCRIPT%"
echo create partition primary>> "%SCRIPT%"
echo format quick fs=ntfs label=Windows>> "%SCRIPT%"
echo assign letter=W>> "%SCRIPT%"
diskpart /s "%SCRIPT%" >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    echo [ERROR] Target disk preparation failed. See %LOG_FILE%
    del "%SCRIPT%" >nul 2>&1
    exit /b 1
)
echo Applying image to target Windows partition... >> "%LOG_FILE%"
dism /Apply-Image /ImageFile:"%TEMP_WIM%" /Index:1 /ApplyDir:W:\ >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    echo [ERROR] WIM apply failed. See %LOG_FILE%
    del "%SCRIPT%" >nul 2>&1
    exit /b 1
)
echo Repairing UEFI boot on target partition... >> "%LOG_FILE%"
bcdboot W:\Windows /s S: /f UEFI >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    echo [ERROR] Boot repair failed. See %LOG_FILE%
    del "%SCRIPT%" >nul 2>&1
    exit /b 1
)
del "%SCRIPT%" >nul 2>&1
del "%TEMP_WIM%" >nul 2>&1
echo [OK] Disk clone complete. See %LOG_FILE%
exit /b 0