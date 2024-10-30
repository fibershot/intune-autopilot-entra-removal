# Input your own APP_ID here
$APP_ID = "APP_ID"

# Get serial numbers from .csv file.
# If no serials, exit
$serials = Get-Content .\serials.csv
if (!$serials){
    Write-Host("[Info] serials.csv is empty. Exiting...")
    exit(0)
}

# Import required modules
Import-Module Microsoft.Graph.Authentication -RequiredVersion "2.23.0"
Import-Module Microsoft.Graph.Intune
Import-Module AzureAD

# Prepare MSGraph environment and attach AppId
# Then, login to MgGraph, MsGraph
Update-MSGraphEnvironment -GraphBaseUrl 'https://graph.microsoft.com' -AppId $APP_ID -GraphResourceId 'https://graph.microsoft.com' -SchemaVersion 'beta'
Connect-MgGraph -NoWelcome
Connect-MsGraph

# Intune segment
# Fetch all of the data
# Parse serial numbers from fetched data and save matches of the .cvs file
Write-Host("[Info] Searching serial(s): $($serials)")
$Devices = Get-MgDeviceManagementManagedDevice -All
$matchingDevices = $Devices | Where-Object { $serials -contains $_.SerialNumber }

# If results for matching data are 0 or less ask the user to continue to AutoPilot or exit.
# Otherwise, list all of the device SN:s and ID:s for viewing
if ($matchingDevices.SerialNumber.Length -le 0) {
    Write-Host("[Alert] No devices found with matching serials!")
    $continueWithNoDevices = Read-Host("[Prompt] Would you wish to continue to Autopilot? (y/N)")
    if ($continueWithNoDevices -eq "y") { Write-Host("[Info] Continuing to Autopilot`n`n") } else { exit(0) }
} else {
    Foreach ($Device in $matchingDevices)
    {
        Write-Host("[Info] Device found: " + $Device.SerialNumber + " " + $Device.Id)
    }
}

# If the amount of found devices is larger than the length of serials.csv, ask if the user would like to quit.
if ($matchingDevices.SerialNumber.Length -gt $serials.Length) {
    $alert = Read-Host("[Alert] Found more devices than entries in serials.csv.`n[Prompt] Do you wish to continue? (y/N)")
    if ($alert -eq "y"){ Write-Host("[Info] User agreed to continue.`n`n") } else {Write-Host("[Info] User interrupted program.`n")exit(0)}
}


# Ask the user for confirmation after posting a listing of the devices
# If confirmation goes through, delete the devices from Intune with the $Device.Id
# If the confirmation is rejected, do not do changes and move to AutoPilot
# If no devices were found and the user wishes to continue to autopilot, skip this statement
if (-not $continueWithNoDevices -eq "y"){
    $confirmation = Read-Host "`n[Intune] Found devices listed above will be deleted from Intune.`n[Prompt] Are you sure you want to proceed? (y/N)"
    if ($confirmation -eq 'y') {
        Write-Host("[Intune] Accepted. Deleting $($matchingDevices.Count) devices from Intune")
        Foreach ($Device in $matchingDevices)
            {
                Write-Host("[Info] Deleting device: $($Device.SerialNumber) and with the ID: $($Device.Id)")
                Remove-IntuneManagedDevice -managedDeviceId $Device.Id
            }
    } 
    else {
        Write-Host("[Info] User cancelled deletion.`n`n")
	    $continueWithNoDevices = "y"
    }
}

# Check if devices are deleted every one minute
# If they're deleted, continue to next segment
if (-not $continueWithNoDevices -eq "y"){
    Write-Host("[Info]Checking if devices have been deleted before continuing")
    Write-Host("[Info] Waiting for one minute...")
    $devicesDeleted = $false
    while (-not $devicesDeleted){
        Start-Sleep -Seconds (1 * 60)
        $Devices = Get-MgDeviceManagementManagedDevice -All
        $matchingDevices = $Devices | Where-Object { $serials -contains $_.SerialNumber }
        if ($matchingDevices.Count -eq 0) {
            Write-Host("[Info] All devices have been successfully deleted, continuing.`n`n")
            $devicesDeleted = $true
        } else {
            Write-Host("[Info] Devices still found. Waiting another minute...")
            
            # Inform user what devices are still left
            Foreach ($Device in $matchingDevices) {
                Write-Host("[Info] Device still found: " + $Device.SerialNumber + " " + $Device.Id)
            }
        }
    }
}

