# Define the URL of the zip file
$zipUrl = 'https://example.com/path/to/your/file.zip'

# Define the local path and name for the downloaded zip file
$zipFile = Join-Path -Path (Get-Location) -ChildPath 'downloaded_file.zip'

# Download the zip file
Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile

# Extract the zip file to the current directory
Expand-Archive -LiteralPath $zipFile -DestinationPath (Get-Location) -Force

# Optionally, delete the zip file after extraction
Remove-Item -Path $zipFile -Force
