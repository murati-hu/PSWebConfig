<#
.SYNOPSIS
    Returns the appSettings from an or application/web config
.DESCRIPTION
    The cmdlet takes an application/web configuration as an input and returns
    all applicationsettings from it.

.PARAMETER ConfigXml
    Mandatory - Pipeline input for Configuration XML

.EXAMPLE
    Get-PSWebConfig -Path 'C:\inetpub\wwwroot\myapp' | Get-PSAppSetting
.EXAMPLE
    Get-WebSite mysite | Get-PSWebConfig | Get-PSAppSetting
#>
function Get-PSAppSetting {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeLine=$true)]
        [psobject[]]$ConfigXml
    )

    process {
        foreach ($config in $ConfigXml) {
            if ($config -is [string]) { $config = [xml]$config }

            if ($config | Get-Member -Name configuration) {
                if ($config.configuration.appSettings.EncryptedData) {
                    Write-Warning "appSettings section is encrypted. You may not see all relevant entries."
                }

                foreach ($appSetting in $config.configuration.appSettings.add) {
                    $appSetting |
                    Add-Member -NotePropertyName Session -NotePropertyValue $config.Session -Force -PassThru |
                    Add-Member -NotePropertyName ComputerName -NotePropertyValue $config.ComputerName -Force -PassThru |
                    Add-Member -NotePropertyName File -NotePropertyValue $config.File -Force -PassThru |
                    Add-Member -NotePropertyName SectionPath -NotePropertyValue "appSettings" -Force -PassThru |
                    Set_Type -TypeName "PSWebConfig.AppSetting"
                }
            }
        }
    }
}
