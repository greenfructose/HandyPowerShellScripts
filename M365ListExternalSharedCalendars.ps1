# Connect to Exchange Online PowerShell
try {
    Connect-ExchangeOnline -ErrorAction Stop
}
catch {
    Write-Error "Failed to connect to Exchange Online. Please ensure you have the Exchange Online PowerShell module installed."
    Write-Error "Install it using: Install-Module -Name ExchangeOnlineManagement"
    exit
}

# Initialize array to store results
$results = @()

# Get all mailboxes
Write-Host "Retrieving all mailboxes..."
$mailboxes = Get-Mailbox -ResultSize Unlimited

# Process each mailbox
foreach ($mailbox in $mailboxes) {
    Write-Host "Checking calendar permissions for $($mailbox.DisplayName)..."
    
    try {
        # Get calendar folder
        $calendar = Get-MailboxFolderStatistics $mailbox.Identity -FolderScope Calendar | 
            Where-Object {$_.FolderType -eq "Calendar"} | 
            Select-Object -First 1
        
        if ($calendar) {
            $calendarPath = $mailbox.Identity.ToString() + ":\" + $calendar.FolderPath.Replace("/", "\")
            
            # Get calendar permissions
            $permissions = Get-MailboxFolderPermission -Identity $calendarPath -ErrorAction SilentlyContinue
            
            # Check for external permissions
            $externalPermissions = $permissions | Where-Object {
                $_.User.DisplayName -eq "Default" -or 
                $_.User.DisplayName -eq "Anonymous" -or 
                $_.User.RecipientPrincipal.ExternalDirectoryObjectId
            }
            
            if ($externalPermissions) {
                foreach ($perm in $externalPermissions) {
                    $results += [PSCustomObject]@{
                        Mailbox = $mailbox.DisplayName
                        Email = $mailbox.PrimarySmtpAddress
                        ExternalUser = $perm.User.DisplayName
                        AccessLevel = $perm.AccessRights -join ','
                        CalendarName = $calendar.Name
                    }
                }
            }
        }
    }
    catch {
        Write-Warning "Error processing $($mailbox.DisplayName): $_"
    }
}

# Export results to CSV
$date = Get-Date -Format "yyyy-MM-dd_HH-mm"
$exportPath = ".\ExternalCalendarSharing_$date.csv"
$results | Export-Csv -Path $exportPath -NoTypeInformation

# Display summary
Write-Host "`nScan Complete!"
Write-Host "Total mailboxes scanned: $($mailboxes.Count)"
Write-Host "Calendars with external sharing: $($results.Count)"
Write-Host "Results exported to: $exportPath"

# Disconnect from Exchange Online
Disconnect-ExchangeOnline -Confirm:$false
