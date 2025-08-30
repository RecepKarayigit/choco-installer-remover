# Chocolatey Installer & Remover Script

A PowerShell script to **install or remove Chocolatey** on Windows. It handles environment variables, restores modified profiles, and ensures proper permissions. Designed for ease of use with clear feedback messages.

---

## Table of Contents

- [Features](#features)  
- [Requirements](#requirements)  
- [Installation](#installation)  
- [Usage](#usage)  
- [Functions](#functions)  
- [Notes](#notes)  
- [License](#license)

---

## Features

- Install Chocolatey in a custom path (`C:\ProgramData\Chocolatey` by default).  
- Remove Chocolatey along with environment variables and profile changes.  
- Restores PowerShell profile to its previous state.  
- Provides clear, colored status messages (✔, ❌, ⚠, ℹ).  
- Checks for administrator permissions before installing.  
- Detects existing Chocolatey installations and optionally reinstalls.  

---

## Requirements

- Windows 7 or later  
- PowerShell 5.1+  
- Internet connection (for Chocolatey installer script)  
- Administrator privileges for installation  

---

## Installation

1. Clone or download this repository.  
2. Open **PowerShell as Administrator**.  
3. Run the script:

```powershell
.\choco-install-remove.ps1
```

> The script will prompt you to select **Install** or **Remove** if no action parameter is provided.

---

## Usage

### Using Parameters

```powershell
# Install Chocolatey
.\choco-install-remove.ps1 -Action install

# Remove Chocolatey
.\choco-install-remove.ps1 -Action remove
```

### Interactive Mode

Running the script without parameters will prompt:

```
Choose an action:
1) Install Chocolatey
2) Remove Chocolatey
Enter choice (1 or 2):
```

---

## Functions Overview

| Function | Description |
|----------|-------------|
| `Write-Status` | Displays colored messages with symbols for status (OK, ERROR, WARN, INFO). |
| `Test-IsAdmin` | Checks if the script is running with administrator privileges. |
| `Remove-Folder` | Deletes a folder and all its contents safely. |
| `Remove-EnvVariable` | Removes environment variables at Process, User, and Machine scopes. |
| `Restore-ProfileChanges` | Restores PowerShell profile modifications saved by previous installs. |
| `Save-ProfileDiff` | Saves differences between the original and updated PowerShell profile. |
| `Remove-Choco` | Removes Chocolatey, environment variables, and restores profile changes. |
| `Install-Choco` | Installs Chocolatey, updates environment variables, and saves profile changes. |

---

## Notes

- The script modifies `$PROFILE` and environment variables. Backup your profile if necessary.  
- Chocolatey will be installed at: `C:\ProgramData\Chocolatey` (default). Change `$installPath` in the script if needed.  
- Administrator privileges are required for installation but **not for removal**.  

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

