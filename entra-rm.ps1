# Get serials from serials.csv
# If serials.csv is empty: exit
$serials = Get-Content .\serials.csv
if (!$serials){Write-Host("[Alert] serials.csv file empty!"); exit}

# Connect to Entra and add devices to $entraDevices
Import-Module Microsoft.Graph.Authentication -RequiredVersion "2.15.0"
Connect-Entra -Scopes "Device.Read.All" -NoWelcome
$entraDevices = Get-EntraDevice -All

# Create an empty array to store matching devices
$matchingEntraDevices = @()
# Check if serials.csv matches the last 8 characters of the DisplayName
foreach ($serial in $serials) {
    $matchedDevices = $entraDevices | Where-Object {
        if ($_.DisplayName.Length -gt 8) {
            $_.DisplayName.Substring($_.DisplayName.Length - 8) -match [regex]::Escape($serial)
        }
    }
    $matchingEntraDevices += $matchedDevices
}

# Display device amount and their corresponding names
Write-Host("Added following devices to list [amount: $($matchingEntraDevices.Count)]:`n $($matchingEntraDevices.DisplayName -join ' | ')")

# Confirmation and Deletion Process
$confirmation = Read-Host "`nFound devices listed above will be deleted from Entra. Are you sure you want to proceed? (Y/N)"
if ($confirmation -eq 'y') {
    Write-Host("Accepted. Deleting $($matchingEntraDevices.Count) devices from Entra")
    Foreach ($Device in $matchingEntraDevices)
        {
            Write-Host("Deleting device: $($Device.DisplayName) with the ID: $($Device.ObjectId)")
            Remove-EntraDevice -ObjectId $Device.ObjectId
        }
} 
else {
    Write-Host("User cancelled deletion.")
    exit(0)
}