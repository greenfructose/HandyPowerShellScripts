# List of Windows Update endpoints for Windows 10 21H2
$endpoints = @(
    "http://ctldl.windowsupdate.com",
    "http://www.msftncsi.com",
    "http://www.msftconnecttest.com",
    "https://fg.ds.b1.download.windowsupdate.com",
    "https://sls.update.microsoft.com",
    "https://fe3.delivery.mp.microsoft.com",
    "https://analogshield.microsoft.com",
    "https://fe3cr.delivery.mp.microsoft.com"
)

# Function to test connectivity
function Test-Connectivity {
    param (
        [string]$Url
    )
    
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Host "Connection to $Url successful." -ForegroundColor Green
        } else {
            Write-Host "Connection to $Url failed. Status code: $($response.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Connection to $Url failed. Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Test connectivity to each endpoint
foreach ($endpoint in $endpoints) {
    Test-Connectivity -Url $endpoint
}

Write-Host "`nConnectivity test completed." -ForegroundColor Cyan
