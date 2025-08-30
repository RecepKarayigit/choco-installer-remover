choco-installer/
├── choco-install-remove.ps1
├── choco-manager.ps1
├── install-standard-programs.ps1
├── backup-restore-packages.ps1
├── README.md
└── LICENSE

---

# choco-manager.ps1

\<PowerShell script to manage Chocolatey packages with export, import, delete, and install standard programs functionality>

```powershell
param(
    [ValidateSet("export", "import", "delete", "install-standard")]
    [string]$Action,
    [switch]$IncludeVersion
)

# -------------------------------
# Config
# -------------------------------
$chocoPath = if ($env:ChocolateyInstall) { $env:ChocolateyInstall } else { "C:\ProgramData\Chocolatey" }
$backupFolder = Join-Path $chocoPath "choco_package_backups"
if (-not (Test-Path $backupFolder)) { New-Item -ItemType Directory -Path $backupFolder -Force | Out-Null }

$exportFile = Join-Path $backupFolder "installed_packages.txt"
$installStandardScript = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "install-standard-programs.ps1"

# -------------------------------
# Functions
# -------------------------------
function Export-Packages {
    param([switch]$WithVersion)
    if ($WithVersion) {
        choco list --local-only > $exportFile
    } else {
        choco list --local-only --id-only > $exportFile
    }
    Write-Host "Exported packages to: $exportFile"
}

function Import-Packages {
    $fileToImport = $exportFile
    if (-not (Test-Path $fileToImport)) {
        $currentPathFile = Join-Path (Get-Location) "installed_packages.txt"
        if (Test-Path $currentPathFile) {
            $fileToImport = $currentPathFile
        } else {
            $fileToImport = Read-Host "Export file not found. Please provide full path to the exported package list"
        }
    }

    if (Test-Path $fileToImport) {
        $packages = Get-Content $fileToImport
        foreach ($pkg in $packages) {
            Write-Host "Installing $pkg..."
            choco install $pkg -y
        }
        Write-Host "All packages imported successfully."
    } else {
        Write-Host "File not found. Aborting import."
    }
}

function Delete-AllPackages {
    $installedPackages = choco list --local-only --id-only
    foreach ($pkg in $installedPackages) {
        Write-Host "Uninstalling $pkg..."
        choco uninstall $pkg -y
    }
    Write-Host "All Chocolatey packages have been uninstalled."
}

function Install-StandardPrograms {
    if (Test-Path $installStandardScript) {
        Write-Host "Running install-standard-programs script..."
        & $installStandardScript
    } else {
        Write-Host "install-standard-programs.ps1 not found at: $installStandardScript"
    }
}

# -------------------------------
# Main
# -------------------------------
switch ($Action) {
    "export" { Export-Packages -WithVersion:$IncludeVersion }
    "import" { Import-Packages }
    "delete" { Delete-AllPackages }
    "install-standard" { Install-StandardPrograms }
    default { Write-Host "Invalid action. Choose: export, import, delete, or install-standard." }
}
```
