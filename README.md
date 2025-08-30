# Chocolatey Package Manager

A set of PowerShell scripts to **install/remove Chocolatey**, **manage installed programs**, and **install standard programs** on Windows. Includes export/import functionality for Chocolatey packages.

---

## Table of Contents

- [Features](#features)  
- [Requirements](#requirements)  
- [Installation](#installation)  
- [Usage](#usage)  
- [Functions](#functions)  
- [Scripts](#scripts)  
- [Notes](#notes)  
- [License](#license)

---

## Features

- Install or remove Chocolatey.  
- Export installed Chocolatey packages (with or without version info).  
- Import Chocolatey packages from a saved list.  
- Delete all installed Chocolatey packages.  
- Install a set of standard programs via Chocolatey.  
- Clear status messages and logging for all actions.

---

## Requirements

- Windows 7 or later  
- PowerShell 5.1+  
- Administrator privileges for installation and package management  
- Internet connection

---

## Installation

1. Clone or download this repository.  
2. Open **PowerShell as Administrator**.  
3. Run the desired script:

```powershell
# To install or remove Chocolatey
.\choco-install-remove.ps1

# To manage Chocolatey packages
.\choco-manager.ps1
```

---

## Usage

### `choco-install-remove.ps1`

- Install Chocolatey:
```powershell
.\choco-install-remove.ps1 -Action install
```
- Remove Chocolatey:
```powershell
.\choco-install-remove.ps1 -Action remove
```

### `choco-manager.ps1`

- Export installed packages:
```powershell
.\choco-manager.ps1 -Action export            # without version
.\choco-manager.ps1 -Action export -IncludeVersion  # with version info
```
- Import packages from a previously exported list:
```powershell
.\choco-manager.ps1 -Action import
```
- Delete all installed Chocolatey packages:
```powershell
.\choco-manager.ps1 -Action delete
```
- Install standard programs:
```powershell
.\choco-manager.ps1 -Action install-standard
```

---

## Scripts Overview

| Script | Description |
|--------|-------------|
| `choco-install-remove.ps1` | Installs or removes Chocolatey and restores PowerShell profile changes. |
| `choco-manager.ps1` | Exports, imports, deletes Chocolatey packages, and installs standard programs. |
| `install-standard-programs.ps1` | Installs a predefined list of standard programs via Chocolatey. |
| `backup-restore-packages.ps1` | Exports and restores installed Chocolatey and Scoop packages. |

---

## Notes

- Back up your PowerShell profile if necessary.  
- Chocolatey will be installed at: `C:\ProgramData\Chocolatey` (default).  
- Administrator privileges are required for installation but not for removal of Chocolatey.  
- Standard programs installation requires `install-standard-programs.ps1` to exist in the same folder as `choco-manager.ps1`.

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

