:: ===========================================================================
:: Nom       : WinMigrate.bat
:: Projet    : WinMigrate
:: Author    : PS81FRT
:: GitHub    : https://github.com/ps81frt/winmigrate
:: Version   : 1.0.0
:: Licence   : MIT
:: Synopsis  : Main launcher - Windows migration toolkit menu (EN/FR)
:: Usage     : Run as Administrator
:: ===========================================================================
@echo off
chcp 437 > nul
setlocal enabledelayedexpansion
net session >nul 2>&1
if not errorlevel 1 goto :ADMIN_OK
fsutil dirty query %SystemDrive% >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Administrator rights required.
    exit /b 1
)
:ADMIN_OK

:: ?????? Language auto-detection from system locale ??????
if not defined WINMIGRATE_LANG (
    for /f "tokens=3" %%L in ('reg query "HKCU\Control Panel\International" /v LocaleName 2^>nul') do set "_WML=%%L"
    if "!_WML:~0,2!"=="fr" (set "WINMIGRATE_LANG=FR") else (set "WINMIGRATE_LANG=EN")
    set "_WML="
)
if /i "%WINMIGRATE_LANG%"=="FR" (set "_YES=O" & set "_YESNO=O/N") else (set "_YES=Y" & set "_YESNO=Y/N")

:: ?????? Language selection screen ??????
:LANG_SELECT
cls
echo =============================================
echo   WinMigrate
echo =============================================
echo.
if /i "%WINMIGRATE_LANG%"=="FR" (
    echo  Langue detectee : Francais [FR]
    echo  Tapez EN pour passer en anglais, ou appuyez sur ENTREE.
) else (
    echo  Detected language: English [EN]
    echo  Type FR to switch to French, or press ENTER.
)
echo.
set /p "_LANGCHOICE=Language / Langue [EN/FR] : "
if /i "!_LANGCHOICE!"=="FR" set "WINMIGRATE_LANG=FR"
if /i "!_LANGCHOICE!"=="EN" set "WINMIGRATE_LANG=EN"
if /i "%WINMIGRATE_LANG%"=="FR" (set "_YES=O" & set "_YESNO=O/N") else (set "_YES=Y" & set "_YESNO=Y/N")

:: ?????? MAIN MENU ??????
:MENU
cls
if /i "%WINMIGRATE_LANG%"=="FR" goto :MENU_FR
echo =============================================
echo   WinMigrate - Windows Migration Toolkit
echo =============================================
echo  [1] Detect system information
echo  [2] Disk operations
echo  [3] Imaging (WIM)
echo  [4] Boot repair
echo  [5] EXPORT data  (old PC)
echo  [6] INSTALL / IMPORT data  (new PC)
echo  [7] Optional tools
echo  [8] Verify project integrity
echo  [9] GUIDED MIGRATION  (full workflow)
echo  [0] Exit
echo =============================================
set /p "CHOICE=Select: "
goto :MENU_HANDLE
:MENU_FR
echo =============================================
echo   WinMigrate - Outil de Migration Windows
echo =============================================
echo  [1] Informations systeme
echo  [2] Operations disque
echo  [3] Imagerie (WIM)
echo  [4] Reparation boot
echo  [5] EXPORTER les donnees  (ancien PC)
echo  [6] INSTALLER / IMPORTER  (nouveau PC)
echo  [7] Outils optionnels
echo  [8] Verifier l integrite du projet
echo  [9] MIGRATION GUIDEE  (workflow complet)
echo  [0] Quitter
echo =============================================
set /p "CHOICE=Selectionner : "
:MENU_HANDLE
if "!CHOICE!"=="1" goto DETECT_MENU
if "!CHOICE!"=="2" goto DISK_MENU
if "!CHOICE!"=="3" goto IMAGING_MENU
if "!CHOICE!"=="4" goto BOOT_MENU
if "!CHOICE!"=="5" goto EXPORT_MENU
if "!CHOICE!"=="6" goto INSTALL_MENU
if "!CHOICE!"=="7" goto OPTIONAL_MENU
if "!CHOICE!"=="8" ( call "%~dp0Verify.bat" & pause & goto MENU )
if "!CHOICE!"=="9" goto MIGRATION_MENU
if "!CHOICE!"=="0" exit /b 0
goto MENU

