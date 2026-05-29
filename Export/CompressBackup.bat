:: ===========================================================================
:: Nom       : CompressBackup.bat
:: Projet    : WinMigrate
:: Author    : PS81FRT
:: GitHub    : https://github.com/ps81frt/winmigrate
:: Version   : 1.0.0
:: Licence   : MIT
:: Synopsis  : Compress a backup folder using 7-Zip or tar (timestamped archive)
:: Usage     : Run as Administrator - args: [SourceFolder] [DestinationFolder]
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
set "DEST=%~2"
if "%SOURCE%"=="" (
    echo Usage: %~nx0 [SourceFolder] [DestinationFolder]
    exit /b 1
)
if "%DEST%"=="" set "DEST=%~dp1"
if not exist "%DEST%" mkdir "%DEST%"
set "LOG_FILE=%TEMP%\WinMigrate_CompressBackup_%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%.log"
set "STAMP=%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%"
set "STAMP=%STAMP: =0%"
set "ARCHIVE=%DEST%\WinMigrateBackup_%STAMP%"
set /p "CONFIRM=Confirm compression of %SOURCE% to %ARCHIVE%? (!_YESNO!) : "
if /i not "%CONFIRM%"=="%_YES%" exit /b 1
set "SEVENZIP=%ProgramFiles%\7-Zip\7z.exe"
if not exist "%SEVENZIP%" set "SEVENZIP=%ProgramFiles(x86)%\7-Zip\7z.exe"
if exist "%SEVENZIP%" (
    echo Using 7-Zip...
    "%SEVENZIP%" a -t7z "%ARCHIVE%.7z" "%SOURCE%\*" -mx5 >> "%LOG_FILE%" 2>&1
    if errorlevel 1 (
        echo [ERROR] 7-Zip compression failed. See %LOG_FILE%
        exit /b 1
    )
    echo [OK] Archive created: %ARCHIVE%.7z
    goto :END
)
where tar >nul 2>&1
if errorlevel 1 goto :NOTOOL
echo Using tar (Windows built-in)...
tar -czf "%ARCHIVE%.tgz" -C "%SOURCE%" . >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    echo [ERROR] tar compression failed. See %LOG_FILE%
    exit /b 1
)
echo [OK] Archive created: %ARCHIVE%.tgz
goto :END
:NOTOOL
echo [ERROR] No compression tool found. Install 7-Zip or use Windows 10 1903+.
exit /b 1
:END
echo [OK] See %LOG_FILE%
exit /b 0