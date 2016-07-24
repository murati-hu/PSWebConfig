# IISAdministration and WebAdministration compatible aliases
New-Alias -Name Test-WebConfigFile -Value Test-PSWebConfig -Scope Script

# Common aliases for application config scenarios
New-Alias -Name Get-PSAppConfig -Value Get-PSWebConfig -Scope Script
New-Alias -Name Test-PSAppConfig -Value Test-PSWebConfig -Scope Script