# Autopilot segment
# Fetch Autopilot devices
$fetchAPD = Invoke-MSGraphRequest -HttpMethod GET -Url "deviceManagement/windowsAutopilotDeviceIdentities"
$autoPilotDevices = $fetchAPD.value

# Parse fetched data
$parseAPD = $fetchAPD."@odata.nextLink"

while ($parseAPD) {
    $fetchAPD = Get-MSGraphNextPage -NextLink $parseAPD
    $parseAPD = $fetchAPD."@odata.nextLink"
    $autoPilotDevices += $fetchAPD.value
}

# Display amount of discovered devices and how many of them contain the searched serials
Write-Host "[Info] $(($autoPilotDevices | Measure-Object).Count) devices found in Autopilot"
$matchingAPDevices = $autoPilotDevices | Where-Object { $serials -contains $_.SerialNumber }

# Inform if no devices were found. Otherwise, list them.
if ($matchingAPDevices.SerialNumber.Length -le 0) {
    Write-Host("[Alert] No devices found with matching serials in Autopilot!`n")
    exit(0)
} else {
    Foreach ($Device in $matchingAPDevices)
    {
        Write-Host("[Info] Device found: $($Device.serialNumber)")
    }
}

# If the amount of found devices is larger than the length of serials.csv, ask if the user would like to quit.
if ($matchingAPDevices.SerialNumber.Length -gt $serials.Length){
    $alert = Read-Host("[Alert] Found more devices than entries in serials.csv.`n[Prompt] Do you wish to continue? (y/N)")
    if ($alert -eq "y"){ continue; } else { exit (0) }
}


# Ask the user for confirmation after posting a listing of the devices
# If confirmation goes through, delete the devices from Autopilot with the $Device.id
# If the confirmation is rejected, do not do changes and terminate the program

if (-not $Automated) {
    $confirmation = Read-Host "`n[Autopilot] Found devices listed above will be deleted from Autopilot.`n[Prompt] Are you sure you want to proceed? (y/N)"
    if ($confirmation -eq 'y') {
        Write-Host("[Autopilot] Accepted. Deleting $($matchingAPDevices.Count) devices from Autopilot")
        Foreach ($Device in $matchingAPDevices)
        {
            Write-Host("[Info] Deleting device: $($Device.serialNumber) with the screen name $($Device.displayName)")
            Invoke-MSGraphRequest -HttpMethod DELETE -Url "deviceManagement/windowsAutopilotDeviceIdentities/$($Device.id)"
        } 
    } 
    else {
        Write-Host("[Info] User cancelled deletion.")
        exit(0)
    }
} 

# Check if devices are deleted every minute
# If they're deleted, continue to the end
$devicesDeleted = $false
Write-Host("[Info] Checking if devices have been deleted before continuing")
Write-Host("[Info] Waiting for a minute...")
while (-not $devicesDeleted) {
    Start-Sleep -Seconds (1 * 60)

    $fetchAPD = Invoke-MSGraphRequest -HttpMethod GET -Url "deviceManagement/windowsAutopilotDeviceIdentities"
    $autoPilotDevices = $fetchAPD.value

    $parseAPD = $fetchAPD."@odata.nextLink"

    while ($parseAPD) {
        $fetchAPD = Get-MSGraphNextPage -NextLink $parseAPD
        $parseAPD = $fetchAPD."@odata.nextLink"
        $autoPilotDevices += $fetchAPD.value
    }

    $matchingAPDevices = $autoPilotDevices | Where-Object { $serials -contains $_.serialNumber }
    if ($matchingAPDevices.Count -eq 0) {
        Write-Host("[Success] All devices have been successfully deleted from Autopilot.")
        $devicesDeleted = $true
    } else {
        Write-Host("[Info] Devices still found in Autopilot. Waiting another minute...")
        Foreach ($Device in $matchingAPDevices) {
            Write-Host("[Info] Device still found: $($Device.serialNumber) with display name: $($Device.displayName)")
        }
    }
}