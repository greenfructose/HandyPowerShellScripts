# Define variables
$adobeVersion = $null
$found = $false

# Registry paths to check
$uninstallPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

# Target version to compare
$targetVersion = [Version]"24.002.20991"

foreach ($path in $uninstallPaths) {
    if (Test-Path $path) {
        $subKeys = Get-ChildItem -Path $path
        foreach ($subKey in $subKeys) {
            $keyPath = $subKey.PSPath
            $displayName = (Get-ItemProperty -Path $keyPath -Name "DisplayName" -ErrorAction SilentlyContinue).DisplayName
            if ($displayName -like "Adobe Acrobat*DC*") {
                $adobeVersionString = (Get-ItemProperty -Path $keyPath -Name "DisplayVersion" -ErrorAction SilentlyContinue).DisplayVersion
                if ($adobeVersionString) {
                    $found = $true
                    # Convert version strings to [Version] objects for comparison
                    $installedVersion = [Version]$adobeVersionString
                    # Compare versions
                    if ($installedVersion -le $targetVersion) {
                        Write-Output "Installed Adobe Acrobat DC version $adobeVersionString is equal to or less than 24.002.20991."
                    } else {
                        Write-Output "Installed Adobe Acrobat DC version $adobeVersionString is greater than 24.002.20991."
                    }
                }
                break
            }
        }
    }
    if ($found) { break }
}

if (-not $found) {
    Write-Output "Adobe Acrobat DC is not installed."
}
