# Function to check if a cipher suite is vulnerable to ROBOT
function Is-VulnerableToROBOT {
    param (
        [string]$CipherSuite
    )
    
    $vulnerableCiphers = @(
        "TLS_RSA_WITH_AES_128_CBC_SHA",
        "TLS_RSA_WITH_AES_256_CBC_SHA",
        "TLS_RSA_WITH_AES_128_CBC_SHA256",
        "TLS_RSA_WITH_AES_256_CBC_SHA256",
        "TLS_RSA_WITH_3DES_EDE_CBC_SHA",
        "TLS_RSA_WITH_RC4_128_SHA"
    )

    return $vulnerableCiphers -contains $CipherSuite
}

# Get all enabled SSL/TLS cipher suites
$enabledCiphers = Get-TlsCipherSuite | Where-Object { $_.Name -like "TLS_RSA*" }

# Filter vulnerable cipher suites
$vulnerableCiphers = $enabledCiphers | Where-Object { Is-VulnerableToROBOT $_.Name }

# Display results
if ($vulnerableCiphers.Count -gt 0) {
    Write-Host "The following TLS cipher suites are vulnerable to ROBOT attacks:"
    $vulnerableCiphers | Format-Table Name, KeyType, Exchange, Hash, Cipher
    
    Write-Host "`nRecommendation: Consider disabling these cipher suites to mitigate ROBOT vulnerability."
    Write-Host "You can disable a cipher suite using the following command:"
    Write-Host "Disable-TlsCipherSuite -Name 'CIPHER_SUITE_NAME'"
} else {
    Write-Host "No TLS cipher suites vulnerable to ROBOT attacks were found."
}

# Check TLS 1.0 and 1.1 status
$tls10 = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client' -Name 'Enabled' -ErrorAction SilentlyContinue).Enabled
$tls11 = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client' -Name 'Enabled' -ErrorAction SilentlyContinue).Enabled

Write-Host "`nTLS Protocol Status:"
Write-Host "TLS 1.0: $( if ($tls10 -eq 1) { 'Enabled' } elseif ($tls10 -eq 0) { 'Disabled' } else { 'Not configured' } )"
Write-Host "TLS 1.1: $( if ($tls11 -eq 1) { 'Enabled' } elseif ($tls11 -eq 0) { 'Disabled' } else { 'Not configured' } )"

if ($tls10 -eq 1 -or $tls11 -eq 1) {
    Write-Host "`nRecommendation: Consider disabling TLS 1.0 and 1.1 as they are outdated and potentially vulnerable."
}
