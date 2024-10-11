# Function to get processes using SQL Server Compact 4.0
function Get-SqlCompactProcesses {
    $sqlCompactDll = "sqlceme40.dll"
    
    try {
        $processes = Get-Process | Where-Object {
            $_.Modules | Where-Object { $_.ModuleName -eq $sqlCompactDll }
        } | Select-Object Id, ProcessName, @{
            Name="MainModule";
            Expression={ $_.MainModule.FileName }
        }
        
        return $processes
    }
    catch {
        Write-Error "An error occurred while searching for processes: $_"
        return $null
    }
}

# Main script
Write-Host "Searching for processes using Microsoft SQL Server Compact 4.0..."

$sqlCompactProcesses = Get-SqlCompactProcesses

if ($sqlCompactProcesses) {
    Write-Host "The following processes are currently using Microsoft SQL Server Compact 4.0:"
    $sqlCompactProcesses | Format-Table -AutoSize
}
else {
    Write-Host "No processes were found that are currently using Microsoft SQL Server Compact 4.0."
}

Write-Host "Search completed."
