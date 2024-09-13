# Updated list of Windows Update endpoints
$endpoints = @(
    "https://update.microsoft.com",
    "https://download.microsoft.com",
    "https://delivery.mp.microsoft.com",
    "https://windowsupdate.com",
    "https://ctldl.windowsupdate.com",
    "https://www.microsoft.com",
    "http://www.msftconnecttest.com",
    "https://sls.update.microsoft.com",
    "https://fe3.delivery.mp.microsoft.com"
)

# Function to test connectivity
function Test-Connectivity {
    param (
        [string]$Url
    )
    
    try {
        $request = [System.Net.WebRequest]::Create($Url)
        $request.Method = "HEAD"
        $request.Timeout = 10000  # 10 seconds timeout

        $response = $request.GetResponse()
        $status = [int]$response.StatusCode
        $response.Close()

        if ($status -eq 200) {
            Write-Host "Connection to $Url successful (Status: $status)" -ForegroundColor Green
        } else {
            Write-Host "Connection to $Url returned status: $status" -ForegroundColor Yellow
        }
    } catch [System.Net.WebException] {
        $status = [int]$_.Exception.Response.StatusCode
        Write-Host "Connection to $Url failed (Status: $status). Error: $($_.Exception.Message)" -ForegroundColor Red
    } catch {
        Write-Host "Connection to $Url failed. Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Test connectivity to each endpoint
foreach ($endpoint in $endpoints) {
    Test-Connectivity -Url $endpoint
}

Write-Host "`nConnectivity test completed." -ForegroundColor Cyan
