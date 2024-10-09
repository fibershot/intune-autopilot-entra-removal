# intune-autopilot-entra-removal 
Scripts, which were created for the removal of devices with serial numbers in Intune, Autopilot and Entra.<br/>

# Information ℹ️
The hellscape that are the Windows PowerShell modules and dependencies, I wanted to find out what the minimal requirements were (for me) for a safe (arguable) way to remove devices from Intune, Autopilot and Entra with a script. Anywhere I looked stuff was out of date or simply not working.

These scripts have been tested to be working on a brand new computer as of 9.10.2024.

If you have questions you can send an email to tonkotop@tonko.top

# Proceed with caution! ⚠️
Please read the source code for the scripts to make sure the use case is safe for your tenant!

I've tried to add as many safety checks as possible, so deletion won't happen without your consent!

The use case for the following scripts are as follows:
 - Your devices contain the serial number within their display names! (e.g EDC99<strong>ABC123456</strong> where ABC123456 is the serial)
   - In the Entra script the script will check the last 8 chars of the DisplayName!
 - Make sure serials.csv contains the full serial numbers seperated by a linebreak!
 - Before confirming deletion, make sure to check only the devices you listed in .csv are present!
Safety checks:
 - Alert user if devices returned more than the length of serials.csv
 - Display user which devices were found
 - Require user confirmation before deletion
 - Log in the console which devices were deleted
 - Do not change anything if the user declines deletion

# Requirements 📝
Entra script will run on PowerShell 7 or higher
 - Download PowerShell here [PowerShell releases](https://github.com/PowerShell/PowerShell/releases)
 - Learn more here [Installing PowerShell on Windows](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.4)

There is a script for installing the following modules. Please read before continuing.
    AzureAD                                Version - 2.0.2.182
    Microsoft.Graph.Authentication         Version - 2.23.0
    Microsoft.Graph.DeviceManagement       Version - 2.23.0
    Microsoft.Graph.Intune"                Version - 6.1907.1.0
    Microsoft.Graph.Entra                  Version - 0.15.0

# Usage 📜
ExecutionPolicy:<br/>
Set-ExecutionPolicy Unrestricted -Scope CurrentUser

<strong>Using PowerShell 5:</strong><br/>
Run .\install-modules.ps1 to install the required modules and their versions.<br/>
Run .\intra-autopilot-rm.ps1 to remove devices from Intune and Autopilot.
 - Note: Add your appId at the start of the script and save before running.

<strong>Using PowerShell 7 or higher:</strong><br/>
Run .\entra-rm.ps1 to remove devices from Entra.
Open a terminal for PowerShell 7 or higher.

In both cases login to your Microsoft account and follow the instuctions on the screen.<br/>No other user input is required after login that isn't yes or no (Y/N).

It's (hopefully) really that simple!