:: ?????? DETECT MENU ??????
:DETECT_MENU
cls
if /i "%WINMIGRATE_LANG%"=="FR" goto :DETECT_MENU_FR
echo =============================================
echo   Detection
echo =============================================
echo  [1] Full system info (OS, arch, disks)
echo  [2] Firmware type (UEFI or Legacy)
echo  [3] BitLocker status
echo  [4] Windows build number
echo  [0] Back
echo =============================================
set /p "CHOICE=Select: "
goto :DETECT_HANDLE
:DETECT_MENU_FR
echo =============================================
echo   Detection systeme
echo =============================================
echo  [1] Informations systeme completes
echo  [2] Type firmware (UEFI ou Legacy)
echo  [3] Statut BitLocker
echo  [4] Numero de build Windows
echo  [0] Retour
echo =============================================
set /p "CHOICE=Selectionner : "
:DETECT_HANDLE
if "!CHOICE!"=="1" ( call "%~dp0Detection\DetectSystem.bat" & pause & goto DETECT_MENU )
if "!CHOICE!"=="2" ( call "%~dp0Detection\DetectFirmware.bat" & pause & goto DETECT_MENU )
if "!CHOICE!"=="3" ( call "%~dp0Detection\DetectBitLocker.bat" & pause & goto DETECT_MENU )
if "!CHOICE!"=="4" ( call "%~dp0Detection\DetectWindowsBuild.bat" & pause & goto DETECT_MENU )
if "!CHOICE!"=="0" goto MENU
goto DETECT_MENU

:: ?????? DISK MENU ??????
:DISK_MENU
cls
if /i "%WINMIGRATE_LANG%"=="FR" goto :DISK_MENU_FR
echo =============================================
echo   Disk Operations
echo =============================================
echo  [1] List all disks
echo  [2] Clone disk to disk
echo  [3] Convert MBR to GPT (MBR2GPT)
echo  [4] Create UEFI GPT layout
echo  [5] Create Legacy MBR layout
echo  [0] Back
echo =============================================
set /p "CHOICE=Select: "
goto :DISK_HANDLE
:DISK_MENU_FR
echo =============================================
echo   Operations disque
echo =============================================
echo  [1] Lister tous les disques
echo  [2] Cloner un disque vers un autre
echo  [3] Convertir MBR en GPT (MBR2GPT)
echo  [4] Creer un layout UEFI GPT
echo  [5] Creer un layout Legacy MBR
echo  [0] Retour
echo =============================================
set /p "CHOICE=Selectionner : "
:DISK_HANDLE
if "!CHOICE!"=="1" ( call "%~dp0Disk\ListDisks.bat" & pause & goto DISK_MENU )
if "!CHOICE!"=="2" goto DISK_CLONE
if "!CHOICE!"=="3" goto DISK_CONVERT
if "!CHOICE!"=="4" goto DISK_UEFI
if "!CHOICE!"=="5" goto DISK_LEGACY
if "!CHOICE!"=="0" goto MENU
goto DISK_MENU

:DISK_CLONE
call "%~dp0Disk\ListDisks.bat"
echo.
if /i "%WINMIGRATE_LANG%"=="FR" (
    set /p "SRC=Numero du disque SOURCE : "
    set /p "DST=Numero du disque CIBLE : "
) else (
    set /p "SRC=Enter SOURCE disk number: "
    set /p "DST=Enter TARGET disk number: "
)
call "%~dp0Disk\CloneDisk.bat" !SRC! !DST!
pause & goto DISK_MENU

:DISK_CONVERT
if /i "%WINMIGRATE_LANG%"=="FR" (
    set /p "DSK=Numero du disque a convertir MBR->GPT : "
) else (
    set /p "DSK=Enter disk number to convert MBR->GPT: "
)
call "%~dp0Disk\ConvertMbrToGpt.bat" !DSK!
pause & goto DISK_MENU

:DISK_UEFI
if /i "%WINMIGRATE_LANG%"=="FR" (
    set /p "DSK=Numero du disque pour le layout UEFI GPT : "
) else (
    set /p "DSK=Enter disk number for UEFI GPT layout: "
)
call "%~dp0Disk\CreateUefiLayout.bat" !DSK!
pause & goto DISK_MENU

:DISK_LEGACY
if /i "%WINMIGRATE_LANG%"=="FR" (
    set /p "DSK=Numero du disque pour le layout Legacy MBR : "
) else (
    set /p "DSK=Enter disk number for Legacy MBR layout: "
)
call "%~dp0Disk\CreateLegacyLayout.bat" !DSK!
pause & goto DISK_MENU

:: ?????? IMAGING MENU ??????
:IMAGING_MENU
cls
if /i "%WINMIGRATE_LANG%"=="FR" goto :IMAGING_MENU_FR
echo =============================================
echo   Imaging (WIM)
echo =============================================
echo  [1] Capture WIM from a directory
echo  [2] Apply WIM to a drive
echo  [3] Split WIM into parts (FAT32 USB)
echo  [0] Back
echo =============================================
set /p "CHOICE=Select: "
goto :IMAGING_HANDLE
:IMAGING_MENU_FR
echo =============================================
echo   Imagerie (WIM)
echo =============================================
echo  [1] Capturer un WIM depuis un dossier
echo  [2] Appliquer un WIM sur un lecteur
echo  [3] Diviser un WIM en parties (USB FAT32)
echo  [0] Retour
echo =============================================
set /p "CHOICE=Selectionner : "
:IMAGING_HANDLE
if "!CHOICE!"=="1" goto IMG_CAPTURE
if "!CHOICE!"=="2" goto IMG_APPLY
if "!CHOICE!"=="3" goto IMG_SPLIT
if "!CHOICE!"=="0" goto MENU
goto IMAGING_MENU

