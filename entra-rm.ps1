# Import required modules
Import-Module Microsoft.Graph.Authentication -RequiredVersion "2.15.0"
Import-Module Microsoft.Graph.Entra

# Connect to Entra and fetch all devices
Connect-Entra -Scopes "Device.Read.All"
$entraDevices = Get-EntraDevice
$matchingEntraDevices = $entraDevices | Where-Object { $entraDevices.DisplayName -contains $_.SerialNumber }

Write-Host("[Info] Found device: $($matchingEntraDevices.DisplayName)")

# If there are no devices, exit
if ($matchingEntraDevices.SerialNumber.Length -le 0) {
    Write-Host("[Alert] No devices found with matching IDs!")
    exit(0)
} else {
    Foreach ($Device in $matchingEntraDevices)
    {
        Write-Host("[Info] Found " + $Device. + $Device.id)
    }
}

# Confirmation and deletion of devices
$confirmation = Read-Host "`n[Entra] Found devices listed above will be deleted from Entra.`n[Prompt] Are you sure you want to proceed? (y/N)"
if ($confirmation -eq 'y') {
    Write-Host("[Entra] Accepted. Deleting $($matchingEntraDevices.Count) devices from Entra")
    Foreach($device in $matchingEntraDevices) 
    {
        Write-Host "[Info] Deleting device $($device.id), serial: $($device.serialNumber)) from Entra"
        Remove-AzureADDevice -ObjectId $device.azureActiveDirectoryDeviceId
    }
} else {
    Write-Host("[Info] User cancelled deletion.")
    exit(0)
}