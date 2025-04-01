# clean-git-path.ps1
# This script removes duplicate Git paths from the system PATH variable
# and ensures only the correct Git paths remain.
# Requires Administrator privileges to run

# Check for administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script requires Administrator privileges to modify system PATH."
    Write-Warning "Please re-run this script as Administrator."
    exit 1
}

# Get the current system PATH
$systemPath = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::Machine)
$userPath = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::User)

Write-Host "Processing system PATH..." -ForegroundColor Cyan

# Split the PATH into individual entries
$systemPathEntries = $systemPath -split ";"
$userPathEntries = $userPath -split ";"

# Normalize paths (handle different formats of backslashes, trailing slashes, etc.)
$normalizedSystemEntries = $systemPathEntries | ForEach-Object { 
    if ($_ -ne "") { 
        $normalized = $_ -replace "\\\\", "\" -replace "\\+$", ""
        [System.IO.Path]::GetFullPath($normalized + "\") 
    }
}

$normalizedUserEntries = $userPathEntries | ForEach-Object { 
    if ($_ -ne "") { 
        $normalized = $_ -replace "\\\\", "\" -replace "\\+$", ""
        [System.IO.Path]::GetFullPath($normalized + "\") 
    }
}

# Define the correct Git paths we want to keep
$correctGitPaths = @(
    "C:\Program Files\Git\cmd\",
    "C:\Program Files\Git\bin\",
    "C:\Program Files\Git\usr\bin\"
)

# Find all Git-related paths
$gitSystemPaths = $normalizedSystemEntries | Where-Object { $_ -like "*\Git\*" }
$gitUserPaths = $normalizedUserEntries | Where-Object { $_ -like "*\Git\*" }

Write-Host "Current Git paths in system PATH:" -ForegroundColor Yellow
$gitSystemPaths | ForEach-Object { Write-Host "  $_" }

Write-Host "Current Git paths in user PATH:" -ForegroundColor Yellow
$gitUserPaths | ForEach-Object { Write-Host "  $_" }

# Remove all Git paths from system and user PATH
$newSystemPathEntries = $normalizedSystemEntries | Where-Object { $_ -notlike "*\Git\*" }
$newUserPathEntries = $normalizedUserEntries | Where-Object { $_ -notlike "*\Git\*" }

# Add the correct Git paths to system PATH
foreach ($path in $correctGitPaths) {
    if (Test-Path $path) {
        $newSystemPathEntries += $path
        Write-Host "Added correct Git path: $path" -ForegroundColor Green
    }
    else {
        Write-Host "Warning: Git path does not exist: $path" -ForegroundColor Red
    }
}

# Join the path entries back together
$newSystemPath = $newSystemPathEntries -join ";"
$newUserPath = $newUserPathEntries -join ";"

# Update the PATH environment variables
[Environment]::SetEnvironmentVariable("PATH", $newSystemPath, [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable("PATH", $newUserPath, [EnvironmentVariableTarget]::User)

Write-Host "`nPATH environment variables updated successfully." -ForegroundColor Green
Write-Host "Please restart any open terminal windows or applications for changes to take effect." -ForegroundColor Cyan
Write-Host "`nThe following Git paths are now in your system PATH:" -ForegroundColor Green
$correctGitPaths | ForEach-Object { Write-Host "  $_" }

