# install-modules.ps1
# This script installs required PowerShell modules on a new machine. NOTE: Might work BETTER on a NEW machine
function Install-ModuleIfNotPresent {
    param (
        [string]$ModuleName,
        [string]$RequiredVersion
    )
 
    # Check if the module is installed
    $module = Get-Module -ListAvailable -Name $ModuleName -RequiredVersion $RequiredVersion
 
    if (-not $module) {
        Write-Host "$ModuleName (version $RequiredVersion) not found. Installing..." -ForegroundColor Yellow
        try {
            Install-Module -Name $ModuleName -RequiredVersion $RequiredVersion -Force -Scope CurrentUser
            Write-Host "$ModuleName (version $RequiredVersion) successfully installed." -ForegroundColor Green
        } catch {
            Write-Host "Failed to install $ModuleName (version $RequiredVersion): $_" -ForegroundColor Red
        }
    } else {
        Write-Host "$ModuleName (version $RequiredVersion) is already installed." -ForegroundColor Green
    }
}

# The required versions were tested on a brand new computer and work without issue
Install-ModuleIfNotPresent -ModuleName "AzureAD" -RequiredVersion "2.0.2.182"
Install-ModuleIfNotPresent -ModuleName "Microsoft.Graph.Authentication" -RequiredVersion "2.23.0"
Install-ModuleIfNotPresent -ModuleName "Microsoft.Graph.DeviceManagement" -RequiredVersion "2.23.0"
Install-ModuleIfNotPresent -ModuleName "Microsoft.Graph.Intune" -RequiredVersion "6.1907.1.0"