:IMG_CAPTURE
if /i "%WINMIGRATE_LANG%"=="FR" (
    set /p "SRCDIR=Repertoire source a capturer (ex: C:\) : "
    set /p "WIMOUT=Chemin du fichier WIM de sortie (ex: D:\image.wim) : "
) else (
    set /p "SRCDIR=Enter source directory to capture (e.g. C:\): "
    set /p "WIMOUT=Enter output WIM file path (e.g. D:\image.wim): "
)
call "%~dp0Imaging\CaptureWim.bat" "!SRCDIR!" "!WIMOUT!"
pause & goto IMAGING_MENU

:IMG_APPLY
if /i "%WINMIGRATE_LANG%"=="FR" (
    set /p "WIMFILE=Chemin du fichier WIM : "
    set /p "WIMIDX=Index de l image (defaut 1) : "
    set /p "TGTDRV=Lettre du lecteur cible (ex: W:) : "
) else (
    set /p "WIMFILE=Enter WIM file path: "
    set /p "WIMIDX=Enter image index (default 1): "
    set /p "TGTDRV=Enter target drive letter (e.g. W:): "
)
if "!WIMIDX!"=="" set "WIMIDX=1"
call "%~dp0Imaging\ApplyWim.bat" "!WIMFILE!" !WIMIDX! "!TGTDRV!"
pause & goto IMAGING_MENU

:IMG_SPLIT
if /i "%WINMIGRATE_LANG%"=="FR" (
    set /p "WIMFILE=Chemin du fichier WIM source : "
    set /p "DESTDIR=Dossier de destination pour les parties .swm : "
) else (
    set /p "WIMFILE=Enter source WIM file path: "
    set /p "DESTDIR=Enter output folder for .swm parts: "
)
call "%~dp0Imaging\SplitWim.bat" "!WIMFILE!" "!DESTDIR!"
pause & goto IMAGING_MENU

:: ?????? BOOT MENU ??????
:BOOT_MENU
cls
if /i "%WINMIGRATE_LANG%"=="FR" goto :BOOT_MENU_FR
echo =============================================
echo   Boot Repair
echo =============================================
echo  [1] Repair UEFI boot (bcdboot /f UEFI)
echo  [2] Repair Legacy boot (bootrec + bcdboot)
echo  [3] Verify BCD store (bcdedit)
echo  [0] Back
echo =============================================
set /p "CHOICE=Select: "
goto :BOOT_HANDLE
:BOOT_MENU_FR
echo =============================================
echo   Reparation boot
echo =============================================
echo  [1] Reparer le boot UEFI (bcdboot /f UEFI)
echo  [2] Reparer le boot Legacy (bootrec + bcdboot)
echo  [3] Verifier le magasin BCD (bcdedit)
echo  [0] Retour
echo =============================================
set /p "CHOICE=Selectionner : "
:BOOT_HANDLE
if "!CHOICE!"=="1" goto BOOT_UEFI
if "!CHOICE!"=="2" goto BOOT_LEGACY
if "!CHOICE!"=="3" ( call "%~dp0Boot\VerifyBcd.bat" & pause & goto BOOT_MENU )
if "!CHOICE!"=="0" goto MENU
goto BOOT_MENU

:BOOT_UEFI
if /i "%WINMIGRATE_LANG%"=="FR" (
    set /p "WINPATH=Lettre de la partition Windows (ex: W:) : "
) else (
    set /p "WINPATH=Enter Windows partition letter (e.g. W:): "
)
call "%~dp0Boot\RepairBootUefi.bat" "!WINPATH!"
pause & goto BOOT_MENU

:BOOT_LEGACY
if /i "%WINMIGRATE_LANG%"=="FR" (
    set /p "WINPATH=Lettre de la partition Windows (ex: W:) : "
) else (
    set /p "WINPATH=Enter Windows partition letter (e.g. W:): "
)
call "%~dp0Boot\RepairBootLegacy.bat" "!WINPATH!"
pause & goto BOOT_MENU

