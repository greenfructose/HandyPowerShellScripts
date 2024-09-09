# Function to check if a file contains Silverlight references
function Test-SilverlightDependency {
    param (
        [string]$FilePath
    )
    
    if (Test-Path $FilePath) {
        $content = Get-Content $FilePath -Raw
        return $content -match "Silverlight"
    }
    return $false
}

# Get all installed applications
$installedApps = Get-WmiObject -Class Win32_Product | Select-Object Name, Version, InstallLocation

$silverlightApps = @()

foreach ($app in $installedApps) {
    $appPath = $app.InstallLocation
    if ($appPath) {
        $configFiles = Get-ChildItem -Path $appPath -Recurse -Include *.exe.config, *.dll.config, *.config -ErrorAction SilentlyContinue
        
        foreach ($file in $configFiles) {
            if (Test-SilverlightDependency $file.FullName) {
                $silverlightApps += [PSCustomObject]@{
                    Name = $app.Name
                    Version = $app.Version
                    ConfigFile = $file.FullName
                }
                break  # Stop checking other config files for this app once we find a match
            }
        }
    }
}

# Display results
if ($silverlightApps.Count -gt 0) {
    Write-Host "Applications potentially using Silverlight:"
    $silverlightApps | Format-Table -AutoSize
} else {
    Write-Host "No applications were found that appear to use Silverlight."
}

# Check for Silverlight installation
$silverlightInstalled = Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE '%Silverlight%'"
if ($silverlightInstalled) {
    Write-Host "`nMicrosoft Silverlight is installed on this system."
    $silverlightInstalled | Format-Table Name, Version -AutoSize
} else {
    Write-Host "`nMicrosoft Silverlight is not installed on this system."
}
