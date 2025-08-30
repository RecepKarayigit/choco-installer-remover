param(
    [ValidateSet("install","remove")]
    [string]$Action
)

# -------------------------------
# Config
# -------------------------------
# $installPath = Join-Path $env:USERPROFILE "PortableApps\PackageManagers\Chocolatey"
$installPath = "C:\ProgramData\Chocolatey"
$helpersPath = Join-Path $installPath "helpers"
$diffFile    = Join-Path $helpersPath "exportedProfileChanges.txt"
$profilePath = $PROFILE

$tick  = [char]0x2714
$cross = [char]0x274C
$warn  = [char]0x26A0

# -------------------------------
# Message Helper
# -------------------------------
function Write-Status {
    param (
        [Parameter(Mandatory)][ValidateSet("OK","ERROR","WARN","INFO")]
        [string]$Type,
        [Parameter(Mandatory)]
        [string]$Message
    )
    switch ($Type) {
        "OK"    { Write-Host "$tick $Message"  -ForegroundColor Green }
        "ERROR" { Write-Host "$cross $Message" -ForegroundColor Red }
        "WARN"  { Write-Host "$warn $Message"  -ForegroundColor Yellow }
        "INFO"  { Write-Host "ℹ $Message"      -ForegroundColor Cyan }
    }
}

# -------------------------------
# Permissions
# -------------------------------
function Test-IsAdmin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal   = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# -------------------------------
# Remove Folder
# -------------------------------
function Remove-Folder {
    param ([string]$Path)
    try {
        if (Test-Path $Path) {
            $fullPath = (Resolve-Path $Path).Path
            Remove-Item -Recurse -Force -Path $fullPath
            Write-Status OK "Deleted '$fullPath'."
        } else {
            Write-Status WARN "Folder not found: $Path"
        }
    }
    catch {
        Write-Status ERROR "Failed to delete '$Path': $($_.Exception.Message)"
        exit 1
    }
}

# -------------------------------
# Remove Env Variable
# -------------------------------
function Remove-EnvVariable {
    param ([string]$VariableName)
    $scopes = @('Process', 'User', 'Machine')
    $found = $false

    foreach ($scope in $scopes) {
        $value = [Environment]::GetEnvironmentVariable($VariableName, $scope)
        if ($value) {
            Write-Status WARN "$VariableName exists at $scope level: $value"
            try {
                [Environment]::SetEnvironmentVariable($VariableName, $null, $scope)
                Write-Status OK "$VariableName removed from $scope."
                $found = $true
            }
            catch {
                Write-Status ERROR "Failed to remove $VariableName from $scope : $($_.Exception.Message)"
            }
        }
    }

    if (-not $found) {
        Write-Status INFO "$VariableName not found in any scope."
    }
}

# -------------------------------
# Restore Profile
# -------------------------------
function Restore-ProfileChanges {
    if ((Test-Path $diffFile) -and (Test-Path $profilePath)) {

        # Read diff file lines (these are the lines added by Chocolatey)
        $changes = Get-Content $diffFile

        # Read current profile lines
        $profileLines = Get-Content $profilePath

        # Keep all lines except those exactly in the changes
        # Blank lines and other content remain untouched
        $updatedProfile = $profileLines | Where-Object {
            $line = $_
            ($line.Trim() -eq "" -or -not ($changes -contains $line))
        }

        # Write the updated profile back to disk
        Set-Content -Path $profilePath -Value $updatedProfile -Encoding UTF8

        # Remove the diff file after restoration
        Remove-Item $diffFile -Force
        Write-Status OK "Profile changes restored."
    } else {
        Write-Status INFO "No stored profile changes found."
    }
}

# -------------------------------
# Save Profile Difference
# -------------------------------
function Save-ProfileDiff {
    param (
        [string]$BeforeContent,
        [string]$AfterContent
    )
    $diff = Compare-Object ($BeforeContent -split "`r?`n") ($AfterContent -split "`r?`n") |
            Where-Object { $_.SideIndicator -eq '=>' } |
            ForEach-Object { $_.InputObject }
    if ($diff) {
        if (-not (Test-Path $helpersPath)) {
            New-Item -ItemType Directory -Path $helpersPath -Force | Out-Null
        }
        $diff -join "`r`n" | Set-Content -Path $diffFile -Encoding UTF8
        Write-Status OK "Profile changes saved to: $diffFile"
    } else {
        Write-Status INFO "No profile changes detected."
    }
}

# -------------------------------
# Remove Chocolatey
# -------------------------------
function Remove-Choco {
    Restore-ProfileChanges
    Remove-Folder $installPath
    Remove-EnvVariable -VariableName 'ChocolateyInstall'
}

# -------------------------------
# Install Chocolatey
# -------------------------------
function Install-Choco {
    if (-not (Test-IsAdmin)) {
        Write-Status ERROR "This script must be run as Administrator."
        exit 1
    }

    $existingChoco = Get-Command choco.exe -ErrorAction SilentlyContinue
    if ($existingChoco) {
        $existingPath = Split-Path $existingChoco.Source -Parent
        Write-Status WARN "Chocolatey already installed at: $existingPath"
        Write-Host "Do you want to remove and reinstall? (Y/N)" -ForegroundColor Yellow
        $choice = Read-Host
        if ($choice -match '^[Yy]$') {
            Remove-Choco
        } else {
            Write-Status INFO "Installation aborted by user."
            exit 0
        }
    }

    try {
        $env:ChocolateyInstall = $installPath
        [Environment]::SetEnvironmentVariable('ChocolateyInstall', $installPath, 'User')
        Write-Status OK "ChocolateyInstall variable set to $installPath"
    }
    catch {
        Write-Status ERROR "Failed to set environment variable: $($_.Exception.Message)"
        exit 1
    }

    if (-not (Test-Path $profilePath)) {
        New-Item -ItemType File -Path $profilePath -Force | Out-Null
        Write-Status OK "Profile created at $profilePath"
    }

    # Capture profile before
    $profileBefore = Get-Content -Path $profilePath -Raw

    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        $chocoInstallScript = 'https://community.chocolatey.org/install.ps1'
        iex ((New-Object System.Net.WebClient).DownloadString($chocoInstallScript))
        Write-Status OK "Chocolatey installation complete!"
    }
    catch {
        Write-Status ERROR "Chocolatey installation failed: $($_.Exception.Message)"
        exit 1
    }

    # Capture profile after
    $profileAfter = Get-Content -Path $profilePath -Raw

    # Save the difference
    Save-ProfileDiff -BeforeContent $profileBefore -AfterContent $profileAfter
}

# -------------------------------
# Main
# -------------------------------
if (-not $Action) {
    Write-Host ""
    Write-Host "Choose an action:" -ForegroundColor Cyan
    Write-Host "1) Install Chocolatey" -ForegroundColor Yellow
    Write-Host "2) Remove Chocolatey"  -ForegroundColor Yellow
    $choice = Read-Host "Enter choice (1 or 2)"
    switch ($choice) {
        "1" { $Action = "install" }
        "2" { $Action = "remove" }
        default {
            Write-Status ERROR "Invalid choice. Exiting."
            exit 1
        }
    }
}

switch ($Action) {
    "install" { Install-Choco }
    "remove"  { Remove-Choco }
}