:: ?????? EXPORT MENU ??????
:EXPORT_MENU
cls
if /i "%WINMIGRATE_LANG%"=="FR" goto :EXPORT_MENU_FR
echo =============================================
echo   Export (run on OLD PC)
echo =============================================
echo  [1]  Export user data (Desktop/Docs/etc)
echo  [2]  Export Wi-Fi profiles
echo  [3]  Export firewall rules
echo  [4]  Export hosts file
echo  [5]  Export PATH variable
echo  [6]  Export software list (64-bit, winget)
echo  [7]  Export software list (32-bit, WOW64)
echo  [8]  Export browser profiles
echo  [9]  Export product key info
echo  [10] Export registry (HKLM/HKCU backup)
echo  [11] Export drivers
echo  [12] Export scheduled tasks
echo  [13] Export printers list
echo  [14] Export Windows settings
echo  [15] Compress backup folder
echo  [0]  Back
echo =============================================
set /p "CHOICE=Select: "
goto :EXPORT_HANDLE
:EXPORT_MENU_FR
echo =============================================
echo   Export (lancer sur l ANCIEN PC)
echo =============================================
echo  [1]  Exporter donnees utilisateur
echo  [2]  Exporter profils Wi-Fi
echo  [3]  Exporter regles pare-feu
echo  [4]  Exporter fichier hosts
echo  [5]  Exporter variable PATH
echo  [6]  Exporter logiciels 64-bit (winget)
echo  [7]  Exporter logiciels 32-bit (WOW64)
echo  [8]  Exporter profils navigateurs
echo  [9]  Exporter cle produit Windows
echo  [10] Exporter registre (sauvegarde HKLM/HKCU)
echo  [11] Exporter pilotes
echo  [12] Exporter taches planifiees
echo  [13] Exporter liste imprimantes
echo  [14] Exporter parametres Windows
echo  [15] Compresser le dossier de sauvegarde
echo  [0]  Retour
echo =============================================
set /p "CHOICE=Selectionner : "
:EXPORT_HANDLE
if "!CHOICE!"=="1"  goto EXP_USERDATA
if "!CHOICE!"=="2"  goto EXP_WIFI
if "!CHOICE!"=="3"  goto EXP_FW
if "!CHOICE!"=="4"  goto EXP_HOSTS
if "!CHOICE!"=="5"  goto EXP_PATH
if "!CHOICE!"=="6"  goto EXP_SW64
if "!CHOICE!"=="7"  goto EXP_SW32
if "!CHOICE!"=="8"  goto EXP_BROWSER
if "!CHOICE!"=="9"  goto EXP_KEY
if "!CHOICE!"=="10" goto EXP_REG
if "!CHOICE!"=="11" goto EXP_DRV
if "!CHOICE!"=="12" goto EXP_TASKS
if "!CHOICE!"=="13" goto EXP_PRINT
if "!CHOICE!"=="14" goto EXP_SETTINGS
if "!CHOICE!"=="15" goto EXP_COMPRESS
if "!CHOICE!"=="0"  goto MENU
goto EXPORT_MENU

:EXP_USERDATA
if /i "%WINMIGRATE_LANG%"=="FR" (set /p "DEST=Dossier de destination (ENTREE=Bureau\WinMigrate_Backup) : ") else (set /p "DEST=Destination folder (ENTER=Desktop\WinMigrate_Backup): ")
call "%~dp0Export\ExportUserData.bat" "!DEST!"
pause & goto EXPORT_MENU
:EXP_WIFI
if /i "%WINMIGRATE_LANG%"=="FR" (set /p "DEST=Dossier de destination : ") else (set /p "DEST=Destination folder: ")
call "%~dp0Export\ExportWifi.bat" "!DEST!"
pause & goto EXPORT_MENU
:EXP_FW
if /i "%WINMIGRATE_LANG%"=="FR" (set /p "DEST=Dossier de destination : ") else (set /p "DEST=Destination folder: ")
call "%~dp0Export\ExportFirewall.bat" "!DEST!"
pause & goto EXPORT_MENU
:EXP_HOSTS
if /i "%WINMIGRATE_LANG%"=="FR" (set /p "DEST=Dossier de destination : ") else (set /p "DEST=Destination folder: ")
call "%~dp0Export\ExportHosts.bat" "!DEST!"
pause & goto EXPORT_MENU
:EXP_PATH
if /i "%WINMIGRATE_LANG%"=="FR" (set /p "DEST=Dossier de destination : ") else (set /p "DEST=Destination folder: ")
call "%~dp0Export\ExportPath.bat" "!DEST!"
pause & goto EXPORT_MENU
:EXP_SW64
if /i "%WINMIGRATE_LANG%"=="FR" (set /p "DEST=Dossier de destination : ") else (set /p "DEST=Destination folder: ")
call "%~dp0Export\ExportSoftware.bat" "!DEST!"
pause & goto EXPORT_MENU
:EXP_SW32
if /i "%WINMIGRATE_LANG%"=="FR" (set /p "DEST=Dossier de destination : ") else (set /p "DEST=Destination folder: ")
call "%~dp0Export\ExportSoftwareWOW64.bat" "!DEST!"
pause & goto EXPORT_MENU
:EXP_BROWSER
if /i "%WINMIGRATE_LANG%"=="FR" (set /p "DEST=Dossier de destination : ") else (set /p "DEST=Destination folder: ")
call "%~dp0Export\ExportBrowserProfiles.bat" "!DEST!"
pause & goto EXPORT_MENU
:EXP_KEY
if /i "%WINMIGRATE_LANG%"=="FR" (set /p "DEST=Dossier de destination : ") else (set /p "DEST=Destination folder: ")
call "%~dp0Export\ExportProductKey.bat" "!DEST!"
pause & goto EXPORT_MENU
:EXP_REG
if /i "%WINMIGRATE_LANG%"=="FR" (set /p "DEST=Dossier de destination : ") else (set /p "DEST=Destination folder: ")
call "%~dp0Export\ExportRegistry.bat" "!DEST!"
pause & goto EXPORT_MENU
:EXP_DRV
if /i "%WINMIGRATE_LANG%"=="FR" (set /p "DEST=Dossier de destination : ") else (set /p "DEST=Destination folder: ")
call "%~dp0Export\ExportDrivers.bat" "!DEST!"
pause & goto EXPORT_MENU
:EXP_TASKS
if /i "%WINMIGRATE_LANG%"=="FR" (set /p "DEST=Dossier de destination : ") else (set /p "DEST=Destination folder: ")
call "%~dp0Export\ExportScheduledTasks.bat" "!DEST!"
pause & goto EXPORT_MENU
:EXP_PRINT
if /i "%WINMIGRATE_LANG%"=="FR" (set /p "DEST=Dossier de destination : ") else (set /p "DEST=Destination folder: ")
call "%~dp0Export\ExportPrinters.bat" "!DEST!"
pause & goto EXPORT_MENU
:EXP_SETTINGS
if /i "%WINMIGRATE_LANG%"=="FR" (set /p "DEST=Dossier de destination : ") else (set /p "DEST=Destination folder: ")
call "%~dp0Export\ExportWindowsSettings.bat" "!DEST!"
pause & goto EXPORT_MENU
:EXP_COMPRESS
if /i "%WINMIGRATE_LANG%"=="FR" (
    set /p "SRC=Dossier a compresser : "
    set /p "DEST=Dossier de destination pour l archive : "
) else (
    set /p "SRC=Folder to compress: "
    set /p "DEST=Destination folder for archive: "
)
call "%~dp0Export\CompressBackup.bat" "!SRC!" "!DEST!"
pause & goto EXPORT_MENU

