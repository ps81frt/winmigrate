# WinMigrate

> **Zero-dependency Windows migration toolkit — pure BAT, 47 scripts, one command.**

Automate a full PC-to-PC Windows migration without any third-party tool.
WinMigrate exports everything from the old machine (user data, Wi-Fi, drivers, browser profiles,
firewall rules, registry, software list, product key) and restores it all on the new one —
in a single guided workflow or menu by menu.

Built for sysadmins, IT technicians and power users who need a reproducible,
auditable, offline-capable migration process on Windows 7 / 10 / 11 / WinPE.

---

## Features

- **Guided migration** — one path, one command: export all → copy USB → import all
- **47 standalone BAT scripts** — each usable independently, no installer, no runtime
- **WMIC-free** — fully compatible with Windows 11 22H2+ (diskpart / reg / netsh / manage-bde / certutil)
- **UEFI & Legacy BIOS** — firmware detection via `bcdedit`, disk layout creation, boot repair
- **Bilingual EN/FR** — auto-detects system locale, every prompt and message in both languages
- **WIM imaging** — capture, apply, split (DISM-based, FAT32 USB ready)
- **Admin guard** — every script checks `net session` then falls back to `fsutil dirty query` for WinPE compatibility (Workstation service absent in WinPE)
- **Confirmed destructive ops** — every irreversible action requires explicit Y/O confirmation
- **Structured logging** — all operations logged to `%TEMP%\WinMigrate_<script>_<date>.log`
- **ASCII-pure, CRLF** — safe across all locales, transfer methods and text editors

---

## Requirements

| Requirement | Details |
|---|---|
| OS | Windows 7 SP1 / 10 / 11 / WinPE 5+ |
| Privileges | Administrator (UAC elevated session) |
| Shell | CMD — no PowerShell, no WSL, no dependencies |
| Optional | `7z.exe` in PATH for archive compression; `winget` for software export/install |

---

## Quick Start

```cmd
:: Right-click WinMigrate.bat -> Run as administrator
WinMigrate.bat
```

**Full migration in 3 steps:**

1. **Old PC** → Run `WinMigrate.bat` → `[9] Guided Migration` → `[1] Export` → enter backup path
2. Copy the backup folder to a USB drive or network share
3. **New PC** → Run `WinMigrate.bat` → `[9] Guided Migration` → `[2] Import` → enter backup path → reboot

---

## Menu Structure

```
WinMigrate.bat
├── [1] Detection          firmware, BitLocker, OS build, system info
├── [2] Disk               list, clone, MBR↔GPT, UEFI/Legacy layout
├── [3] Imaging (WIM)      capture, apply, split
├── [4] Boot Repair        UEFI bcdboot, Legacy bootrec, BCD verify
├── [5] Export             15 export modules (old PC)
├── [6] Install / Import   12 import/install modules (new PC)
├── [7] Optional           offline driver inject, sysprep, USB creation
├── [8] Verify             integrity check (certutil SHA256)
└── [9] Guided Migration   full export or import workflow in one shot
```

---

## Project Structure

```
WinMigrate/
├── WinMigrate.bat              Main launcher + bilingual hierarchical menu
├── Verify.bat                  Dynamic integrity check — auto-scans all .bat/.md, certutil SHA256 per file
├── Boot/                       UEFI + Legacy boot repair, BCD verification
├── Detection/                  Firmware, BitLocker, OS build, system info
├── Disk/                       Clone, convert, partition layout (no WMIC)
├── Export/                     15 modules: data, Wi-Fi, drivers, registry...
├── Imaging/                    WIM capture / apply / split (DISM)
├── Install/                    12 modules: import data, drivers, software...
├── Optional/                   Sysprep, offline driver inject, utilities
└── USB/                        Bootable USB creation (diskpart + robocopy)
```

---

## Security & Safety

- Every script validates admin rights via double fallback: `net session` (live OS) → `fsutil dirty query %SystemDrive%` (WinPE) — exits immediately if not elevated
- All destructive operations (disk wipe, registry import, sysprep) require explicit confirmation
- No network calls, no telemetry, no external binaries fetched at runtime
- All operations are logged — full audit trail available in `%TEMP%`

---

## Compatibility Notes

- `wmic` has been **removed entirely** — replaced with `diskpart`, `reg`, `netsh`, `manage-bde`, `certutil`
- Firmware detection uses `bcdedit | find /i ".efi"` — works on live systems (not WinPE-only like registry method)
- Scripts use `chcp 437` + ASCII encoding — safe in all CMD sessions regardless of system locale

---

## Author

**PS81FRT** — [github.com/ps81frt/winmigrate](https://github.com/ps81frt/winmigrate)

---

## License

MIT — Copyright (c) 2026 PS81FRT — free to use, modify and redistribute with attribution.
