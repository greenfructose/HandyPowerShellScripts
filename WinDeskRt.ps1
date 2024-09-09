# Function to get .NET Runtime version from a process
function Get-ProcessRuntimeVersion {
    param (
        [System.Diagnostics.Process]$Process
    )
    
    try {
        $modules = $Process.Modules
        foreach ($module in $modules) {
            if ($module.ModuleName -like "hostfxr.dll") {
                $fileVersion = $module.FileVersionInfo.FileVersion
                return $fileVersion
            }
        }
    }
    catch {
        return $null
    }
    
    return $null
}

# Get all running processes
$processes = Get-Process

# Initialize an empty array to store results
$results = @()

foreach ($process in $processes) {
    $runtimeVersion = Get-ProcessRuntimeVersion -Process $process
    
    if ($runtimeVersion) {
        $results += [PSCustomObject]@{
            ProcessName = $process.ProcessName
            PID = $process.Id
            RuntimeVersion = $runtimeVersion
        }
    }
}

# Display results
if ($results.Count -gt 0) {
    Write-Host "Processes using Microsoft Windows Desktop Runtime:"
    $results | Format-Table -AutoSize
}
else {
    Write-Host "No processes were found using Microsoft Windows Desktop Runtime."
}

# Get installed .NET Desktop Runtime versions
Write-Host "`nInstalled .NET Desktop Runtime versions:"
Get-ChildItem "HKLM:\SOFTWARE\dotnet\Setup\InstalledVersions\x64\sharedfx\Microsoft.WindowsDesktop.App" -ErrorAction SilentlyContinue | 
    ForEach-Object { $_.PSChildName } | 
    ForEach-Object { Write-Host $_ }