:: ?????? INSTALL MENU ??????
:INSTALL_MENU
cls
if /i "%WINMIGRATE_LANG%"=="FR" goto :INSTALL_MENU_FR
echo =============================================
echo   Install / Import (run on NEW PC)
echo =============================================
echo  [1]  Import Wi-Fi profiles
echo  [2]  Import firewall rules
echo  [3]  Import hosts file
echo  [4]  Import PATH variable
echo  [5]  Install software (64-bit)
echo  [6]  Install software (32-bit/WOW64)
echo  [7]  Import browser profiles
echo  [8]  Import drivers (online)
echo  [9]  Verify file checksums
echo  [10] Import Windows settings
echo  [11] Import user data
echo  [0]  Back
echo =============================================
set /p "CHOICE=Select: "
goto :INSTALL_HANDLE
:INSTALL_MENU_FR
echo =============================================
echo   Installation / Import (nouveau PC)
echo =============================================
echo  [1]  Importer profils Wi-Fi
echo  [2]  Importer regles pare-feu
echo  [3]  Importer fichier hosts
echo  [4]  Importer variable PATH
echo  [5]  Installer logiciels 64-bit
echo  [6]  Installer logiciels 32-bit/WOW64
echo  [7]  Importer profils navigateurs
echo  [8]  Importer pilotes (en ligne)
echo  [9]  Verifier les checksums
echo  [10] Importer parametres Windows
echo  [11] Importer donnees utilisateur
echo  [0]  Retour
echo =============================================
set /p "CHOICE=Selectionner : "
:INSTALL_HANDLE
if "!CHOICE!"=="1"  goto IMP_WIFI
if "!CHOICE!"=="2"  goto IMP_FW
if "!CHOICE!"=="3"  goto IMP_HOSTS
if "!CHOICE!"=="4"  goto IMP_PATH
if "!CHOICE!"=="5"  goto IMP_SW64
if "!CHOICE!"=="6"  goto IMP_SW32
if "!CHOICE!"=="7"  goto IMP_BROWSER
if "!CHOICE!"=="8"  goto IMP_DRV
if "!CHOICE!"=="9"  goto IMP_CHECKSUMS
if "!CHOICE!"=="10" goto IMP_SETTINGS
if "!CHOICE!"=="11" goto IMP_USERDATA
if "!CHOICE!"=="0"  goto MENU
goto INSTALL_MENU

