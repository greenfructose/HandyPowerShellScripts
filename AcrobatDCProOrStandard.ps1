# Define the registry key and value you want to check
$regSubKeyPath = "Software\Adobe\Adobe Acrobat\DC\AVGeneral"
$regValueName = "bCheckForUpdatesAtStartup"

# Get all user profiles from the system
$userProfiles = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList'

foreach ($profile in $userProfiles) {
    $sid = $profile.PSChildName
    $profilePath = $profile.GetValue("ProfileImagePath")
    
    # Exclude system profiles
    if ($profilePath -notlike '*systemprofile*' -and $profilePath -notlike '*LocalService*' -and $profilePath -notlike '*NetworkService*') {

        # Attempt to load the user's hive if not already loaded
        if (-not (Test-Path "Registry::HKEY_USERS\$sid")) {
            try {
                $ntUserDat = Join-Path $profilePath 'NTUSER.DAT'
                if (Test-Path $ntUserDat) {
                    reg load "HKU\$sid" $ntUserDat | Out-Null
                    $hiveLoaded = $true
                } else {
                    Write-Host "NTUSER.DAT not found for SID $sid at path $ntUserDat"
                    continue
                }
            } catch {
                Write-Host "Failed to load hive for SID $sid: $_"
                continue
            }
        } else {
            $hiveLoaded = $false
        }

        # Now access the desired registry key
        $userRegKeyPath = "Registry::HKEY_USERS\$sid\$regSubKeyPath"
        if (Test-Path $userRegKeyPath) {
            $regValue = Get-ItemProperty -Path $userRegKeyPath -Name $regValueName -ErrorAction SilentlyContinue
            if ($regValue) {
                Write-Host "User SID: $sid"
                Write-Host "Adobe Update Check at Startup (bCheckForUpdatesAtStartup): $($regValue.$regValueName)"
                Write-Host "-------------------------------------------"
            } else {
                Write-Host "User SID: $sid - Value $regValueName not found."
            }
        } else {
            Write-Host "Registry path $userRegKeyPath does not exist for SID $sid."
        }

        # Unload the hive if we loaded it
        if ($hiveLoaded) {
            reg unload "HKU\$sid" | Out-Null
        }
    }
}
