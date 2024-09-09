$jreRegKey = "HKLM:\SOFTWARE\JavaSoft\Java Runtime Environment"
$sdkRegKey = "HKLM:\SOFTWARE\JavaSoft\Java Development Kit"

Function Get-AmazonJreVersion {
    $jreVersion = (Get-ItemProperty -Path $jreRegKey -Name "CurrentVersion").CurrentVersion
    return $jreVersion
}

Function Get-AmazonSdkVersion {
    $sdkVersion = (Get-ItemProperty -Path $sdkRegKey -Name "CurrentVersion").CurrentVersion
    return $sdkVersion
}

Function Get-ProcessesUsingJre {
    $jreVersion = Get-AmazonJreVersion
    $processes = Get-Process | Where-Object { $_.Modules.FileName -like "*$jreVersion*" }
    return $processes
}

Function Get-ProcessesUsingSdk {
    $sdkVersion = Get-AmazonSdkVersion
    $processes = Get-Process | Where-Object { $_.Modules.FileName -like "*$sdkVersion*" }
    return $processes
}

Write-Host "Amazon JRE Version: " (Get-AmazonJreVersion)
Write-Host "Amazon SDK Version: " (Get-AmazonSdkVersion)

Write-Host "Processes using Amazon JRE:"
(Get-ProcessesUsingJre) | Select-Object ProcessName, Id
Write-Host "Processes using Amazon SDK:"
(Get-ProcessesUsingSdk) | Select-Object ProcessName, Id