:IMP_WIFI
if /i "%WINMIGRATE_LANG%"=="FR" (set /p "SRC=Dossier contenant les profils Wi-Fi XML : ") else (set /p "SRC=Folder containing Wi-Fi XML profiles: ")
call "%~dp0Install\ImportWifi.bat" "!SRC!"
pause & goto INSTALL_MENU
:IMP_FW
if /i "%WINMIGRATE_LANG%"=="FR" (set /p "SRC=Chemin du fichier .wfw de sauvegarde : ") else (set /p "SRC=Firewall backup .wfw file path: ")
call "%~dp0Install\ImportFirewall.bat" "!SRC!"
pause & goto INSTALL_MENU
:IMP_HOSTS
if /i "%WINMIGRATE_LANG%"=="FR" (set /p "SRC=Chemin du fichier hosts de sauvegarde : ") else (set /p "SRC=Hosts backup file path: ")
call "%~dp0Install\ImportHosts.bat" "!SRC!"
pause & goto INSTALL_MENU
:IMP_PATH
if /i "%WINMIGRATE_LANG%"=="FR" (set /p "SRC=Chemin du fichier .reg PATH : ") else (set /p "SRC=PATH .reg backup file path: ")
call "%~dp0Install\ImportPath.bat" "!SRC!"
pause & goto INSTALL_MENU
:IMP_SW64
if /i "%WINMIGRATE_LANG%"=="FR" (set /p "SRC=Dossier contenant les installeurs 64-bit : ") else (set /p "SRC=Folder containing 64-bit installers: ")
call "%~dp0Install\InstallSoftware.bat" "!SRC!"
pause & goto INSTALL_MENU
:IMP_SW32
if /i "%WINMIGRATE_LANG%"=="FR" (set /p "SRC=Dossier contenant les installeurs 32-bit : ") else (set /p "SRC=Folder containing 32-bit installers: ")
call "%~dp0Install\InstallSoftwareWOW64.bat" "!SRC!"
pause & goto INSTALL_MENU
:IMP_BROWSER
if /i "%WINMIGRATE_LANG%"=="FR" (set /p "SRC=Dossier BrowserProfiles de sauvegarde : ") else (set /p "SRC=BrowserProfiles backup folder: ")
call "%~dp0Install\ImportBrowserProfiles.bat" "!SRC!"
pause & goto INSTALL_MENU
:IMP_DRV
if /i "%WINMIGRATE_LANG%"=="FR" (set /p "SRC=Dossier contenant les pilotes (.inf) : ") else (set /p "SRC=Folder containing driver .inf files: ")
call "%~dp0Install\ImportDrivers.bat" "!SRC!"
pause & goto INSTALL_MENU
:IMP_CHECKSUMS
if /i "%WINMIGRATE_LANG%"=="FR" (set /p "SRC=Dossier a verifier (ex: Telechargements) : ") else (set /p "SRC=Folder to verify (e.g. Downloads): ")
call "%~dp0Install\Checksums.bat" "!SRC!"
pause & goto INSTALL_MENU
:IMP_SETTINGS
if /i "%WINMIGRATE_LANG%"=="FR" (set /p "SRC=Dossier contenant les fichiers .reg : ") else (set /p "SRC=Folder containing .reg settings files: ")
call "%~dp0Install\ImportWindowsSettings.bat" "!SRC!"
pause & goto INSTALL_MENU
:IMP_USERDATA
if /i "%WINMIGRATE_LANG%"=="FR" (set /p "SRC=Dossier de sauvegarde des donnees utilisateur : ") else (set /p "SRC=User data backup folder: ")
call "%~dp0Install\ImportUserData.bat" "!SRC!"
pause & goto INSTALL_MENU

:: ?????? OPTIONAL MENU ??????
:OPTIONAL_MENU
cls
if /i "%WINMIGRATE_LANG%"=="FR" goto :OPTIONAL_MENU_FR
echo =============================================
echo   Optional Tools
echo =============================================
echo  [1] Inject drivers offline (DISM)
echo  [2] Sysprep Generalize + Shutdown
echo  [3] Optional utilities installer (winget)
echo  [4] Create bootable USB drive
echo  [0] Back
echo =============================================
set /p "CHOICE=Select: "
goto :OPTIONAL_HANDLE
:OPTIONAL_MENU_FR
echo =============================================
echo   Outils optionnels
echo =============================================
echo  [1] Injecter des pilotes hors-ligne (DISM)
echo  [2] Sysprep Generaliser + Arret
echo  [3] Installeur d utilitaires optionnels
echo  [4] Creer une cle USB bootable
echo  [0] Retour
echo =============================================
set /p "CHOICE=Selectionner : "
:OPTIONAL_HANDLE
if "!CHOICE!"=="1" goto OPT_INJECT
if "!CHOICE!"=="2" ( call "%~dp0Optional\SysprepGeneralize.bat" & goto OPTIONAL_MENU )
if "!CHOICE!"=="3" ( call "%~dp0Install\Optional\Utilities.bat" & goto OPTIONAL_MENU )
if "!CHOICE!"=="4" goto OPT_USB
if "!CHOICE!"=="0" goto MENU
goto OPTIONAL_MENU

