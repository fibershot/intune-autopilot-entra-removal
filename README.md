# intune-autopilot-entra-removal
Scripts, which were created for the removal of devices with serial numbers in Intune, Autopilot and Entra.
Is unstable, do not use yet, in production.

# Information ℹ️
The hellscape that are the Windows PowerShell modules and dependencies, I wanted to find out what the minimal requirements were (for me) for a safe (arguable) way to remove devices from Intune, Autopilot and Entra with a script.
Anywhere I looked stuff was out of date or simply not working. These scripts have been tested as working as of 1.10.2024 on a new device.

If you have questions you can send an email to tonkotop@tonko.top

# Proceed with caution! ⚠️
Please read the source code for the scripts to make sure the use case is safe for your tenant!

I've tried to add as many safety checks as possible, so deletion won't happen without your consent!

The use case for the following scripts are as follows:
 - Your devices contain the serial number within their display names!
 - Make sure serials.csv contains the full serial numbers seperated by a linebreak!
 - Before confirming deletion, make sure to check only the devices you listed in .csv are present!
Safety checks:
 - Alert user if devices returned more than the length of serials.csv
 - Display user which devices were found
 - Require user confirmation before deletion
 - Log in the console which devices were deleted
 - Do not change anything if the user declines deletion
 - If no devices are found skip automatically

# Requirements 📝
All of the scripts run (or have ran) on PowerShell 7.4.5
 - Download PowerShell here [PowerShell releases](https://github.com/PowerShell/PowerShell/releases)
 - Learn more here [Installing PowerShell on Windows](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.4)

There is a script for installing the following modules. Please read before continuing.
 - Microsoft.Graph
 - Microsoft.Graph.Entra
 - Microsoft.Graph.Authentication (Versions 2.15.0 & 2.23.0)
 - AzureAd
The scope for the modules has been set to use the -Scope of AllUsers.

# Usage 📜
Open (intune autopilot).ps1 to input your APP_ID in the -AppId argument and save the file.<br/>Nothing has to be changed for (entra script name).ps1

Open a terminal for PowerShell 7 or higher (Recommended to use administrator).

Use (insert script name here) to check if the modules are installed. If they aren't the script attempts to install them.

For Intune and Autopilot removal execute .\scriptname.ps1<br/>For Entra removal execute .\scriptname2.ps1

First login to your Microsoft account and follow the instuctions on the screen.<br/>No other user input is required after login that isn't yes or no (Y/N).

It's (hopefully) really that simple!
