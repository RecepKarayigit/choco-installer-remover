# List of standard programs
$programs = @(
    "googlechrome",
    "firefox",
    "vscode",
    "git",
    "7zip",
    "notepadplusplus",
    "vlc",
    "spotify"
)

foreach ($app in $programs) {
    Write-Host "Installing $app..."
    choco install $app -y
}
Write-Host "All programs installed!"

Write-Host "`nInstalled Programs"
choco list lo