:OPT_INJECT
if /i "%WINMIGRATE_LANG%"=="FR" (
    set /p "IMG=Chemin de l image Windows hors-ligne (ex: W:\) : "
    set /p "DRV=Dossier des pilotes : "
) else (
    set /p "IMG=Offline Windows image path (e.g. W:\): "
    set /p "DRV=Driver folder path: "
)
call "%~dp0Optional\InjectDrivers.bat" "!IMG!" "!DRV!"
pause & goto OPTIONAL_MENU

:OPT_USB
call "%~dp0Disk\ListDisks.bat"
echo.
if /i "%WINMIGRATE_LANG%"=="FR" (
    set /p "SRC=Dossier source (ISO monte ou fichiers setup) : "
    set /p "DSK=Numero du disque USB (liste ci-dessus) : "
) else (
    set /p "SRC=Source folder (mounted ISO or setup files): "
    set /p "DSK=USB disk number from list above: "
)
call "%~dp0USB\CreateBootableUsb.bat" "!SRC!" !DSK!
pause & goto OPTIONAL_MENU

:: ?????? GUIDED MIGRATION ??????
:MIGRATION_MENU
cls
if /i "%WINMIGRATE_LANG%"=="FR" goto :MIGRATION_MENU_FR
echo =============================================
echo   GUIDED MIGRATION
echo =============================================
echo  [1] OLD PC  - Export all data (backup)
echo  [2] NEW PC  - Import all data (restore)
echo  [0] Back
echo =============================================
set /p "CHOICE=Select: "
goto :MIGRATION_HANDLE
:MIGRATION_MENU_FR
echo =============================================
echo   MIGRATION GUIDEE
echo =============================================
echo  [1] ANCIEN PC - Exporter toutes les donnees
echo  [2] NOUVEAU PC - Importer toutes les donnees
echo  [0] Retour
echo =============================================
set /p "CHOICE=Selectionner : "
:MIGRATION_HANDLE
if "!CHOICE!"=="1" goto MIGRATION_EXPORT
if "!CHOICE!"=="2" goto MIGRATION_IMPORT
if "!CHOICE!"=="0" goto MENU
goto MIGRATION_MENU

:MIGRATION_EXPORT
cls
if /i "%WINMIGRATE_LANG%"=="FR" (
    echo =============================================
    echo   EXPORT - Ancien PC
    echo =============================================
    echo  Toutes les donnees seront exportees dans
    echo  un seul dossier. Copiez-le sur le nouveau PC.
    echo.
    set /p "BKDIR=Dossier de destination (ex: D:\WinMigrate_Backup) : "
) else (
    echo =============================================
    echo   EXPORT - Old PC
    echo =============================================
    echo  All data will be exported to a single folder.
    echo  Copy it to the new PC when done.
    echo.
    set /p "BKDIR=Backup folder (e.g. D:\WinMigrate_Backup): "
)
if "!BKDIR!"=="" goto MIGRATION_MENU
echo.
if /i "%WINMIGRATE_LANG%"=="FR" (echo [ 1/11] Donnees utilisateur...) else (echo [ 1/11] User data...)
call "%~dp0Export\ExportUserData.bat" "!BKDIR!"
if /i "%WINMIGRATE_LANG%"=="FR" (echo [ 2/11] Profils Wi-Fi...) else (echo [ 2/11] Wi-Fi profiles...)
call "%~dp0Export\ExportWifi.bat" "!BKDIR!"
if /i "%WINMIGRATE_LANG%"=="FR" (echo [ 3/11] Pilotes...) else (echo [ 3/11] Drivers...)
call "%~dp0Export\ExportDrivers.bat" "!BKDIR!"
if /i "%WINMIGRATE_LANG%"=="FR" (echo [ 4/11] Profils navigateurs...) else (echo [ 4/11] Browser profiles...)
call "%~dp0Export\ExportBrowserProfiles.bat" "!BKDIR!"
if /i "%WINMIGRATE_LANG%"=="FR" (echo [ 5/11] Regles pare-feu...) else (echo [ 5/11] Firewall rules...)
call "%~dp0Export\ExportFirewall.bat" "!BKDIR!"
if /i "%WINMIGRATE_LANG%"=="FR" (echo [ 6/11] Fichier hosts...) else (echo [ 6/11] Hosts file...)
call "%~dp0Export\ExportHosts.bat" "!BKDIR!"
if /i "%WINMIGRATE_LANG%"=="FR" (echo [ 7/11] Variable PATH...) else (echo [ 7/11] PATH variable...)
call "%~dp0Export\ExportPath.bat" "!BKDIR!"
if /i "%WINMIGRATE_LANG%"=="FR" (echo [ 8/11] Liste logiciels installes...) else (echo [ 8/11] Installed software list...)
call "%~dp0Export\ExportSoftware.bat" "!BKDIR!"
if /i "%WINMIGRATE_LANG%"=="FR" (echo [ 9/11] Parametres Windows...) else (echo [ 9/11] Windows settings...)
call "%~dp0Export\ExportWindowsSettings.bat" "!BKDIR!"
if /i "%WINMIGRATE_LANG%"=="FR" (echo [10/11] Cle produit Windows...) else (echo [10/11] Windows product key...)
call "%~dp0Export\ExportProductKey.bat" "!BKDIR!"
if /i "%WINMIGRATE_LANG%"=="FR" (echo [11/11] Registre (HKLM/HKCU)...) else (echo [11/11] Registry (HKLM/HKCU)...)
call "%~dp0Export\ExportRegistry.bat" "!BKDIR!"
echo.
if /i "%WINMIGRATE_LANG%"=="FR" (
    echo =============================================
    echo   EXPORT TERMINE.
    echo   Dossier : !BKDIR!
    echo   Copiez ce dossier sur le nouveau PC.
    echo =============================================
) else (
    echo =============================================
    echo   EXPORT COMPLETE.
    echo   Folder: !BKDIR!
    echo   Copy this folder to the new PC.
    echo =============================================
)
pause & goto MIGRATION_MENU

