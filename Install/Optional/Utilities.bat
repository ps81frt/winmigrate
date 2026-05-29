:: ===========================================================================
:: Nom       : Utilities.bat
:: Projet    : WinMigrate
:: Author    : PS81FRT
:: GitHub    : https://github.com/ps81frt/winmigrate
:: Version   : 1.0.0
:: Licence   : MIT
:: Synopsis  : Install optional common utilities using winget
:: Usage     : Run as Administrator - interactive menu
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
where winget >nul 2>&1
if errorlevel 1 (
    echo [ERROR] winget is not available on this system.
    exit /b 1
)
set "LOG_FILE=%TEMP%\WinMigrate_Utilities_%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%.log"
:MENU
cls
echo ===================================================
echo    WinMigrate - Optional Utilities Installer
echo ===================================================
echo.
echo  [1] 7-Zip             - File archiver
echo  [2] Notepad++         - Text editor
echo  [3] VLC               - Media player
echo  [4] Google Chrome     - Web browser
echo  [5] Mozilla Firefox   - Web browser
echo  [6] Git               - Version control
echo  [7] Visual Studio Code - Code editor
echo  [8] Python 3          - Programming language
echo  [9] Node.js (LTS)     - JavaScript runtime
echo  [A] Install ALL above
echo  [0] Exit
echo.
set /p "CHOICE=Select an option: "
if /i "%CHOICE%"=="1" (
    winget install --id 7zip.7zip -e --silent >> "%LOG_FILE%" 2>&1 && echo [OK] 7-Zip installed. || echo [ERROR] Failed.
    goto :MENU
)
if /i "%CHOICE%"=="2" (
    winget install --id Notepad++.Notepad++ -e --silent >> "%LOG_FILE%" 2>&1 && echo [OK] Notepad++ installed. || echo [ERROR] Failed.
    goto :MENU
)
if /i "%CHOICE%"=="3" (
    winget install --id VideoLAN.VLC -e --silent >> "%LOG_FILE%" 2>&1 && echo [OK] VLC installed. || echo [ERROR] Failed.
    goto :MENU
)
if /i "%CHOICE%"=="4" (
    winget install --id Google.Chrome -e --silent >> "%LOG_FILE%" 2>&1 && echo [OK] Chrome installed. || echo [ERROR] Failed.
    goto :MENU
)
if /i "%CHOICE%"=="5" (
    winget install --id Mozilla.Firefox -e --silent >> "%LOG_FILE%" 2>&1 && echo [OK] Firefox installed. || echo [ERROR] Failed.
    goto :MENU
)
if /i "%CHOICE%"=="6" (
    winget install --id Git.Git -e --silent >> "%LOG_FILE%" 2>&1 && echo [OK] Git installed. || echo [ERROR] Failed.
    goto :MENU
)
if /i "%CHOICE%"=="7" (
    winget install --id Microsoft.VisualStudioCode -e --silent >> "%LOG_FILE%" 2>&1 && echo [OK] VS Code installed. || echo [ERROR] Failed.
    goto :MENU
)
if /i "%CHOICE%"=="8" (
    winget install --id Python.Python.3 -e --silent >> "%LOG_FILE%" 2>&1 && echo [OK] Python 3 installed. || echo [ERROR] Failed.
    goto :MENU
)
if /i "%CHOICE%"=="9" (
    winget install --id OpenJS.NodeJS.LTS -e --silent >> "%LOG_FILE%" 2>&1 && echo [OK] Node.js installed. || echo [ERROR] Failed.
    goto :MENU
)
if /i "%CHOICE%"=="A" (
    winget install --id 7zip.7zip -e --silent >> "%LOG_FILE%" 2>&1
    winget install --id Notepad++.Notepad++ -e --silent >> "%LOG_FILE%" 2>&1
    winget install --id VideoLAN.VLC -e --silent >> "%LOG_FILE%" 2>&1
    winget install --id Google.Chrome -e --silent >> "%LOG_FILE%" 2>&1
    winget install --id Mozilla.Firefox -e --silent >> "%LOG_FILE%" 2>&1
    winget install --id Git.Git -e --silent >> "%LOG_FILE%" 2>&1
    winget install --id Microsoft.VisualStudioCode -e --silent >> "%LOG_FILE%" 2>&1
    winget install --id Python.Python.3 -e --silent >> "%LOG_FILE%" 2>&1
    winget install --id OpenJS.NodeJS.LTS -e --silent >> "%LOG_FILE%" 2>&1
    echo [OK] All utilities installation complete. See %LOG_FILE%
    goto :MENU
)
if "%CHOICE%"=="0" exit /b 0
echo [ERROR] Invalid option.
goto :MENU