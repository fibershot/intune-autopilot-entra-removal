# If any of the modules are already installed then use # to comment them out.
# Scopes are AllUsers, feel free to change if you know what you are doing!

Install-Module Microsoft.Graph -Force -AllowClobber -Scope AllUsers
Install-Module AzureAd -Force -Scope AllUsers

Install-Module -Name Microsoft.Graph.Authentication -RequiredVersion 2.15.0
Install-Module -Name Microsoft.Graph.Authentication -RequiredVersion 2.23.0

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Install-Module -Name Microsoft.Graph.Entra -Repository PSGallery -Scope AllUsers -AllowPrerelease