:MIGRATION_IMPORT
cls
if /i "%WINMIGRATE_LANG%"=="FR" (
    echo =============================================
    echo   IMPORT - Nouveau PC
    echo =============================================
    echo  Indiquez le dossier de sauvegarde copie
    echo  depuis l ancien PC.
    echo.
    set /p "BKDIR=Dossier de sauvegarde (ex: D:\WinMigrate_Backup) : "
) else (
    echo =============================================
    echo   IMPORT - New PC
    echo =============================================
    echo  Enter the backup folder path copied from
    echo  the old PC.
    echo.
    set /p "BKDIR=Backup folder (e.g. D:\WinMigrate_Backup): "
)
if "!BKDIR!"=="" goto MIGRATION_MENU
echo.
if /i "%WINMIGRATE_LANG%"=="FR" (echo [ 1/10] Pilotes...) else (echo [ 1/10] Drivers...)
call "%~dp0Install\ImportDrivers.bat" "!BKDIR!"
if /i "%WINMIGRATE_LANG%"=="FR" (echo [ 2/10] Profils Wi-Fi...) else (echo [ 2/10] Wi-Fi profiles...)
call "%~dp0Install\ImportWifi.bat" "!BKDIR!"
if /i "%WINMIGRATE_LANG%"=="FR" (echo [ 3/10] Regles pare-feu...) else (echo [ 3/10] Firewall rules...)
call "%~dp0Install\ImportFirewall.bat" "!BKDIR!"
if /i "%WINMIGRATE_LANG%"=="FR" (echo [ 4/10] Fichier hosts...) else (echo [ 4/10] Hosts file...)
call "%~dp0Install\ImportHosts.bat" "!BKDIR!"
if /i "%WINMIGRATE_LANG%"=="FR" (echo [ 5/10] Variable PATH...) else (echo [ 5/10] PATH variable...)
call "%~dp0Install\ImportPath.bat" "!BKDIR!"
if /i "%WINMIGRATE_LANG%"=="FR" (echo [ 6/10] Donnees utilisateur...) else (echo [ 6/10] User data...)
call "%~dp0Install\ImportUserData.bat" "!BKDIR!"
if /i "%WINMIGRATE_LANG%"=="FR" (echo [ 7/10] Profils navigateurs...) else (echo [ 7/10] Browser profiles...)
call "%~dp0Install\ImportBrowserProfiles.bat" "!BKDIR!"
if /i "%WINMIGRATE_LANG%"=="FR" (echo [ 8/10] Parametres Windows...) else (echo [ 8/10] Windows settings...)
call "%~dp0Install\ImportWindowsSettings.bat" "!BKDIR!"
if /i "%WINMIGRATE_LANG%"=="FR" (echo [ 9/10] Installation logiciels 64-bit...) else (echo [ 9/10] Software install 64-bit...)
call "%~dp0Install\InstallSoftware.bat" "!BKDIR!"
if /i "%WINMIGRATE_LANG%"=="FR" (echo [10/10] Installation logiciels 32-bit (WOW64)...) else (echo [10/10] Software install 32-bit (WOW64)...)
call "%~dp0Install\InstallSoftwareWOW64.bat" "!BKDIR!"
echo.
if /i "%WINMIGRATE_LANG%"=="FR" (
    echo =============================================
    echo   IMPORT TERMINE. Redemarrez le PC.
    echo =============================================
) else (
    echo =============================================
    echo   IMPORT COMPLETE. Please restart your PC.
    echo =============================================
)
pause & goto MIGRATION_MENU